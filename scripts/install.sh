#!/bin/bash
###############################################################################
# OpenCode Web Service Installation Script
# Secure and scalable setup for running OpenCode as a service with IdP
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OPENCODE_USER="opencode"
OPENCODE_HOME="/opt/opencode"
OPENCODE_PORT="3000"
NGINX_AVAILABLE="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"
SYSTEMD_PATH="/etc/systemd/system"

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
        log_error "This script must be run as root"
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
        log_error "Cannot detect OS. /etc/os-release not found"
        exit 1
    fi
}

install_dependencies() {
    log_info "Installing system dependencies..."
    
    case $OS in
        ubuntu|debian|raspbian)
            apt-get update
            apt-get install -y curl wget git nginx certbot python3-certbot-nginx \
                nodejs npm ufw fail2ban
            ;;
        centos|rhel|fedora)
            yum install -y curl wget git nginx certbot python3-certbot-nginx \
                nodejs npm firewalld fail2ban
            ;;
        arch)
            pacman -Sy --noconfirm curl wget git nginx certbot certbot-nginx \
                nodejs npm ufw fail2ban
            ;;
        *)
            log_error "Unsupported OS: $OS"
            exit 1
            ;;
    esac
    
    log_success "System dependencies installed"
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

install_opencode() {
    log_info "Installing OpenCode..."
    
    # Create directory structure
    mkdir -p "$OPENCODE_HOME"/{bin,config,logs,data}
    
    # Install OpenCode (assuming it's available via npm or git)
    # Modify this based on actual OpenCode installation method
    cd "$OPENCODE_HOME"
    
    # Option 1: If OpenCode is an npm package
    # npm install -g @anthropic/opencode
    
    # Option 2: If OpenCode is a git repository
    if [ ! -d "$OPENCODE_HOME/opencode" ]; then
        git clone https://github.com/anthropic/opencode.git "$OPENCODE_HOME/opencode"
        cd "$OPENCODE_HOME/opencode"
        npm install --production
    fi
    
    # Set ownership
    chown -R "$OPENCODE_USER:$OPENCODE_USER" "$OPENCODE_HOME"
    
    log_success "OpenCode installed"
}

configure_systemd() {
    log_info "Configuring systemd service..."
    
    cat > "$SYSTEMD_PATH/opencode.service" <<EOF
[Unit]
Description=OpenCode Web Service
After=network.target
Documentation=https://github.com/yourusername/opencode-web-service

[Service]
Type=simple
User=$OPENCODE_USER
Group=$OPENCODE_USER
WorkingDirectory=$OPENCODE_HOME/opencode
Environment="NODE_ENV=production"
Environment="PORT=$OPENCODE_PORT"
ExecStart=/usr/bin/node $OPENCODE_HOME/opencode/server.js
Restart=always
RestartSec=10
StandardOutput=append:$OPENCODE_HOME/logs/opencode.log
StandardError=append:$OPENCODE_HOME/logs/opencode.error.log

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$OPENCODE_HOME/data $OPENCODE_HOME/logs
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable opencode.service
    
    log_success "Systemd service configured"
}

configure_nginx() {
    log_info "Configuring Nginx..."
    
    # Backup existing default config
    if [ -f "$NGINX_AVAILABLE/default" ]; then
        cp "$NGINX_AVAILABLE/default" "$NGINX_AVAILABLE/default.backup"
    fi
    
    # Read domain name
    read -p "Enter your domain name (e.g., opencode.example.com): " DOMAIN_NAME
    read -p "Enter admin email for Let's Encrypt: " ADMIN_EMAIL
    
    # Create Nginx configuration
    cat > "$NGINX_AVAILABLE/opencode" <<EOF
# OpenCode Web Service Nginx Configuration

upstream opencode_backend {
    server 127.0.0.1:$OPENCODE_PORT;
    keepalive 64;
}

# HTTP server - redirects to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN_NAME;
    
    # Let's Encrypt challenge
    location ^~ /.well-known/acme-challenge/ {
        default_type "text/plain";
        root /var/www/html;
    }
    
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}

# HTTPS server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN_NAME;
    
    # SSL configuration (will be managed by certbot)
    ssl_certificate /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;
    
    # SSL security settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_stapling on;
    ssl_stapling_verify on;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Logging
    access_log /var/log/nginx/opencode-access.log;
    error_log /var/log/nginx/opencode-error.log;
    
    # Max upload size
    client_max_body_size 100M;
    
    # Proxy settings
    location / {
        proxy_pass http://opencode_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Forwarded-Port \$server_port;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Buffering
        proxy_buffering off;
        proxy_request_buffering off;
    }
    
    # OAuth2/OIDC callback endpoint
    location /oauth2/callback {
        proxy_pass http://opencode_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
    
    # Enable site
    ln -sf "$NGINX_AVAILABLE/opencode" "$NGINX_ENABLED/opencode"
    
    # Test configuration
    nginx -t
    
    log_success "Nginx configured"
    
    # Obtain SSL certificate
    log_info "Obtaining SSL certificate from Let's Encrypt..."
    certbot --nginx -d "$DOMAIN_NAME" --non-interactive --agree-tos -m "$ADMIN_EMAIL"
    
    log_success "SSL certificate obtained"
}

configure_firewall() {
    log_info "Configuring firewall..."
    
    case $OS in
        ubuntu|debian|raspbian)
            ufw allow 22/tcp
            ufw allow 80/tcp
            ufw allow 443/tcp
            ufw --force enable
            ;;
        centos|rhel|fedora)
            firewall-cmd --permanent --add-service=ssh
            firewall-cmd --permanent --add-service=http
            firewall-cmd --permanent --add-service=https
            firewall-cmd --reload
            ;;
        arch)
            ufw allow 22/tcp
            ufw allow 80/tcp
            ufw allow 443/tcp
            ufw --force enable
            ;;
    esac
    
    log_success "Firewall configured"
}

configure_fail2ban() {
    log_info "Configuring Fail2ban..."
    
    cat > /etc/fail2ban/jail.d/nginx.conf <<EOF
[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/opencode-error.log

[nginx-noscript]
enabled = true
port = http,https
logpath = /var/log/nginx/opencode-access.log

[nginx-badbots]
enabled = true
port = http,https
logpath = /var/log/nginx/opencode-access.log
maxretry = 2

[nginx-noproxy]
enabled = true
port = http,https
logpath = /var/log/nginx/opencode-access.log
maxretry = 2
EOF
    
    systemctl enable fail2ban
    systemctl restart fail2ban
    
    log_success "Fail2ban configured"
}

setup_logrotate() {
    log_info "Setting up log rotation..."
    
    cat > /etc/logrotate.d/opencode <<EOF
$OPENCODE_HOME/logs/*.log {
    daily
    missingok
    rotate 14
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
    systemctl restart nginx
    
    log_success "Services started"
}

print_summary() {
    echo ""
    echo "========================================================================"
    log_success "OpenCode Web Service installation completed!"
    echo "========================================================================"
    echo ""
    echo "Installation Details:"
    echo "  - OpenCode User: $OPENCODE_USER"
    echo "  - OpenCode Home: $OPENCODE_HOME"
    echo "  - OpenCode Port: $OPENCODE_PORT"
    echo "  - Domain: $DOMAIN_NAME"
    echo ""
    echo "Service Management:"
    echo "  - Start:   systemctl start opencode"
    echo "  - Stop:    systemctl stop opencode"
    echo "  - Restart: systemctl restart opencode"
    echo "  - Status:  systemctl status opencode"
    echo "  - Logs:    journalctl -u opencode -f"
    echo ""
    echo "Next Steps:"
    echo "  1. Configure IdP integration: npm run setup-idp"
    echo "  2. Review logs: tail -f $OPENCODE_HOME/logs/opencode.log"
    echo "  3. Access your service: https://$DOMAIN_NAME"
    echo ""
    echo "Documentation:"
    echo "  - IdP Setup: docs/IDP_SETUP.md"
    echo "  - SSL Management: docs/SSL_MANAGEMENT.md"
    echo "  - Troubleshooting: docs/TROUBLESHOOTING.md"
    echo ""
    echo "========================================================================"
}

###############################################################################
# Main Installation Flow
###############################################################################

main() {
    echo "========================================================================"
    echo "   OpenCode Web Service Installation"
    echo "   Secure and Scalable Setup with IdP Integration"
    echo "========================================================================"
    echo ""
    
    check_root
    detect_os
    install_dependencies
    create_user
    install_opencode
    configure_systemd
    configure_nginx
    configure_firewall
    configure_fail2ban
    setup_logrotate
    start_services
    print_summary
}

# Run main installation
main "$@"
