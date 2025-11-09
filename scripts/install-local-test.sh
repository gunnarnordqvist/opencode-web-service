#!/bin/bash
###############################################################################
# OpenCode Web Service - LOCAL TEST INSTALLATION
# For local testing without SSL/Let's Encrypt
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
OPENCODE_USER="opencode"
OPENCODE_HOME="/opt/opencode"
OPENCODE_PORT="3000"
NGINX_AVAILABLE="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"
SYSTEMD_PATH="/etc/systemd/system"
DOMAIN_NAME="localhost"

###############################################################################
# Helper Functions
###############################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
        log_info "Detected OS: $OS $VERSION"
    else
        log_error "Cannot detect OS"
        exit 1
    fi
}

install_dependencies() {
    log_info "Installing dependencies..."
    
    case $OS in
        ubuntu|debian)
            apt-get update
            apt-get install -y curl wget git nginx nodejs npm
            ;;
        *)
            log_error "Unsupported OS for test installation: $OS"
            exit 1
            ;;
    esac
    
    log_success "Dependencies installed"
}

create_user() {
    log_info "Creating OpenCode service user..."
    
    if id "$OPENCODE_USER" &>/dev/null; then
        log_warning "User $OPENCODE_USER already exists"
    else
        useradd -r -m -d "$OPENCODE_HOME" -s /bin/bash "$OPENCODE_USER"
        log_success "User $OPENCODE_USER created"
    fi
}

create_test_app() {
    log_info "Creating test OpenCode application..."
    
    mkdir -p "$OPENCODE_HOME"/{app,config,logs,data}
    
    # Create a simple Node.js test application
    cat > "$OPENCODE_HOME/app/server.js" <<'EOAPP'
const http = require('http');
const port = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  const response = {
    message: 'OpenCode Web Service - Test Installation',
    status: 'running',
    timestamp: new Date().toISOString(),
    path: req.url,
    method: req.method,
    headers: req.headers
  };
  
  // Health check endpoint
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'healthy' }));
    return;
  }
  
  // Main endpoint
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(response, null, 2));
});

server.listen(port, () => {
  console.log(`OpenCode test server listening on port ${port}`);
});
EOAPP

    # Set ownership
    chown -R "$OPENCODE_USER:$OPENCODE_USER" "$OPENCODE_HOME"
    
    log_success "Test application created"
}

configure_systemd() {
    log_info "Configuring systemd service..."
    
    cat > "$SYSTEMD_PATH/opencode.service" <<EOF
[Unit]
Description=OpenCode Web Service (Test)
After=network.target

[Service]
Type=simple
User=$OPENCODE_USER
Group=$OPENCODE_USER
WorkingDirectory=$OPENCODE_HOME/app
Environment="NODE_ENV=development"
Environment="PORT=$OPENCODE_PORT"
ExecStart=/usr/bin/node $OPENCODE_HOME/app/server.js
Restart=always
RestartSec=10
StandardOutput=append:$OPENCODE_HOME/logs/opencode.log
StandardError=append:$OPENCODE_HOME/logs/opencode.error.log

# Basic security
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable opencode.service
    
    log_success "Systemd service configured"
}

configure_nginx() {
    log_info "Configuring Nginx for local testing..."
    
    # Backup existing default config
    if [ -f "$NGINX_AVAILABLE/default" ]; then
        cp "$NGINX_AVAILABLE/default" "$NGINX_AVAILABLE/default.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create Nginx configuration (HTTP only, no SSL)
    cat > "$NGINX_AVAILABLE/opencode-test" <<'EOF'
# OpenCode Web Service - Local Test Configuration

upstream opencode_backend {
    server 127.0.0.1:3000;
    keepalive 64;
}

# HTTP server
server {
    listen 8080;
    listen [::]:8080;
    server_name localhost;
    
    # Logging
    access_log /var/log/nginx/opencode-access.log;
    error_log /var/log/nginx/opencode-error.log;
    
    # Security headers (even for test)
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Max upload size
    client_max_body_size 100M;
    
    # Proxy settings
    location / {
        proxy_pass http://opencode_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Buffering
        proxy_buffering off;
        proxy_request_buffering off;
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        proxy_pass http://opencode_backend;
        proxy_set_header Host $host;
    }
}
EOF
    
    # Enable site
    ln -sf "$NGINX_AVAILABLE/opencode-test" "$NGINX_ENABLED/opencode-test"
    
    # Disable default site to avoid conflicts
    if [ -L "$NGINX_ENABLED/default" ]; then
        rm "$NGINX_ENABLED/default"
    fi
    
    # Test configuration
    nginx -t
    
    log_success "Nginx configured (HTTP only on port 8080)"
}

setup_logrotate() {
    log_info "Setting up log rotation..."
    
    cat > /etc/logrotate.d/opencode <<EOF
$OPENCODE_HOME/logs/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 $OPENCODE_USER $OPENCODE_USER
    sharedscripts
    postrotate
        systemctl reload opencode > /dev/null 2>&1 || true
    endscript
}
EOF
    
    log_success "Log rotation configured"
}

start_services() {
    log_info "Starting services..."
    
    systemctl start opencode
    systemctl reload nginx
    
    # Wait a moment for services to start
    sleep 2
    
    log_success "Services started"
}

test_installation() {
    log_info "Testing installation..."
    
    # Test OpenCode service
    if systemctl is-active --quiet opencode; then
        log_success "OpenCode service is running"
    else
        log_error "OpenCode service is not running"
        systemctl status opencode
    fi
    
    # Test direct connection to app
    if curl -s http://localhost:3000/health > /dev/null; then
        log_success "OpenCode app responds on port 3000"
    else
        log_warning "OpenCode app not responding on port 3000"
    fi
    
    # Test Nginx proxy
    if curl -s http://localhost:8080/health > /dev/null; then
        log_success "Nginx proxy working on port 8080"
    else
        log_warning "Nginx proxy not responding on port 8080"
    fi
}

print_summary() {
    echo ""
    echo "========================================================================"
    log_success "OpenCode Web Service TEST installation completed!"
    echo "========================================================================"
    echo ""
    echo "Installation Details:"
    echo "  - OpenCode User: $OPENCODE_USER"
    echo "  - OpenCode Home: $OPENCODE_HOME"
    echo "  - OpenCode Port: $OPENCODE_PORT"
    echo "  - Nginx Port: 8080 (HTTP only)"
    echo ""
    echo "Test URLs:"
    echo "  - Direct app: http://localhost:3000"
    echo "  - Via Nginx:  http://localhost:8080"
    echo "  - Health:     http://localhost:8080/health"
    echo ""
    echo "Service Management:"
    echo "  - Start:   sudo systemctl start opencode"
    echo "  - Stop:    sudo systemctl stop opencode"
    echo "  - Restart: sudo systemctl restart opencode"
    echo "  - Status:  sudo systemctl status opencode"
    echo "  - Logs:    sudo journalctl -u opencode -f"
    echo ""
    echo "Testing:"
    echo "  curl http://localhost:8080"
    echo "  curl http://localhost:8080/health"
    echo ""
    echo "File Locations:"
    echo "  - Application: $OPENCODE_HOME/app/server.js"
    echo "  - Logs: $OPENCODE_HOME/logs/"
    echo "  - Nginx config: $NGINX_AVAILABLE/opencode-test"
    echo ""
    echo "⚠️  NOTE: This is a TEST installation without SSL/IdP"
    echo "For production, use the full installation script on a real server."
    echo ""
    echo "========================================================================"
}

###############################################################################
# Main Installation Flow
###############################################################################

main() {
    echo "========================================================================"
    echo "   OpenCode Web Service - LOCAL TEST INSTALLATION"
    echo "   HTTP only (no SSL) - For development/testing"
    echo "========================================================================"
    echo ""
    
    check_root
    detect_os
    install_dependencies
    create_user
    create_test_app
    configure_systemd
    configure_nginx
    setup_logrotate
    start_services
    test_installation
    print_summary
}

# Run main installation
main "$@"
