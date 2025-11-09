# Changelog

All notable changes to OpenCode Web Service will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-09

### Added

#### Core Features
- Automated installation script for OpenCode with Nginx and systemd
- Support for multiple Linux distributions:
  - Ubuntu 20.04 LTS and later
  - Debian 11 and later
  - CentOS 8 and later / RHEL 8 and later
  - Fedora 35 and later
  - Arch Linux
  - Raspberry Pi OS (Bullseye and later)

#### Identity Provider Integration
- IdP setup script with support for:
  - Auth0
  - Okta
  - Azure AD (Microsoft Entra ID)
  - Google Workspace
  - Keycloak
  - Generic OIDC providers
- OAuth2 Proxy integration for authentication
- Automated OAuth2 configuration
- Session management with configurable timeouts

#### Security Features
- Let's Encrypt SSL/TLS certificate automation
- Automatic certificate renewal
- Nginx reverse proxy with security headers
- Firewall configuration (ufw/firewalld)
- Fail2ban integration for brute-force protection
- Systemd security hardening:
  - NoNewPrivileges
  - PrivateTmp
  - ProtectSystem
  - ProtectHome
  - And more...
- Rate limiting and connection limits

#### Nginx Configuration
- HTTP to HTTPS redirect
- WebSocket support
- Security headers (HSTS, CSP, X-Frame-Options, etc.)
- OCSP stapling
- TLS 1.2 and 1.3 support
- Strong cipher suites
- Gzip compression
- Static file caching

#### Service Management
- Systemd service files for:
  - OpenCode application
  - OAuth2 Proxy
- Automatic service startup on boot
- Service health monitoring
- Graceful restart capabilities

#### Logging and Monitoring
- Comprehensive logging setup
- Log rotation configuration
- Access logs and error logs
- Systemd journal integration
- Fail2ban log monitoring

#### Documentation
- Comprehensive README with:
  - Installation instructions
  - Usage guidelines
  - Architecture overview
  - Security features
  - Troubleshooting guide
- IdP Setup Guide with:
  - Provider-specific instructions
  - Configuration examples
  - Testing procedures
  - Troubleshooting tips
- SSL Management Guide with:
  - Certificate obtainment
  - Renewal procedures
  - Verification methods
  - Advanced configuration
- Provider-specific guides:
  - Auth0 detailed setup
  - (More providers to be added)
- CONTRIBUTING guidelines
- Quick Installation Guide

#### Testing
- Test suite for validation:
  - Script existence checks
  - Executable permissions
  - Syntax validation
  - Template verification
  - Documentation checks
- Support for Docker-based testing

#### Configuration Templates
- Systemd service template with security hardening
- Nginx configuration template with best practices
- OAuth2 Proxy configuration template
- Environment variable templates

### Security
- All scripts run with error checking (`set -e`)
- Secure credential handling
- No hardcoded secrets
- File permission management
- Principle of least privilege

### Dependencies
- Node.js 14+
- Nginx
- Certbot (Let's Encrypt client)
- OAuth2 Proxy 7.5.1
- Git
- Fail2ban
- UFW or Firewalld

## [Unreleased]

### Planned Features
- Additional IdP provider guides (Okta, Azure AD, Google, Keycloak)
- Docker Compose deployment option
- Kubernetes deployment manifests
- Ansible playbook for automation
- Terraform modules for infrastructure
- Health check endpoints
- Metrics and monitoring integration
- Backup and restore scripts
- Migration scripts for upgrades
- Multi-instance deployment support
- Redis session storage option
- Database connection pooling
- WebSocket load balancing
- API documentation
- Admin dashboard
- User management interface

### Known Issues
- None reported yet

## Release Notes

### Version 1.0.0

This is the initial release of OpenCode Web Service, providing a complete, production-ready setup for running OpenCode as a secure web service with Identity Provider integration.

**Key Highlights:**
- ✅ One-command installation
- ✅ Support for 6 major IdP providers
- ✅ Automatic SSL/TLS certificates
- ✅ Production-grade security
- ✅ Comprehensive documentation
- ✅ Multi-distribution support

**What's Included:**
- 2 main installation scripts (~800 lines)
- 13 configuration files and templates
- 3 comprehensive documentation guides
- 1 provider-specific guide (Auth0)
- Test suite for validation
- MIT License

**Installation Time:** ~5-10 minutes
**Lines of Code:** ~4,300+
**Documentation Pages:** 1,500+ lines

---

## How to Upgrade

### From Source

```bash
cd opencode-web-service
git pull origin main
sudo bash scripts/install.sh
```

### Via npm

```bash
sudo npm update -g opencode-web-service
```

---

## Support

For questions, issues, or feature requests:
- GitHub Issues: https://github.com/yourusername/opencode-web-service/issues
- Discussions: https://github.com/yourusername/opencode-web-service/discussions
- Documentation: https://github.com/yourusername/opencode-web-service/tree/main/docs

---

**Stay Updated**: Watch this repository for updates and new releases.
