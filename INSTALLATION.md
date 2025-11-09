# Quick Installation Guide

This is a quick start guide to get OpenCode Web Service up and running in minutes.

## Prerequisites Checklist

Before you begin, ensure you have:

- [ ] A Linux server (Ubuntu 20.04+, Debian 11+, CentOS 8+, etc.)
- [ ] Root or sudo access
- [ ] A domain name (e.g., `opencode.example.com`)
- [ ] DNS A record pointing to your server's IP
- [ ] Ports 80 and 443 open (for SSL certificate validation)

## Installation Steps

### 1. Clone the Repository

```bash
# SSH to your server
ssh user@your-server-ip

# Clone the repository
git clone https://github.com/yourusername/opencode-web-service.git
cd opencode-web-service
```

### 2. Run Installation Script

```bash
# Make sure scripts are executable
chmod +x scripts/*.sh

# Run the installation (as root or with sudo)
sudo bash scripts/install.sh
```

The script will prompt you for:
- **Domain name**: Your FQDN (e.g., `opencode.example.com`)
- **Admin email**: For Let's Encrypt notifications

Installation takes approximately 5-10 minutes and includes:
- System dependencies (Node.js, Nginx, Certbot, etc.)
- OpenCode application
- Systemd service configuration
- Nginx reverse proxy setup
- SSL certificate from Let's Encrypt
- Firewall configuration
- Fail2ban security
- Log rotation

### 3. Verify Installation

After installation completes:

```bash
# Check services are running
sudo systemctl status opencode
sudo systemctl status nginx

# Test SSL certificate
curl -I https://your-domain.com

# View logs
sudo journalctl -u opencode -f
```

### 4. Configure Identity Provider (IdP)

To add authentication:

```bash
# Run IdP setup script
sudo bash scripts/setup-idp.sh
```

Select your IdP provider:
1. Auth0
2. Okta
3. Azure AD
4. Google Workspace
5. Keycloak
6. Generic OIDC

Follow the prompts and enter your IdP credentials.

### 5. Test Authentication

```bash
# Check OAuth2 Proxy is running
sudo systemctl status oauth2-proxy

# Access your application
# Open browser: https://your-domain.com
# You should be redirected to your IdP login page
```

## Quick Troubleshooting

### Installation Fails

```bash
# Check system requirements
cat /etc/os-release

# Ensure running as root
sudo -i

# Check internet connectivity
ping -c 3 google.com

# Review logs
sudo journalctl -xe
```

### SSL Certificate Issues

```bash
# Verify DNS
nslookup your-domain.com

# Check port 80 is open
sudo netstat -tlnp | grep :80

# Check Let's Encrypt logs
sudo tail -f /var/log/letsencrypt/letsencrypt.log
```

### Service Won't Start

```bash
# Check detailed status
sudo systemctl status opencode -l

# View logs
sudo journalctl -u opencode -n 50

# Test Nginx config
sudo nginx -t

# Restart services
sudo systemctl restart opencode
sudo systemctl restart nginx
```

### Authentication Issues

```bash
# Check OAuth2 Proxy logs
sudo journalctl -u oauth2-proxy -f

# Verify configuration
sudo cat /opt/opencode/config/.env

# Check callback URL in IdP matches:
# https://your-domain.com/oauth2/callback
```

## Next Steps

After successful installation:

1. **Configure Users**: Set up users in your IdP
2. **Customize Settings**: Adjust application settings as needed
3. **Set Up Monitoring**: Configure monitoring and alerts
4. **Backup Configuration**: Backup important configuration files
5. **Read Documentation**: Review full documentation in `docs/`

## Getting Help

- 📖 Full documentation: [README.md](README.md)
- 🔐 IdP setup guide: [docs/IDP_SETUP.md](docs/IDP_SETUP.md)
- 🔒 SSL management: [docs/SSL_MANAGEMENT.md](docs/SSL_MANAGEMENT.md)
- 🐛 Troubleshooting: Open a GitHub issue
- 💬 Community: Join our discussions

## Uninstallation

To remove OpenCode Web Service:

```bash
# Stop and disable services
sudo systemctl stop opencode oauth2-proxy nginx
sudo systemctl disable opencode oauth2-proxy

# Remove systemd services
sudo rm /etc/systemd/system/opencode.service
sudo rm /etc/systemd/system/oauth2-proxy.service
sudo systemctl daemon-reload

# Remove Nginx configuration
sudo rm /etc/nginx/sites-enabled/opencode*
sudo rm /etc/nginx/sites-available/opencode*
sudo systemctl restart nginx

# Remove application files
sudo rm -rf /opt/opencode

# Remove user (optional)
sudo userdel -r opencode

# Revoke SSL certificate (optional)
sudo certbot revoke --cert-path /etc/letsencrypt/live/your-domain.com/cert.pem
sudo certbot delete --cert-name your-domain.com
```

---

**Questions?** Check the [full documentation](README.md) or open an issue on GitHub.
