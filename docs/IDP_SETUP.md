# Identity Provider (IdP) Setup Guide

This comprehensive guide walks you through setting up authentication for your OpenCode Web Service using various Identity Providers (IdP).

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Setup](#quick-setup)
- [Supported Providers](#supported-providers)
- [Provider Configuration](#provider-configuration)
  - [Auth0](#auth0-setup)
  - [Okta](#okta-setup)
  - [Azure AD](#azure-ad-setup)
  - [Google Workspace](#google-workspace-setup)
  - [Keycloak](#keycloak-setup)
  - [Generic OIDC](#generic-oidc-setup)
- [Testing Authentication](#testing-authentication)
- [Troubleshooting](#troubleshooting)

## Overview

OpenCode Web Service uses OAuth2/OIDC for authentication through OAuth2 Proxy. This provides:

- **Single Sign-On (SSO)**: Users authenticate via your existing IdP
- **Centralized Identity Management**: Manage users in one place
- **Multi-Factor Authentication (MFA)**: Leverage your IdP's MFA capabilities
- **Enterprise Features**: Role-based access, group management, etc.

### Architecture

```
User → Browser → Nginx → OAuth2 Proxy → IdP (Authentication)
                    ↓
              OpenCode Application (Protected Resource)
```

## Prerequisites

Before setting up IdP integration:

1. ✅ OpenCode Web Service is installed and running
2. ✅ Domain name is configured with SSL certificate
3. ✅ Access to your IdP admin console
4. ✅ Administrator privileges on the server

## Quick Setup

Run the interactive IdP setup script:

```bash
sudo bash scripts/setup-idp.sh
```

The script will:
1. Prompt you to select your IdP provider
2. Request necessary configuration details
3. Install OAuth2 Proxy
4. Configure authentication
5. Update Nginx configuration
6. Start all services

## Supported Providers

| Provider | Type | Free Tier | Enterprise | Documentation |
|----------|------|-----------|------------|---------------|
| Auth0 | Cloud | ✅ | ✅ | [Link](providers/AUTH0.md) |
| Okta | Cloud | ✅ | ✅ | [Link](providers/OKTA.md) |
| Azure AD | Cloud | ✅ | ✅ | [Link](providers/AZURE.md) |
| Google Workspace | Cloud | ❌ | ✅ | [Link](providers/GOOGLE.md) |
| Keycloak | Self-hosted | ✅ | ✅ | [Link](providers/KEYCLOAK.md) |
| Generic OIDC | Any | Varies | Varies | [Link](providers/GENERIC_OIDC.md) |

## Provider Configuration

### Auth0 Setup

Auth0 is a popular cloud-based identity platform with a generous free tier.

#### Step 1: Create Auth0 Account

1. Go to [auth0.com](https://auth0.com)
2. Sign up for a free account
3. Create a new tenant

#### Step 2: Create Application

1. Navigate to **Applications** → **Applications**
2. Click **Create Application**
3. Choose **Regular Web Application**
4. Select **Node.js** as technology

#### Step 3: Configure Application

In the application settings:

1. **Application URIs**:
   - **Allowed Callback URLs**: `https://your-domain.com/oauth2/callback`
   - **Allowed Logout URLs**: `https://your-domain.com/`
   - **Allowed Web Origins**: `https://your-domain.com`

2. **Application Properties**:
   - Copy **Domain** (e.g., `your-tenant.auth0.com`)
   - Copy **Client ID**
   - Copy **Client Secret**

#### Step 4: Run Setup Script

```bash
sudo bash scripts/setup-idp.sh
```

When prompted:
- Select option `1` (Auth0)
- Enter your Auth0 domain
- Enter Client ID
- Enter Client Secret
- Enter Audience (optional, leave blank if not using API)

#### Step 5: Configure Users

1. Go to **User Management** → **Users**
2. Create test user or connect to existing user directory
3. Set up roles and permissions as needed

---

### Okta Setup

Okta provides enterprise-grade identity management with a developer-friendly free tier.

#### Step 1: Create Okta Account

1. Go to [developer.okta.com](https://developer.okta.com)
2. Sign up for a free developer account
3. Note your Okta domain (e.g., `dev-123456.okta.com`)

#### Step 2: Create Application

1. Navigate to **Applications** → **Applications**
2. Click **Create App Integration**
3. Select **OIDC - OpenID Connect**
4. Choose **Web Application**

#### Step 3: Configure Application

In the application settings:

1. **General Settings**:
   - **App integration name**: OpenCode Web Service
   - **Grant type**: Authorization Code

2. **Sign-in redirect URIs**:
   - Add: `https://your-domain.com/oauth2/callback`

3. **Sign-out redirect URIs**:
   - Add: `https://your-domain.com/`

4. **Controlled access**:
   - Choose who can access (e.g., "Allow everyone in your organization to access")

5. Save and copy:
   - **Client ID**
   - **Client Secret**

#### Step 4: Run Setup Script

```bash
sudo bash scripts/setup-idp.sh
```

When prompted:
- Select option `2` (Okta)
- Enter your Okta domain
- Enter Client ID
- Enter Client Secret

---

### Azure AD Setup

Microsoft Azure Active Directory (now Microsoft Entra ID) is Microsoft's cloud identity service.

#### Step 1: Access Azure Portal

1. Go to [portal.azure.com](https://portal.azure.com)
2. Sign in with your Microsoft account
3. Navigate to **Azure Active Directory**

#### Step 2: Register Application

1. Go to **App registrations**
2. Click **New registration**
3. Configure:
   - **Name**: OpenCode Web Service
   - **Supported account types**: Choose appropriate option
   - **Redirect URI**: 
     - Platform: **Web**
     - URI: `https://your-domain.com/oauth2/callback`

#### Step 3: Configure Application

1. **Copy Identifiers**:
   - Go to **Overview**
   - Copy **Application (client) ID**
   - Copy **Directory (tenant) ID**

2. **Create Client Secret**:
   - Go to **Certificates & secrets**
   - Click **New client secret**
   - Add description and expiry
   - Copy the **Value** (shown only once!)

3. **API Permissions**:
   - Go to **API permissions**
   - Ensure these permissions exist:
     - `User.Read` (Microsoft Graph)
     - `OpenID` permissions (openid, profile, email)

4. **Authentication**:
   - Go to **Authentication**
   - Verify Redirect URI is set
   - Under **Implicit grant and hybrid flows**: Leave unchecked (use Code flow)

#### Step 4: Run Setup Script

```bash
sudo bash scripts/setup-idp.sh
```

When prompted:
- Select option `3` (Azure AD)
- Enter Tenant ID
- Enter Client ID (Application ID)
- Enter Client Secret

---

### Google Workspace Setup

Google Workspace provides identity services for organizations using Google's ecosystem.

> **Note**: Requires a Google Workspace (formerly G Suite) account, not a personal Gmail account.

#### Step 1: Access Google Cloud Console

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Create a new project or select existing one

#### Step 2: Enable APIs

1. Navigate to **APIs & Services** → **Library**
2. Search and enable:
   - **Google+ API**
   - **People API**

#### Step 3: Configure OAuth Consent Screen

1. Go to **APIs & Services** → **OAuth consent screen**
2. Choose **Internal** (for Workspace users only)
3. Fill in:
   - **App name**: OpenCode Web Service
   - **User support email**: Your email
   - **Developer contact**: Your email
4. Add scopes:
   - `openid`
   - `email`
   - `profile`

#### Step 4: Create OAuth Credentials

1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **OAuth client ID**
3. Application type: **Web application**
4. Configure:
   - **Name**: OpenCode Web Service
   - **Authorized redirect URIs**: 
     - Add: `https://your-domain.com/oauth2/callback`
5. Copy:
   - **Client ID**
   - **Client Secret**

#### Step 5: Run Setup Script

```bash
sudo bash scripts/setup-idp.sh
```

When prompted:
- Select option `4` (Google Workspace)
- Enter Client ID
- Enter Client Secret
- Enter Hosted Domain (your workspace domain, e.g., `example.com`)

---

### Keycloak Setup

Keycloak is an open-source identity and access management solution you can self-host.

#### Step 1: Install Keycloak

If you don't have Keycloak installed:

```bash
# Using Docker (recommended for testing)
docker run -d \
  --name keycloak \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  quay.io/keycloak/keycloak:latest \
  start-dev
```

Or follow the [official installation guide](https://www.keycloak.org/guides#getting-started).

#### Step 2: Create Realm

1. Access Keycloak admin console (e.g., `https://keycloak.example.com`)
2. Log in with admin credentials
3. Click **Create Realm**
4. Set **Realm name** (e.g., `opencode`)

#### Step 3: Create Client

1. In your realm, go to **Clients**
2. Click **Create client**
3. Configure:
   - **Client type**: OpenID Connect
   - **Client ID**: `opencode-web-service`
4. Click **Next**
5. Enable:
   - **Client authentication**: ON
   - **Authorization**: OFF
   - **Standard flow**: ON
   - **Direct access grants**: OFF
6. Click **Next**
7. **Valid redirect URIs**: `https://your-domain.com/oauth2/callback`
8. **Web origins**: `https://your-domain.com`
9. **Save**

#### Step 4: Get Client Secret

1. Go to **Clients** → **opencode-web-service**
2. Click **Credentials** tab
3. Copy **Client secret**

#### Step 5: Create Users

1. Go to **Users**
2. Click **Add user**
3. Set username and other details
4. Go to **Credentials** tab
5. Set password

#### Step 6: Run Setup Script

```bash
sudo bash scripts/setup-idp.sh
```

When prompted:
- Select option `5` (Keycloak)
- Enter Keycloak URL (e.g., `https://keycloak.example.com`)
- Enter Realm name
- Enter Client ID
- Enter Client Secret

---

### Generic OIDC Setup

Use this option for any OpenID Connect compliant identity provider not listed above.

#### Step 1: Gather Provider Information

You need the following from your IdP:

1. **Issuer URL** (e.g., `https://idp.example.com`)
2. **Authorization Endpoint** (e.g., `https://idp.example.com/oauth2/authorize`)
3. **Token Endpoint** (e.g., `https://idp.example.com/oauth2/token`)
4. **UserInfo Endpoint** (e.g., `https://idp.example.com/oauth2/userinfo`)
5. **Client ID** (from your IdP application)
6. **Client Secret** (from your IdP application)

> **Tip**: Most OIDC providers expose a discovery document at `/.well-known/openid-configuration` that contains all endpoints.

#### Step 2: Configure Application in IdP

In your IdP's admin console:

1. Create a new application/client
2. Set application type to **Web Application** or **Confidential Client**
3. Add redirect URI: `https://your-domain.com/oauth2/callback`
4. Copy Client ID and Client Secret

#### Step 3: Run Setup Script

```bash
sudo bash scripts/setup-idp.sh
```

When prompted:
- Select option `6` (Generic OIDC)
- Enter all required URLs
- Enter Client ID
- Enter Client Secret

---

## Testing Authentication

After configuration, test your authentication setup:

### 1. Check Services Status

```bash
# Verify OAuth2 Proxy is running
sudo systemctl status oauth2-proxy

# Verify OpenCode is running
sudo systemctl status opencode

# Verify Nginx is running
sudo systemctl status nginx
```

### 2. Check Logs

```bash
# OAuth2 Proxy logs
sudo journalctl -u oauth2-proxy -f

# OpenCode logs
sudo journalctl -u opencode -f

# Nginx logs
sudo tail -f /var/log/nginx/opencode-error.log
```

### 3. Test Login Flow

1. Open your browser (preferably in incognito mode)
2. Navigate to `https://your-domain.com`
3. You should be redirected to your IdP's login page
4. Enter credentials
5. You should be redirected back to OpenCode

### 4. Verify Headers

After successful authentication, check that user information is passed:

```bash
# From within OpenCode, check for headers:
# X-User: username
# X-Email: user@example.com
# Authorization: Bearer <token>
```

### 5. Test Logout

1. Navigate to `https://your-domain.com/oauth2/sign_out`
2. You should be logged out
3. Accessing `https://your-domain.com` should redirect to login again

## Troubleshooting

### Common Issues

#### Issue: Redirect Loop

**Symptoms**: Browser keeps redirecting between IdP and application

**Causes**:
- Incorrect callback URL
- Cookie issues
- Session configuration problems

**Solutions**:
```bash
# Check OAuth2 Proxy logs
sudo journalctl -u oauth2-proxy -n 50

# Verify callback URL matches exactly in IdP
cat /opt/opencode/config/.env | grep CALLBACK

# Clear browser cookies
# Check cookie settings in OAuth2 Proxy config
cat /opt/opencode/config/oauth2-proxy.cfg | grep cookie
```

#### Issue: "Invalid Client" Error

**Symptoms**: IdP returns "invalid_client" error

**Causes**:
- Wrong Client ID
- Wrong Client Secret
- Client not enabled in IdP

**Solutions**:
```bash
# Verify credentials in config
sudo cat /opt/opencode/config/.env

# Re-run setup script
sudo bash scripts/setup-idp.sh

# Check IdP application is enabled
```

#### Issue: "Unauthorized" After Login

**Symptoms**: Successfully log in at IdP but get 401/403 from application

**Causes**:
- Email domain restriction
- Insufficient permissions
- Group/role requirements not met

**Solutions**:
```bash
# Check OAuth2 Proxy email domains setting
cat /opt/opencode/config/oauth2-proxy.cfg | grep email_domains

# Modify to allow all domains
echo 'email_domains = [ "*" ]' | sudo tee -a /opt/opencode/config/oauth2-proxy.cfg

# Restart OAuth2 Proxy
sudo systemctl restart oauth2-proxy
```

#### Issue: SSL/TLS Errors

**Symptoms**: Connection errors, certificate warnings

**Causes**:
- Certificate validation failures
- Mismatched domains
- Expired certificates

**Solutions**:
```bash
# Check certificate
sudo certbot certificates

# Verify SSL configuration
sudo nginx -t

# Check OAuth2 Proxy can reach IdP
sudo -u opencode curl -v https://your-idp.com

# For self-signed certs (testing only), disable validation
# Add to oauth2-proxy.cfg: ssl_insecure_skip_verify = true
```

#### Issue: Session Expired Too Quickly

**Symptoms**: Users need to re-authenticate frequently

**Causes**:
- Short session timeout
- Cookie expiration
- Token refresh issues

**Solutions**:
```bash
# Edit session timeout in .env
sudo nano /opt/opencode/config/.env

# Increase SESSION_MAX_AGE (in seconds)
# Example: 86400 = 24 hours
SESSION_MAX_AGE=86400

# Restart OAuth2 Proxy
sudo systemctl restart oauth2-proxy
```

### Debug Mode

Enable debug logging for more information:

```bash
# Enable debug logging in OAuth2 Proxy
sudo nano /opt/opencode/config/oauth2-proxy.cfg

# Add or modify:
# request_logging = true
# auth_logging = true
# standard_logging = true

# Restart service
sudo systemctl restart oauth2-proxy

# Watch logs
sudo journalctl -u oauth2-proxy -f
```

### Testing OIDC Discovery

Test your IdP's OIDC discovery endpoint:

```bash
# Replace with your IdP's issuer URL
curl https://your-idp.com/.well-known/openid-configuration | jq .

# Should return JSON with:
# - authorization_endpoint
# - token_endpoint
# - userinfo_endpoint
# - issuer
```

### Manual Token Testing

Test OAuth flow manually:

```bash
# 1. Get authorization code (in browser)
https://your-idp.com/authorize?
  client_id=YOUR_CLIENT_ID&
  redirect_uri=https://your-domain.com/oauth2/callback&
  response_type=code&
  scope=openid%20profile%20email

# 2. Exchange code for token (replace values)
curl -X POST https://your-idp.com/token \
  -d "grant_type=authorization_code" \
  -d "code=AUTHORIZATION_CODE" \
  -d "client_id=YOUR_CLIENT_ID" \
  -d "client_secret=YOUR_CLIENT_SECRET" \
  -d "redirect_uri=https://your-domain.com/oauth2/callback"

# 3. Get user info (replace ACCESS_TOKEN)
curl -H "Authorization: Bearer ACCESS_TOKEN" \
  https://your-idp.com/userinfo
```

## Advanced Configuration

### Email Domain Restrictions

Restrict access to specific email domains:

```bash
sudo nano /opt/opencode/config/oauth2-proxy.cfg

# Restrict to specific domains
email_domains = [ "example.com", "company.com" ]

# Or allow all
email_domains = [ "*" ]
```

### Group/Role-Based Access

Require specific groups or roles:

```bash
sudo nano /opt/opencode/config/oauth2-proxy.cfg

# Azure AD groups
azure_groups = [ "OpenCode-Users" ]

# Google groups
google_groups = [ "opencode@example.com" ]

# Generic OIDC groups claim
oidc_groups_claim = "groups"
allowed_groups = [ "opencode-users" ]
```

### Custom Session Storage

Use Redis for session storage (for multiple instances):

```bash
# Install Redis
sudo apt install redis-server

# Configure OAuth2 Proxy
sudo nano /opt/opencode/config/oauth2-proxy.cfg

# Add:
session_store_type = "redis"
redis_connection_url = "redis://localhost:6379"
```

## Next Steps

After successful IdP setup:

1. ✅ Configure user groups and roles in your IdP
2. ✅ Set up Multi-Factor Authentication (MFA) in your IdP
3. ✅ Review and adjust session timeouts
4. ✅ Configure monitoring and alerting
5. ✅ Test failover scenarios
6. ✅ Document your configuration for your team

## Additional Resources

- [OAuth2 Proxy Documentation](https://oauth2-proxy.github.io/oauth2-proxy/)
- [OpenID Connect Specification](https://openid.net/connect/)
- [OAuth 2.0 Specification](https://oauth.net/2/)

## Support

If you need help with IdP setup:

1. Check provider-specific guides in `docs/providers/`
2. Review [Troubleshooting](TROUBLESHOOTING.md)
3. Open an issue on GitHub
4. Contact support

---

**Last Updated**: November 2025
