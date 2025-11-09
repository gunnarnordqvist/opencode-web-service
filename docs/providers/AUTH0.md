# Auth0 Integration Guide

Complete guide for integrating OpenCode Web Service with Auth0.

## Overview

Auth0 is a flexible, drop-in solution for adding authentication and authorization services to your applications. This guide walks you through setting up Auth0 as your Identity Provider for OpenCode Web Service.

## Prerequisites

- ✅ OpenCode Web Service installed
- ✅ Auth0 account (free tier available at [auth0.com](https://auth0.com))
- ✅ Domain name with SSL configured

## Step-by-Step Setup

### 1. Create Auth0 Account

1. Go to [auth0.com](https://auth0.com)
2. Click **Sign Up** (or **Log In** if you have an account)
3. Choose your region (US, EU, AU)
4. Complete the registration process

### 2. Create a Tenant

If you're new to Auth0:

1. You'll be prompted to create a tenant
2. Choose a **Tenant Domain** (e.g., `mycompany.auth0.com` or `mycompany.eu.auth0.com`)
3. Select **Region** closest to your users
4. Click **Create**

### 3. Create an Application

1. In the Auth0 Dashboard, go to **Applications** → **Applications**
2. Click **Create Application**
3. Enter:
   - **Name**: `OpenCode Web Service`
   - **Application Type**: `Regular Web Applications`
4. Click **Create**

### 4. Configure Application Settings

In your application settings:

#### Basic Information

- **Name**: OpenCode Web Service
- **Description**: Authentication for OpenCode Web Service
- **Application Logo**: (optional) Upload a logo

#### Application URIs

Configure these URLs (replace `your-domain.com` with your actual domain):

- **Application Login URI**: `https://your-domain.com`
- **Allowed Callback URLs**: 
  ```
  https://your-domain.com/oauth2/callback
  ```
- **Allowed Logout URLs**:
  ```
  https://your-domain.com/
  ```
- **Allowed Web Origins**:
  ```
  https://your-domain.com
  ```
- **Allowed Origins (CORS)**:
  ```
  https://your-domain.com
  ```

#### Application Properties

Copy these values for later use:

- **Domain**: (e.g., `your-tenant.auth0.com` or `your-tenant.eu.auth0.com`)
- **Client ID**: (e.g., `AbC123dEf456GhI789JkL012`)
- **Client Secret**: Click **Show** to reveal, then copy

#### Application Metadata (Optional)

You can add custom metadata if needed.

#### Advanced Settings

- **OAuth** tab:
  - **JsonWebToken Signature Algorithm**: `RS256` (default, recommended)
  - **OIDC Conformant**: `Enabled` (should be enabled by default)
- **Grant Types**:
  - Ensure `Authorization Code` is checked
  - Ensure `Refresh Token` is checked (for longer sessions)

Click **Save Changes**

### 5. Configure Connections

Auth0 supports multiple authentication methods (connections):

#### Database Connections (Username/Password)

1. Go to **Authentication** → **Database**
2. You should see a default `Username-Password-Authentication` connection
3. To customize:
   - Click on the connection name
   - Configure password policies
   - Enable/disable sign-ups
   - Customize login/signup pages

#### Social Connections

To add social login (Google, GitHub, etc.):

1. Go to **Authentication** → **Social**
2. Click on the desired provider (e.g., **Google**)
3. Enter provider-specific credentials:
   - **Client ID** from provider
   - **Client Secret** from provider
4. Configure **Permissions/Scopes**
5. Save

#### Enterprise Connections

For enterprise SSO (SAML, AD/LDAP, etc.):

1. Go to **Authentication** → **Enterprise**
2. Select connection type (e.g., **SAMLP**, **Active Directory/LDAP**)
3. Configure according to provider requirements

#### Enable Connections for Your Application

1. Go to **Applications** → **Applications** → **OpenCode Web Service**
2. Click **Connections** tab
3. Enable desired connections:
   - `Username-Password-Authentication` (enabled by default)
   - Social connections
   - Enterprise connections

### 6. Configure Users

#### Create Test User

1. Go to **User Management** → **Users**
2. Click **Create User**
3. Fill in:
   - **Email**: Test user email
   - **Password**: Secure password
   - **Connection**: Select connection (e.g., `Username-Password-Authentication`)
4. Click **Create**

#### Import Existing Users (Optional)

1. Go to **User Management** → **Users**
2. Click **Create User** → **Bulk Import**
3. Follow the import wizard

### 7. Run OpenCode IdP Setup Script

Now configure OpenCode to use Auth0:

```bash
sudo bash /home/gunnar/github/opencode-web-service/scripts/setup-idp.sh
```

When prompted:

1. **Select your Identity Provider**: Enter `1` for Auth0
2. **Enter Auth0 Domain**: Enter your tenant domain (e.g., `your-tenant.auth0.com`)
3. **Enter Auth0 Client ID**: Paste the Client ID from step 4
4. **Enter Auth0 Client Secret**: Paste the Client Secret from step 4
5. **Enter Auth0 Audience** (optional): 
   - Leave blank if not using Auth0 APIs
   - Or enter your API identifier if you have one

The script will:
- Install OAuth2 Proxy
- Configure Auth0 integration
- Update Nginx configuration
- Start all services

### 8. Verify Configuration

Check that all services are running:

```bash
# Check OAuth2 Proxy
sudo systemctl status oauth2-proxy

# Check OpenCode
sudo systemctl status opencode

# Check Nginx
sudo systemctl status nginx
```

View logs:

```bash
# OAuth2 Proxy logs
sudo journalctl -u oauth2-proxy -f

# OpenCode logs
sudo journalctl -u opencode -f
```

### 9. Test Authentication

1. Open your browser (incognito mode recommended)
2. Navigate to `https://your-domain.com`
3. You should be redirected to Auth0 login page
4. Enter your test user credentials
5. After successful login, you should be redirected back to OpenCode
6. Verify you can access the application

## Advanced Configuration

### Customize Login Page

Auth0 provides a customizable Universal Login page:

1. Go to **Branding** → **Universal Login**
2. Choose **Classic** or **New** experience
3. Click **Customize Login Page**
4. Modify HTML/CSS/JavaScript as needed
5. Save changes

### Add Multi-Factor Authentication (MFA)

1. Go to **Security** → **Multi-factor Auth**
2. Click **Enable** on desired factors:
   - **One-time Password** (Google Authenticator, Authy)
   - **SMS**
   - **Email**
   - **Push via Guardian**
3. Configure policies:
   - **Always**: Require for all users
   - **Adaptive**: Require based on risk assessment
   - **Never**: Optional
4. Save

### Configure Rules (Legacy) or Actions

Rules/Actions allow you to customize authentication flow:

#### Using Actions (Recommended)

1. Go to **Actions** → **Flows**
2. Select **Login** flow
3. Click **Custom** tab → **Create Action**
4. Add custom logic (JavaScript):

```javascript
exports.onExecutePostLogin = async (event, api) => {
  // Add custom claims
  api.idToken.setCustomClaim('https://your-domain.com/roles', event.authorization?.roles);
  
  // Add user metadata
  api.idToken.setCustomClaim('https://your-domain.com/user_metadata', event.user.user_metadata);
};
```

5. Save and add to Login flow

### Email Templates

Customize email templates:

1. Go to **Branding** → **Email Templates**
2. Select template type:
   - Welcome Email
   - Verification Email
   - Change Password
   - Blocked Account Email
   - etc.
3. Customize template
4. Save

### Rate Limiting

Configure rate limiting to prevent brute force attacks:

1. Go to **Security** → **Attack Protection**
2. Configure:
   - **Brute Force Protection**: Blocks repeated failed login attempts
   - **Suspicious IP Throttling**: Throttles requests from suspicious IPs
   - **Breached Password Detection**: Prevents use of compromised passwords

## Monitoring and Logs

### View Logs

1. Go to **Monitoring** → **Logs**
2. Filter by:
   - **Type**: Success Login, Failed Login, etc.
   - **User**
   - **Connection**
   - **Date Range**
3. Click on individual logs for details

### Export Logs

For long-term storage:

1. Go to **Monitoring** → **Streams**
2. Create a stream to:
   - Datadog
   - Splunk
   - Sumo Logic
   - AWS EventBridge
   - Custom webhook

### Set Up Alerts

Configure email alerts:

1. Go to **Monitoring** → **Logs**
2. Click **Create Alert**
3. Configure conditions and recipients
4. Save

## Troubleshooting

### Common Issues

#### Issue: "Callback URL mismatch"

**Error**: `The redirect URI is wrong. You sent https://your-domain.com/oauth2/callback, and we expected...`

**Solution**:
1. Go to Auth0 Application settings
2. Verify **Allowed Callback URLs** exactly matches:
   ```
   https://your-domain.com/oauth2/callback
   ```
3. No trailing slashes
4. Correct protocol (https)
5. Save changes

#### Issue: "Invalid Client"

**Error**: `Invalid client or client credentials`

**Solution**:
1. Verify Client ID and Client Secret are correct
2. Check configuration file:
   ```bash
   sudo cat /opt/opencode/config/.env | grep AUTH0
   ```
3. Re-run setup script if needed

#### Issue: "Access Denied"

**Error**: User logs in successfully but gets access denied

**Solution**:
1. Check email domain restrictions in OAuth2 Proxy:
   ```bash
   cat /opt/opencode/config/oauth2-proxy.cfg | grep email_domains
   ```
2. Change to allow all domains:
   ```
   email_domains = [ "*" ]
   ```
3. Restart OAuth2 Proxy:
   ```bash
   sudo systemctl restart oauth2-proxy
   ```

#### Issue: Session Expires Too Quickly

**Solution**:
1. Increase session timeout in Auth0:
   - Go to **Applications** → **OpenCode Web Service** → **Settings**
   - Find **Inactivity timeout** and **Require log in after**
   - Adjust values
2. Increase session timeout in OpenCode:
   ```bash
   sudo nano /opt/opencode/config/.env
   # Change: SESSION_MAX_AGE=86400  (24 hours in seconds)
   ```
3. Restart services:
   ```bash
   sudo systemctl restart oauth2-proxy
   ```

### Debug Mode

Enable debug logging:

```bash
# Enable Auth0 debug logs in OAuth2 Proxy
sudo nano /opt/opencode/config/oauth2-proxy.cfg

# Add:
request_logging = true
auth_logging = true

# Restart
sudo systemctl restart oauth2-proxy

# View logs
sudo journalctl -u oauth2-proxy -f
```

## Security Best Practices

1. **Enable MFA**: Always enable multi-factor authentication for enhanced security
2. **Use Strong Passwords**: Enforce strong password policies in database connections
3. **Regular Audits**: Review logs regularly for suspicious activity
4. **Update Dependencies**: Keep Auth0 tenant and OpenCode updated
5. **Least Privilege**: Grant minimum necessary permissions to users
6. **Backup Configuration**: Document and backup your Auth0 configuration
7. **Monitor Anomalies**: Set up alerts for unusual login patterns
8. **Rotate Secrets**: Periodically rotate Client Secrets

## Additional Resources

- [Auth0 Documentation](https://auth0.com/docs)
- [Auth0 Community](https://community.auth0.com/)
- [Auth0 Blog](https://auth0.com/blog/)
- [OAuth2 Proxy Documentation](https://oauth2-proxy.github.io/oauth2-proxy/)

## Support

For Auth0-specific issues:
- [Auth0 Support Center](https://support.auth0.com/)
- [Auth0 Community Forum](https://community.auth0.com/)

For OpenCode Web Service issues:
- [GitHub Issues](https://github.com/yourusername/opencode-web-service/issues)
- [Documentation](../IDP_SETUP.md)

---

**Last Updated**: November 2025
