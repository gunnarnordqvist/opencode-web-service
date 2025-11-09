#!/bin/bash
###############################################################################
# OpenCode IdP (Identity Provider) Setup Script
# Supports OAuth2/OIDC integration with popular IdP providers
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OPENCODE_HOME="/opt/opencode"
CONFIG_DIR="$OPENCODE_HOME/config"
ENV_FILE="$CONFIG_DIR/.env"

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

select_idp_provider() {
    echo ""
    echo "Select your Identity Provider:"
    echo "  1) Auth0"
    echo "  2) Okta"
    echo "  3) Azure AD (Microsoft Entra ID)"
    echo "  4) Google Workspace"
    echo "  5) Keycloak"
    echo "  6) Generic OIDC Provider"
    echo ""
    read -p "Enter choice [1-6]: " IDP_CHOICE
    
    case $IDP_CHOICE in
        1) IDP_PROVIDER="auth0" ;;
        2) IDP_PROVIDER="okta" ;;
        3) IDP_PROVIDER="azure" ;;
        4) IDP_PROVIDER="google" ;;
        5) IDP_PROVIDER="keycloak" ;;
        6) IDP_PROVIDER="generic" ;;
        *) 
            log_error "Invalid choice"
            exit 1
            ;;
    esac
    
    log_info "Selected provider: $IDP_PROVIDER"
}

configure_auth0() {
    log_info "Configuring Auth0 integration..."
    
    read -p "Enter Auth0 Domain (e.g., your-tenant.auth0.com): " AUTH0_DOMAIN
    read -p "Enter Auth0 Client ID: " AUTH0_CLIENT_ID
    read -sp "Enter Auth0 Client Secret: " AUTH0_CLIENT_SECRET
    echo ""
    read -p "Enter Auth0 Audience (optional): " AUTH0_AUDIENCE
    
    cat >> "$ENV_FILE" <<EOF

# Auth0 Configuration
IDP_PROVIDER=auth0
AUTH0_DOMAIN=$AUTH0_DOMAIN
AUTH0_CLIENT_ID=$AUTH0_CLIENT_ID
AUTH0_CLIENT_SECRET=$AUTH0_CLIENT_SECRET
AUTH0_AUDIENCE=$AUTH0_AUDIENCE
OAUTH_ISSUER_URL=https://$AUTH0_DOMAIN/
OAUTH_AUTHORIZATION_URL=https://$AUTH0_DOMAIN/authorize
OAUTH_TOKEN_URL=https://$AUTH0_DOMAIN/oauth/token
OAUTH_USERINFO_URL=https://$AUTH0_DOMAIN/userinfo
OAUTH_CALLBACK_URL=https://$DOMAIN_NAME/oauth2/callback
EOF
    
    log_success "Auth0 configuration saved"
}

configure_okta() {
    log_info "Configuring Okta integration..."
    
    read -p "Enter Okta Domain (e.g., dev-123456.okta.com): " OKTA_DOMAIN
    read -p "Enter Okta Client ID: " OKTA_CLIENT_ID
    read -sp "Enter Okta Client Secret: " OKTA_CLIENT_SECRET
    echo ""
    
    cat >> "$ENV_FILE" <<EOF

# Okta Configuration
IDP_PROVIDER=okta
OKTA_DOMAIN=$OKTA_DOMAIN
OKTA_CLIENT_ID=$OKTA_CLIENT_ID
OKTA_CLIENT_SECRET=$OKTA_CLIENT_SECRET
OAUTH_ISSUER_URL=https://$OKTA_DOMAIN/oauth2/default
OAUTH_AUTHORIZATION_URL=https://$OKTA_DOMAIN/oauth2/default/v1/authorize
OAUTH_TOKEN_URL=https://$OKTA_DOMAIN/oauth2/default/v1/token
OAUTH_USERINFO_URL=https://$OKTA_DOMAIN/oauth2/default/v1/userinfo
OAUTH_CALLBACK_URL=https://$DOMAIN_NAME/oauth2/callback
EOF
    
    log_success "Okta configuration saved"
}

configure_azure() {
    log_info "Configuring Azure AD integration..."
    
    read -p "Enter Azure Tenant ID: " AZURE_TENANT_ID
    read -p "Enter Azure Client ID (Application ID): " AZURE_CLIENT_ID
    read -sp "Enter Azure Client Secret: " AZURE_CLIENT_SECRET
    echo ""
    
    cat >> "$ENV_FILE" <<EOF

# Azure AD Configuration
IDP_PROVIDER=azure
AZURE_TENANT_ID=$AZURE_TENANT_ID
AZURE_CLIENT_ID=$AZURE_CLIENT_ID
AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET
OAUTH_ISSUER_URL=https://login.microsoftonline.com/$AZURE_TENANT_ID/v2.0
OAUTH_AUTHORIZATION_URL=https://login.microsoftonline.com/$AZURE_TENANT_ID/oauth2/v2.0/authorize
OAUTH_TOKEN_URL=https://login.microsoftonline.com/$AZURE_TENANT_ID/oauth2/v2.0/token
OAUTH_USERINFO_URL=https://graph.microsoft.com/oidc/userinfo
OAUTH_CALLBACK_URL=https://$DOMAIN_NAME/oauth2/callback
EOF
    
    log_success "Azure AD configuration saved"
}

configure_google() {
    log_info "Configuring Google Workspace integration..."
    
    read -p "Enter Google Client ID: " GOOGLE_CLIENT_ID
    read -sp "Enter Google Client Secret: " GOOGLE_CLIENT_SECRET
    echo ""
    read -p "Enter Hosted Domain (optional, e.g., example.com): " GOOGLE_HD
    
    cat >> "$ENV_FILE" <<EOF

# Google Workspace Configuration
IDP_PROVIDER=google
GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET=$GOOGLE_CLIENT_SECRET
GOOGLE_HD=$GOOGLE_HD
OAUTH_ISSUER_URL=https://accounts.google.com
OAUTH_AUTHORIZATION_URL=https://accounts.google.com/o/oauth2/v2/auth
OAUTH_TOKEN_URL=https://oauth2.googleapis.com/token
OAUTH_USERINFO_URL=https://openidconnect.googleapis.com/v1/userinfo
OAUTH_CALLBACK_URL=https://$DOMAIN_NAME/oauth2/callback
EOF
    
    log_success "Google Workspace configuration saved"
}

configure_keycloak() {
    log_info "Configuring Keycloak integration..."
    
    read -p "Enter Keycloak URL (e.g., https://keycloak.example.com): " KEYCLOAK_URL
    read -p "Enter Realm Name: " KEYCLOAK_REALM
    read -p "Enter Client ID: " KEYCLOAK_CLIENT_ID
    read -sp "Enter Client Secret: " KEYCLOAK_CLIENT_SECRET
    echo ""
    
    cat >> "$ENV_FILE" <<EOF

# Keycloak Configuration
IDP_PROVIDER=keycloak
KEYCLOAK_URL=$KEYCLOAK_URL
KEYCLOAK_REALM=$KEYCLOAK_REALM
KEYCLOAK_CLIENT_ID=$KEYCLOAK_CLIENT_ID
KEYCLOAK_CLIENT_SECRET=$KEYCLOAK_CLIENT_SECRET
OAUTH_ISSUER_URL=$KEYCLOAK_URL/realms/$KEYCLOAK_REALM
OAUTH_AUTHORIZATION_URL=$KEYCLOAK_URL/realms/$KEYCLOAK_REALM/protocol/openid-connect/auth
OAUTH_TOKEN_URL=$KEYCLOAK_URL/realms/$KEYCLOAK_REALM/protocol/openid-connect/token
OAUTH_USERINFO_URL=$KEYCLOAK_URL/realms/$KEYCLOAK_REALM/protocol/openid-connect/userinfo
OAUTH_CALLBACK_URL=https://$DOMAIN_NAME/oauth2/callback
EOF
    
    log_success "Keycloak configuration saved"
}

configure_generic() {
    log_info "Configuring Generic OIDC Provider..."
    
    read -p "Enter Issuer URL: " OIDC_ISSUER
    read -p "Enter Authorization URL: " OIDC_AUTH_URL
    read -p "Enter Token URL: " OIDC_TOKEN_URL
    read -p "Enter UserInfo URL: " OIDC_USERINFO_URL
    read -p "Enter Client ID: " OIDC_CLIENT_ID
    read -sp "Enter Client Secret: " OIDC_CLIENT_SECRET
    echo ""
    
    cat >> "$ENV_FILE" <<EOF

# Generic OIDC Configuration
IDP_PROVIDER=generic
OAUTH_ISSUER_URL=$OIDC_ISSUER
OAUTH_AUTHORIZATION_URL=$OIDC_AUTH_URL
OAUTH_TOKEN_URL=$OIDC_TOKEN_URL
OAUTH_USERINFO_URL=$OIDC_USERINFO_URL
OAUTH_CLIENT_ID=$OIDC_CLIENT_ID
OAUTH_CLIENT_SECRET=$OIDC_CLIENT_SECRET
OAUTH_CALLBACK_URL=https://$DOMAIN_NAME/oauth2/callback
EOF
    
    log_success "Generic OIDC configuration saved"
}

configure_common_settings() {
    log_info "Configuring common OAuth settings..."
    
    read -p "Enter OAuth Scope (default: openid profile email): " OAUTH_SCOPE
    OAUTH_SCOPE=${OAUTH_SCOPE:-"openid profile email"}
    
    # Generate session secret
    SESSION_SECRET=$(openssl rand -hex 32)
    
    cat >> "$ENV_FILE" <<EOF

# Common OAuth Settings
OAUTH_SCOPE=$OAUTH_SCOPE
SESSION_SECRET=$SESSION_SECRET
SESSION_MAX_AGE=86400
OAUTH_STATE_COOKIE_NAME=oauth_state
OAUTH_NONCE_COOKIE_NAME=oauth_nonce

# Security Settings
ENABLE_HTTPS=true
SECURE_COOKIES=true
SAME_SITE_COOKIES=lax
EOF
    
    log_success "Common settings configured"
}

install_oauth2_proxy() {
    log_info "Installing OAuth2 Proxy..."
    
    # Download and install oauth2-proxy
    OAUTH2_PROXY_VERSION="7.5.1"
    wget https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v${OAUTH2_PROXY_VERSION}/oauth2-proxy-v${OAUTH2_PROXY_VERSION}.linux-amd64.tar.gz
    tar -xzf oauth2-proxy-v${OAUTH2_PROXY_VERSION}.linux-amd64.tar.gz
    mv oauth2-proxy-v${OAUTH2_PROXY_VERSION}.linux-amd64/oauth2-proxy /usr/local/bin/
    chmod +x /usr/local/bin/oauth2-proxy
    rm -rf oauth2-proxy-v${OAUTH2_PROXY_VERSION}*
    
    log_success "OAuth2 Proxy installed"
}

create_oauth2_proxy_config() {
    log_info "Creating OAuth2 Proxy configuration..."
    
    cat > "$CONFIG_DIR/oauth2-proxy.cfg" <<EOF
# OAuth2 Proxy Configuration
http_address = "127.0.0.1:4180"
upstreams = [ "http://127.0.0.1:$OPENCODE_PORT/" ]

# Provider configuration (loaded from environment)
provider = "oidc"
redirect_url = "https://$DOMAIN_NAME/oauth2/callback"
oidc_issuer_url = "\${OAUTH_ISSUER_URL}"
client_id = "\${OAUTH_CLIENT_ID}"
client_secret = "\${OAUTH_CLIENT_SECRET}"

# Session configuration
cookie_name = "_oauth2_proxy"
cookie_secret = "\${SESSION_SECRET}"
cookie_secure = true
cookie_httponly = true
cookie_samesite = "lax"

# Email configuration
email_domains = [ "*" ]

# Security
skip_provider_button = false
pass_access_token = true
pass_authorization_header = true
set_authorization_header = true
set_xauthrequest = true

# Logging
request_logging = true
auth_logging = true
EOF
    
    log_success "OAuth2 Proxy configuration created"
}

update_nginx_for_oauth2() {
    log_info "Updating Nginx configuration for OAuth2 Proxy..."
    
    cat > /etc/nginx/sites-available/opencode-oauth2 <<EOF
# OpenCode with OAuth2 Proxy

upstream oauth2_proxy {
    server 127.0.0.1:4180;
}

upstream opencode_backend {
    server 127.0.0.1:$OPENCODE_PORT;
    keepalive 64;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN_NAME;
    
    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;
    
    # OAuth2 Proxy
    location /oauth2/ {
        proxy_pass http://oauth2_proxy;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Protected application
    location / {
        auth_request /oauth2/auth;
        error_page 401 = /oauth2/sign_in;
        
        # Pass authentication headers
        auth_request_set \$user \$upstream_http_x_auth_request_user;
        auth_request_set \$email \$upstream_http_x_auth_request_email;
        auth_request_set \$auth_header \$upstream_http_authorization;
        
        proxy_set_header X-User \$user;
        proxy_set_header X-Email \$email;
        proxy_set_header Authorization \$auth_header;
        
        proxy_pass http://opencode_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
    
    # Enable new configuration
    ln -sf /etc/nginx/sites-available/opencode-oauth2 /etc/nginx/sites-enabled/opencode-oauth2
    rm -f /etc/nginx/sites-enabled/opencode
    
    # Test and reload Nginx
    nginx -t && systemctl reload nginx
    
    log_success "Nginx updated for OAuth2 authentication"
}

create_oauth2_systemd_service() {
    log_info "Creating OAuth2 Proxy systemd service..."
    
    cat > /etc/systemd/system/oauth2-proxy.service <<EOF
[Unit]
Description=OAuth2 Proxy
After=network.target

[Service]
Type=simple
User=opencode
Group=opencode
EnvironmentFile=$ENV_FILE
ExecStart=/usr/local/bin/oauth2-proxy --config=$CONFIG_DIR/oauth2-proxy.cfg
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable oauth2-proxy.service
    systemctl start oauth2-proxy.service
    
    log_success "OAuth2 Proxy service created and started"
}

print_idp_summary() {
    echo ""
    echo "========================================================================"
    log_success "IdP Integration completed!"
    echo "========================================================================"
    echo ""
    echo "Configuration Details:"
    echo "  - Provider: $IDP_PROVIDER"
    echo "  - Configuration File: $ENV_FILE"
    echo "  - Callback URL: https://$DOMAIN_NAME/oauth2/callback"
    echo ""
    echo "OAuth2 Proxy:"
    echo "  - Status: systemctl status oauth2-proxy"
    echo "  - Logs: journalctl -u oauth2-proxy -f"
    echo ""
    echo "Next Steps:"
    echo "  1. Verify IdP configuration in your provider's console"
    echo "  2. Add the callback URL to your IdP's allowed redirects"
    echo "  3. Test authentication: https://$DOMAIN_NAME"
    echo "  4. Review logs for any authentication issues"
    echo ""
    echo "Documentation:"
    echo "  - Full IdP setup guide: docs/IDP_SETUP.md"
    echo "  - Troubleshooting: docs/TROUBLESHOOTING.md"
    echo ""
    echo "========================================================================"
}

###############################################################################
# Main Setup Flow
###############################################################################

main() {
    echo "========================================================================"
    echo "   OpenCode IdP Setup"
    echo "   OAuth2/OIDC Integration Configuration"
    echo "========================================================================"
    echo ""
    
    check_root
    
    # Create config directory
    mkdir -p "$CONFIG_DIR"
    
    # Get domain name
    read -p "Enter your domain name: " DOMAIN_NAME
    
    # Initialize env file
    cat > "$ENV_FILE" <<EOF
# OpenCode IdP Configuration
# Generated on $(date)
DOMAIN_NAME=$DOMAIN_NAME
OPENCODE_PORT=$OPENCODE_PORT
EOF
    
    select_idp_provider
    
    case $IDP_PROVIDER in
        auth0) configure_auth0 ;;
        okta) configure_okta ;;
        azure) configure_azure ;;
        google) configure_google ;;
        keycloak) configure_keycloak ;;
        generic) configure_generic ;;
    esac
    
    configure_common_settings
    install_oauth2_proxy
    create_oauth2_proxy_config
    update_nginx_for_oauth2
    create_oauth2_systemd_service
    
    # Set proper permissions
    chown -R opencode:opencode "$CONFIG_DIR"
    chmod 600 "$ENV_FILE"
    
    print_idp_summary
}

# Run main setup
main "$@"
