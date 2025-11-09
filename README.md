# OpenCode Web Service

> Secure and scalable setup for running OpenCode Web Solution as a service with Identity Provider (IdP) integration.

## Features

- ✅ **Automated Installation**: One-command setup for OpenCode with Nginx and systemd
- 🔐 **IdP Integration**: Support for Auth0, Okta, Azure AD, Google Workspace, Keycloak, and generic OIDC
- 🔒 **SSL/TLS**: Automatic Let's Encrypt certificate provisioning and renewal
- 🛡️ **Security Hardening**: Firewall configuration, Fail2ban, and systemd security features
- 📊 **Production Ready**: Log rotation, monitoring, and service management
- 🐧 **Cross-Platform**: Support for Ubuntu, Debian, CentOS, RHEL, Fedora, Arch, and Raspberry Pi OS
- 🔄 **OAuth2 Proxy**: Built-in authentication proxy for securing your OpenCode instance

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [IdP Configuration](#idp-configuration)
- [Usage](#usage)
- [Architecture](#architecture)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

## Prerequisites

### System Requirements

- **Operating System**: Linux-based distribution
  - Ubuntu 20.04 LTS or later
  - Debian 11 or later
  - CentOS 8 or later / RHEL 8 or later
  - Fedora 35 or later
  - Arch Linux
  - Raspberry Pi OS (Bullseye or later)
- **Memory**: Minimum 2GB RAM (4GB+ recommended)
- **Storage**: Minimum 20GB free disk space
- **Network**: Public IP address or domain name
- **Privileges**: Root or sudo access

### Domain Requirements

- A registered domain name pointing to your server's IP address
- DNS A record configured (e.g., `opencode.example.com` → `your.server.ip`)
- Port 80 and 443 accessible from the internet (for Let's Encrypt validation)

### Software Prerequisites

The installation script will automatically install:
- Node.js (v14+)
- Nginx
- Certbot (Let's Encrypt client)
- Git
- Firewall (ufw or firewalld)
- Fail2ban
- OAuth2 Proxy

## Quick Start

### Install via npm

```bash
# Install the package globally
sudo npm install -g opencode-web-service

# Run the installation
sudo opencode-install

# Configure IdP integration
sudo opencode-setup-idp
```

### Install from source

```bash
# Clone the repository
git clone https://github.com/yourusername/opencode-web-service.git
cd opencode-web-service

# Run the installation script
sudo bash scripts/install.sh

# Configure IdP integration
sudo bash scripts/setup-idp.sh
```

## Installation

### Step 1: Run the Installation Script

The installation script will:
1. Detect your operating system
2. Install system dependencies
3. Create a dedicated service user
4. Install OpenCode
5. Configure systemd service
6. Set up Nginx with SSL
7. Configure firewall rules
8. Set up Fail2ban for security
9. Configure log rotation

```bash
sudo bash scripts/install.sh
```

During installation, you'll be prompted for:
- **Domain name**: Your fully qualified domain name (e.g., `opencode.example.com`)
- **Admin email**: Email address for Let's Encrypt certificate notifications

### Step 2: Verify Installation

Check that all services are running:

```bash
# Check OpenCode service
sudo systemctl status opencode

# Check Nginx
sudo systemctl status nginx

# Check SSL certificate
sudo certbot certificates

# Test the connection
curl -I https://your-domain.com
```

### Step 3: Configure IdP Integration

See [IdP Configuration](#idp-configuration) section below.

## IdP Configuration

OpenCode Web Service supports multiple Identity Provider (IdP) options through OAuth2/OIDC.

### Supported Providers

1. **Auth0** - Cloud-based identity platform
2. **Okta** - Enterprise identity management
3. **Azure AD** (Microsoft Entra ID) - Microsoft's identity service
4. **Google Workspace** - Google's identity platform
5. **Keycloak** - Open-source identity and access management
6. **Generic OIDC** - Any OpenID Connect compliant provider

### Running the IdP Setup

```bash
sudo bash scripts/setup-idp.sh
```

The script will:
1. Prompt you to select your IdP provider
2. Request provider-specific configuration details
3. Install and configure OAuth2 Proxy
4. Update Nginx configuration for authentication
5. Create systemd service for OAuth2 Proxy
6. Generate secure session secrets

### Provider-Specific Guides

Detailed setup instructions for each provider are available in the documentation:

- [Auth0 Setup Guide](docs/providers/AUTH0.md)
- [Okta Setup Guide](docs/providers/OKTA.md)
- [Azure AD Setup Guide](docs/providers/AZURE.md)
- [Google Workspace Setup Guide](docs/providers/GOOGLE.md)
- [Keycloak Setup Guide](docs/providers/KEYCLOAK.md)
- [Generic OIDC Setup Guide](docs/providers/GENERIC_OIDC.md)

### Configuration Files

After IdP setup, configuration is stored in:
- `/opt/opencode/config/.env` - Environment variables with IdP credentials
- `/opt/opencode/config/oauth2-proxy.cfg` - OAuth2 Proxy configuration
- `/etc/nginx/sites-available/opencode-oauth2` - Nginx OAuth2 configuration

### Callback URL

All IdP providers require you to configure an authorized callback URL:

```
https://your-domain.com/oauth2/callback
```

Add this URL to your IdP application's allowed redirect URIs.

## Usage

### Service Management

```bash
# Start OpenCode
sudo systemctl start opencode

# Stop OpenCode
sudo systemctl stop opencode

# Restart OpenCode
sudo systemctl restart opencode

# Check status
sudo systemctl status opencode

# Enable auto-start on boot
sudo systemctl enable opencode

# Disable auto-start on boot
sudo systemctl disable opencode
```

### OAuth2 Proxy Management

```bash
# Start OAuth2 Proxy
sudo systemctl start oauth2-proxy

# Stop OAuth2 Proxy
sudo systemctl stop oauth2-proxy

# Restart OAuth2 Proxy
sudo systemctl restart oauth2-proxy

# Check status
sudo systemctl status oauth2-proxy
```

### Viewing Logs

```bash
# OpenCode application logs
sudo journalctl -u opencode -f

# OpenCode file logs
sudo tail -f /opt/opencode/logs/opencode.log
sudo tail -f /opt/opencode/logs/opencode.error.log

# OAuth2 Proxy logs
sudo journalctl -u oauth2-proxy -f

# Nginx access logs
sudo tail -f /var/log/nginx/opencode-access.log

# Nginx error logs
sudo tail -f /var/log/nginx/opencode-error.log
```

### SSL Certificate Management

```bash
# Check certificate status
sudo certbot certificates

# Renew certificates manually
sudo certbot renew

# Test renewal process
sudo certbot renew --dry-run

# Renew specific certificate
sudo certbot renew --cert-name your-domain.com
```

Certificates are automatically renewed by certbot's systemd timer.

### Nginx Management

```bash
# Test Nginx configuration
sudo nginx -t

# Reload Nginx (graceful)
sudo systemctl reload nginx

# Restart Nginx
sudo systemctl restart nginx

# Check Nginx status
sudo systemctl status nginx
```

## Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         Internet                             │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            │ HTTPS (443)
                            │
                    ┌───────▼──────┐
                    │    Nginx     │
                    │  (Reverse    │
                    │   Proxy)     │
                    └───────┬──────┘
                            │
                            │ HTTP
                            │
                    ┌───────▼──────────┐
                    │  OAuth2 Proxy    │
                    │ (Authentication) │
                    └───────┬──────────┘
                            │
                            │ HTTP
                            │
                    ┌───────▼──────┐
                    │  OpenCode    │
                    │  Application │
                    └──────────────┘
```

### Components

1. **Nginx** (Port 443)
   - SSL/TLS termination
   - Reverse proxy
   - Rate limiting
   - Security headers
   - Static file caching

2. **OAuth2 Proxy** (Port 4180)
   - Authentication enforcement
   - Session management
   - IdP integration
   - Token validation

3. **OpenCode Application** (Port 3000)
   - Main application logic
   - API endpoints
   - WebSocket support

### File Structure

```
/opt/opencode/
├── bin/              # Executable binaries
├── config/           # Configuration files
│   ├── .env         # Environment variables (IdP credentials)
│   └── oauth2-proxy.cfg
├── logs/            # Application logs
│   ├── opencode.log
│   └── opencode.error.log
├── data/            # Application data
└── opencode/        # OpenCode application files

/etc/nginx/
├── sites-available/
│   ├── opencode           # Basic Nginx config
│   └── opencode-oauth2    # OAuth2-enabled config
└── sites-enabled/         # Symlinks to active configs

/etc/systemd/system/
├── opencode.service       # OpenCode systemd service
└── oauth2-proxy.service   # OAuth2 Proxy systemd service

/etc/letsencrypt/
└── live/
    └── your-domain.com/
        ├── fullchain.pem
        └── privkey.pem
```

## Security

### Security Features

1. **SSL/TLS Encryption**
   - Let's Encrypt certificates
   - TLS 1.2 and 1.3 only
   - Strong cipher suites
   - HSTS headers
   - OCSP stapling

2. **Authentication & Authorization**
   - OAuth2/OIDC integration
   - Session management
   - Secure cookie handling
   - Token-based authentication

3. **Network Security**
   - Firewall configuration (ufw/firewalld)
   - Fail2ban for brute-force protection
   - Rate limiting
   - Connection limits

4. **Application Security**
   - Security headers (CSP, X-Frame-Options, etc.)
   - XSS protection
   - CSRF protection
   - Input validation

5. **System Hardening**
   - Dedicated service user
   - Systemd security features:
     - `NoNewPrivileges=true`
     - `PrivateTmp=true`
     - `ProtectSystem=strict`
     - `ProtectHome=true`
     - And more...

6. **Logging & Monitoring**
   - Comprehensive logging
   - Log rotation
   - Access logs
   - Error logs
   - Audit trails

### Security Best Practices

1. **Keep Software Updated**
   ```bash
   # Update system packages regularly
   sudo apt update && sudo apt upgrade -y  # Debian/Ubuntu
   sudo yum update -y                      # CentOS/RHEL
   ```

2. **Monitor Logs**
   ```bash
   # Review logs regularly for suspicious activity
   sudo tail -f /var/log/nginx/opencode-access.log
   sudo journalctl -u opencode -f
   ```

3. **Review Fail2ban Status**
   ```bash
   sudo fail2ban-client status
   sudo fail2ban-client status nginx-http-auth
   ```

4. **Backup Configuration**
   ```bash
   # Backup important configuration files
   sudo tar -czf opencode-backup-$(date +%Y%m%d).tar.gz \
     /opt/opencode/config \
     /etc/nginx/sites-available/opencode* \
     /etc/systemd/system/opencode.service \
     /etc/systemd/system/oauth2-proxy.service
   ```

5. **Test SSL Configuration**
   ```bash
   # Use SSL Labs to test your SSL configuration
   # Visit: https://www.ssllabs.com/ssltest/
   ```

## Troubleshooting

### Common Issues

#### 1. Installation Fails

**Problem**: Installation script exits with errors

**Solution**:
```bash
# Check system requirements
cat /etc/os-release

# Ensure you're running as root
sudo -i

# Check internet connectivity
ping -c 3 google.com

# Review installation logs
sudo journalctl -xe
```

#### 2. SSL Certificate Issues

**Problem**: Let's Encrypt certificate generation fails

**Solution**:
```bash
# Verify DNS is correctly configured
nslookup your-domain.com

# Check port 80 is accessible
sudo netstat -tlnp | grep :80

# Check Let's Encrypt logs
sudo tail -f /var/log/letsencrypt/letsencrypt.log

# Try manual certificate generation
sudo certbot certonly --nginx -d your-domain.com
```

#### 3. Service Won't Start

**Problem**: OpenCode service fails to start

**Solution**:
```bash
# Check service status
sudo systemctl status opencode

# View detailed logs
sudo journalctl -u opencode -n 50

# Check configuration
sudo nginx -t

# Verify file permissions
sudo ls -la /opt/opencode/

# Restart service
sudo systemctl restart opencode
```

#### 4. OAuth2 Authentication Fails

**Problem**: Users can't log in via IdP

**Solution**:
```bash
# Check OAuth2 Proxy logs
sudo journalctl -u oauth2-proxy -n 50

# Verify environment variables
sudo cat /opt/opencode/config/.env

# Test OAuth2 Proxy configuration
sudo /usr/local/bin/oauth2-proxy --config=/opt/opencode/config/oauth2-proxy.cfg --test

# Verify callback URL is correct
# Should be: https://your-domain.com/oauth2/callback
```

#### 5. Nginx 502 Bad Gateway

**Problem**: Nginx returns 502 error

**Solution**:
```bash
# Check if OpenCode is running
sudo systemctl status opencode

# Verify port 3000 is listening
sudo netstat -tlnp | grep :3000

# Check Nginx error logs
sudo tail -f /var/log/nginx/opencode-error.log

# Restart services
sudo systemctl restart opencode
sudo systemctl restart nginx
```

### Getting Help

If you encounter issues not covered here:

1. Check the [full documentation](docs/)
2. Review the [FAQ](docs/FAQ.md)
3. Search [existing issues](https://github.com/yourusername/opencode-web-service/issues)
4. Open a [new issue](https://github.com/yourusername/opencode-web-service/issues/new)

## Documentation

Comprehensive documentation is available in the `docs/` directory:

- [Installation Guide](docs/INSTALLATION.md) - Detailed installation instructions
- [IdP Setup Guide](docs/IDP_SETUP.md) - Complete IdP configuration guide
- [SSL Management](docs/SSL_MANAGEMENT.md) - Certificate management and renewal
- [Security Guide](docs/SECURITY.md) - Security best practices and hardening
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions
- [FAQ](docs/FAQ.md) - Frequently asked questions
- [API Documentation](docs/API.md) - API endpoints and usage
- [Configuration Reference](docs/CONFIGURATION.md) - All configuration options

### Provider-Specific Guides

- [Auth0](docs/providers/AUTH0.md)
- [Okta](docs/providers/OKTA.md)
- [Azure AD](docs/providers/AZURE.md)
- [Google Workspace](docs/providers/GOOGLE.md)
- [Keycloak](docs/providers/KEYCLOAK.md)
- [Generic OIDC](docs/providers/GENERIC_OIDC.md)

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/opencode-web-service.git
cd opencode-web-service

# Install dependencies
npm install

# Run tests
npm test
```

### Running Tests

```bash
# Run all tests
npm test

# Test on specific distribution
bash tests/test-ubuntu.sh
bash tests/test-debian.sh
bash tests/test-centos.sh
bash tests/test-raspbian.sh
```

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- [OpenCode](https://github.com/anthropic/opencode) by Anthropic
- [OAuth2 Proxy](https://github.com/oauth2-proxy/oauth2-proxy)
- [Let's Encrypt](https://letsencrypt.org/)
- [Nginx](https://nginx.org/)

## Support

- 📧 Email: support@example.com
- 💬 Discord: [Join our community](https://discord.gg/example)
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/opencode-web-service/issues)
- 📖 Documentation: [Full Docs](https://docs.example.com)

---

**Made with ❤️ for the OpenCode community**
