# SSL/TLS Certificate Management Guide

This guide covers SSL/TLS certificate management for your OpenCode Web Service installation using Let's Encrypt.

## Table of Contents

- [Overview](#overview)
- [Initial Certificate Setup](#initial-certificate-setup)
- [Certificate Renewal](#certificate-renewal)
- [Certificate Verification](#certificate-verification)
- [Troubleshooting](#troubleshooting)
- [Advanced Configuration](#advanced-configuration)
- [Best Practices](#best-practices)

## Overview

OpenCode Web Service uses [Let's Encrypt](https://letsencrypt.org/) to provide free, automated SSL/TLS certificates through [Certbot](https://certbot.eff.org/).

### Key Features

- ✅ **Free Certificates**: No cost for SSL/TLS certificates
- ✅ **Automatic Renewal**: Certificates renew automatically before expiration
- ✅ **Domain Validation**: DV (Domain Validated) certificates
- ✅ **Wildcard Support**: Available for wildcard domains
- ✅ **90-Day Validity**: Certificates valid for 90 days, auto-renewed at 60 days

### Certificate Details

- **Certificate Authority**: Let's Encrypt
- **Validation Method**: HTTP-01 or DNS-01 challenge
- **Key Type**: RSA 2048-bit or ECDSA P-256
- **Validity Period**: 90 days
- **Renewal Window**: 30 days before expiration
- **Rate Limits**: 50 certificates per registered domain per week

## Initial Certificate Setup

### Automatic Setup (Recommended)

During installation, certificates are obtained automatically:

```bash
sudo bash scripts/install.sh
```

The installation script:
1. Installs Certbot
2. Configures Nginx for HTTP-01 challenge
3. Obtains certificate for your domain
4. Configures Nginx for HTTPS
5. Sets up automatic renewal

### Manual Certificate Obtainment

If you need to manually obtain a certificate:

```bash
# Stop Nginx (if running)
sudo systemctl stop nginx

# Obtain certificate using standalone mode
sudo certbot certonly --standalone \
  -d your-domain.com \
  -d www.your-domain.com \
  --non-interactive \
  --agree-tos \
  -m admin@your-domain.com

# Start Nginx
sudo systemctl start nginx
```

Or use Nginx plugin (recommended):

```bash
# With Nginx running
sudo certbot --nginx \
  -d your-domain.com \
  -d www.your-domain.com \
  --non-interactive \
  --agree-tos \
  -m admin@your-domain.com
```

### Wildcard Certificates

For wildcard certificates, use DNS-01 challenge:

```bash
# Install DNS plugin (example for Cloudflare)
sudo apt install python3-certbot-dns-cloudflare

# Create Cloudflare credentials file
sudo nano /root/.secrets/cloudflare.ini

# Add content:
# dns_cloudflare_api_token = YOUR_API_TOKEN

# Secure the file
sudo chmod 600 /root/.secrets/cloudflare.ini

# Obtain wildcard certificate
sudo certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials /root/.secrets/cloudflare.ini \
  -d your-domain.com \
  -d *.your-domain.com \
  --non-interactive \
  --agree-tos \
  -m admin@your-domain.com
```

DNS plugins available for:
- Cloudflare: `python3-certbot-dns-cloudflare`
- Route53: `python3-certbot-dns-route53`
- Google Cloud DNS: `python3-certbot-dns-google`
- And many more...

## Certificate Renewal

### Automatic Renewal

Certbot automatically creates a systemd timer for renewal:

```bash
# Check renewal timer status
sudo systemctl status certbot.timer

# View renewal timer details
sudo systemctl list-timers certbot.timer
```

The timer runs twice daily and renews certificates within 30 days of expiration.

### Manual Renewal

Test renewal process (dry run):

```bash
# Test renewal without actually renewing
sudo certbot renew --dry-run
```

Force certificate renewal:

```bash
# Renew all certificates
sudo certbot renew

# Renew specific certificate
sudo certbot renew --cert-name your-domain.com

# Force renewal even if not expiring soon
sudo certbot renew --force-renewal
```

### Renewal Hooks

Add custom scripts to run before/after renewal:

```bash
# Create pre-hook script (runs before renewal)
sudo nano /etc/letsencrypt/renewal-hooks/pre/01-pre-renewal.sh

#!/bin/bash
# Example: Notify monitoring system
echo "Starting certificate renewal at $(date)" >> /var/log/cert-renewal.log

# Make executable
sudo chmod +x /etc/letsencrypt/renewal-hooks/pre/01-pre-renewal.sh

# Create post-hook script (runs after successful renewal)
sudo nano /etc/letsencrypt/renewal-hooks/post/01-post-renewal.sh

#!/bin/bash
# Reload services
systemctl reload nginx
systemctl restart oauth2-proxy
# Send notification
echo "Certificate renewed successfully at $(date)" >> /var/log/cert-renewal.log

# Make executable
sudo chmod +x /etc/letsencrypt/renewal-hooks/post/01-post-renewal.sh
```

## Certificate Verification

### Check Certificate Status

```bash
# List all certificates
sudo certbot certificates

# Output example:
# Found the following certs:
#   Certificate Name: your-domain.com
#     Domains: your-domain.com
#     Expiry Date: 2024-02-15 12:00:00+00:00 (VALID: 30 days)
#     Certificate Path: /etc/letsencrypt/live/your-domain.com/fullchain.pem
#     Private Key Path: /etc/letsencrypt/live/your-domain.com/privkey.pem
```

### Check Certificate Details

```bash
# View certificate details
sudo openssl x509 -in /etc/letsencrypt/live/your-domain.com/fullchain.pem -noout -text

# Check expiration date
sudo openssl x509 -in /etc/letsencrypt/live/your-domain.com/fullchain.pem -noout -dates

# Verify certificate chain
sudo openssl verify -CAfile /etc/letsencrypt/live/your-domain.com/chain.pem \
  /etc/letsencrypt/live/your-domain.com/cert.pem
```

### Test SSL Configuration

```bash
# Test SSL connection
openssl s_client -connect your-domain.com:443 -servername your-domain.com

# Test with specific TLS version
openssl s_client -connect your-domain.com:443 -tls1_2
openssl s_client -connect your-domain.com:443 -tls1_3
```

### Online SSL Testing

Use online tools for comprehensive SSL testing:

1. **SSL Labs Server Test**
   - URL: https://www.ssllabs.com/ssltest/
   - Enter your domain and analyze
   - Aim for A+ rating

2. **Mozilla Observatory**
   - URL: https://observatory.mozilla.org/
   - Comprehensive security analysis
   - Includes headers, certificates, and more

3. **Security Headers**
   - URL: https://securityheaders.com/
   - Check security headers configuration

## Troubleshooting

### Common Issues

#### Issue 1: Certificate Renewal Fails

**Error**: "Failed to renew certificate"

**Diagnosis**:
```bash
# Check renewal logs
sudo tail -f /var/log/letsencrypt/letsencrypt.log

# Test renewal with verbose output
sudo certbot renew --dry-run --verbose
```

**Common Causes and Solutions**:

1. **Port 80 blocked**
   ```bash
   # Check if port 80 is accessible
   sudo netstat -tlnp | grep :80
   
   # Test from external location
   curl -I http://your-domain.com/.well-known/acme-challenge/test
   ```

2. **Nginx misconfiguration**
   ```bash
   # Test Nginx configuration
   sudo nginx -t
   
   # Check ACME challenge location
   cat /etc/nginx/sites-available/opencode | grep acme-challenge
   ```

3. **DNS not resolving**
   ```bash
   # Check DNS resolution
   nslookup your-domain.com
   dig your-domain.com
   ```

4. **Rate limits reached**
   - Wait for rate limit window to reset
   - Use staging environment for testing:
   ```bash
   sudo certbot renew --dry-run --staging
   ```

#### Issue 2: Certificate Chain Issues

**Error**: "unable to get local issuer certificate"

**Solution**:
```bash
# Download Let's Encrypt intermediate certificates
sudo wget -O /etc/ssl/certs/lets-encrypt-r3.pem \
  https://letsencrypt.org/certs/lets-encrypt-r3.pem

# Update certificate configuration in Nginx
sudo nano /etc/nginx/sites-available/opencode

# Ensure these lines exist:
ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
ssl_trusted_certificate /etc/letsencrypt/live/your-domain.com/chain.pem;

# Reload Nginx
sudo systemctl reload nginx
```

#### Issue 3: Mixed Content Warnings

**Problem**: Some resources load over HTTP instead of HTTPS

**Solution**:
```bash
# Force HTTPS redirect in Nginx
sudo nano /etc/nginx/sites-available/opencode

# Ensure HTTP server block redirects to HTTPS:
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

# Add HSTS header (already in template):
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

# Reload Nginx
sudo systemctl reload nginx
```

#### Issue 4: Certificate Not Updating

**Problem**: Renewal succeeds but old certificate still in use

**Solution**:
```bash
# Check certificate file dates
sudo ls -la /etc/letsencrypt/live/your-domain.com/

# Verify Nginx is using correct certificate
sudo nginx -T | grep ssl_certificate

# Reload Nginx to use new certificate
sudo systemctl reload nginx

# If reload doesn't work, restart
sudo systemctl restart nginx

# Verify new certificate is in use
echo | openssl s_client -connect your-domain.com:443 2>/dev/null | openssl x509 -noout -dates
```

### Certificate Revocation

If you need to revoke a certificate (e.g., private key compromised):

```bash
# Revoke certificate
sudo certbot revoke --cert-path /etc/letsencrypt/live/your-domain.com/cert.pem

# Revoke and delete
sudo certbot revoke --cert-path /etc/letsencrypt/live/your-domain.com/cert.pem --delete-after-revoke

# Obtain new certificate
sudo certbot --nginx -d your-domain.com
```

## Advanced Configuration

### Multiple Domains

Add multiple domains to one certificate:

```bash
sudo certbot --nginx \
  -d domain1.com \
  -d www.domain1.com \
  -d domain2.com \
  -d www.domain2.com
```

### Separate Certificates per Domain

Obtain separate certificates:

```bash
# First domain
sudo certbot --nginx -d domain1.com -d www.domain1.com

# Second domain
sudo certbot --nginx -d domain2.com -d www.domain2.com
```

### ECDSA Certificates

Use ECDSA instead of RSA (smaller, faster):

```bash
sudo certbot certonly \
  --nginx \
  -d your-domain.com \
  --key-type ecdsa \
  --elliptic-curve secp384r1
```

### Certificate Backup

Backup your certificates:

```bash
# Create backup directory
sudo mkdir -p /backup/letsencrypt

# Backup certificates
sudo tar -czf /backup/letsencrypt/letsencrypt-backup-$(date +%Y%m%d).tar.gz \
  /etc/letsencrypt

# Automated backup script
sudo nano /usr/local/bin/backup-certificates.sh

#!/bin/bash
BACKUP_DIR="/backup/letsencrypt"
DATE=$(date +%Y%m%d)
mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/letsencrypt-$DATE.tar.gz /etc/letsencrypt
# Keep only last 30 days
find $BACKUP_DIR -name "letsencrypt-*.tar.gz" -mtime +30 -delete

# Make executable
sudo chmod +x /usr/local/bin/backup-certificates.sh

# Add to cron (daily at 2 AM)
echo "0 2 * * * /usr/local/bin/backup-certificates.sh" | sudo crontab -
```

### Certificate Restoration

Restore from backup:

```bash
# Stop services
sudo systemctl stop nginx

# Restore certificates
sudo tar -xzf /backup/letsencrypt/letsencrypt-backup-YYYYMMDD.tar.gz -C /

# Start services
sudo systemctl start nginx
```

### Using Alternative CA

Use Let's Encrypt staging environment for testing:

```bash
sudo certbot --nginx \
  --staging \
  -d your-domain.com
```

## Best Practices

### 1. Monitor Certificate Expiration

Set up monitoring alerts:

```bash
# Create monitoring script
sudo nano /usr/local/bin/check-cert-expiry.sh

#!/bin/bash
DOMAIN="your-domain.com"
DAYS_WARN=14

EXPIRY=$(echo | openssl s_client -connect $DOMAIN:443 -servername $DOMAIN 2>/dev/null | \
  openssl x509 -noout -enddate | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_EPOCH - $NOW_EPOCH) / 86400 ))

if [ $DAYS_LEFT -lt $DAYS_WARN ]; then
  echo "WARNING: Certificate for $DOMAIN expires in $DAYS_LEFT days!"
  # Send alert (email, Slack, etc.)
fi

# Make executable
sudo chmod +x /usr/local/bin/check-cert-expiry.sh

# Add to cron (daily)
echo "0 6 * * * /usr/local/bin/check-cert-expiry.sh" | sudo crontab -
```

### 2. Test Renewal Regularly

```bash
# Test renewal monthly
0 3 1 * * certbot renew --dry-run
```

### 3. Keep Certbot Updated

```bash
# Update Certbot
sudo apt update && sudo apt upgrade certbot python3-certbot-nginx
```

### 4. Enable OCSP Stapling

Already configured in the template:

```nginx
ssl_stapling on;
ssl_stapling_verify on;
ssl_trusted_certificate /etc/letsencrypt/live/your-domain.com/chain.pem;
resolver 8.8.8.8 8.8.4.4 valid=300s;
```

### 5. Use Strong DH Parameters

```bash
# Generate DH parameters (takes several minutes)
sudo openssl dhparam -out /etc/nginx/dhparam.pem 4096

# Add to Nginx config
sudo nano /etc/nginx/sites-available/opencode

# Add this line in the HTTPS server block:
ssl_dhparam /etc/nginx/dhparam.pem;

# Reload Nginx
sudo systemctl reload nginx
```

### 6. Implement Certificate Pinning (Optional)

For high-security environments:

```nginx
# Add to Nginx HTTPS server block
add_header Public-Key-Pins 'pin-sha256="base64+primary=="; pin-sha256="base64+backup=="; max-age=5184000;';
```

Generate pins:

```bash
# Get current certificate pin
openssl x509 -in /etc/letsencrypt/live/your-domain.com/cert.pem -pubkey -noout | \
  openssl pkey -pubin -outform der | \
  openssl dgst -sha256 -binary | base64
```

### 7. Document Your Configuration

Keep a record of:
- Domain names covered
- Certificate type (RSA/ECDSA)
- Renewal method
- DNS configuration
- Contact email
- Backup schedule

## Automation Scripts

### Complete Renewal and Notification Script

```bash
sudo nano /usr/local/bin/renew-certificates.sh

#!/bin/bash
# Certificate Renewal and Notification Script

LOG_FILE="/var/log/cert-renewal.log"
EMAIL="admin@your-domain.com"

echo "=== Certificate Renewal Started: $(date) ===" >> $LOG_FILE

# Test renewal
certbot renew --dry-run >> $LOG_FILE 2>&1

if [ $? -eq 0 ]; then
    echo "Dry run successful, proceeding with actual renewal" >> $LOG_FILE
    
    # Actual renewal
    certbot renew >> $LOG_FILE 2>&1
    
    if [ $? -eq 0 ]; then
        echo "Certificate renewal successful" >> $LOG_FILE
        
        # Reload services
        systemctl reload nginx
        systemctl restart oauth2-proxy
        
        # Send success notification
        echo "Certificate renewal successful at $(date)" | \
          mail -s "Certificate Renewal Success" $EMAIL
    else
        echo "Certificate renewal failed" >> $LOG_FILE
        
        # Send failure notification
        echo "Certificate renewal failed at $(date). Check logs." | \
          mail -s "Certificate Renewal FAILED" $EMAIL
    fi
else
    echo "Dry run failed, skipping renewal" >> $LOG_FILE
    
    # Send warning
    echo "Certificate renewal dry run failed at $(date). Check configuration." | \
      mail -s "Certificate Renewal Dry Run Failed" $EMAIL
fi

echo "=== Certificate Renewal Completed: $(date) ===" >> $LOG_FILE

# Make executable
sudo chmod +x /usr/local/bin/renew-certificates.sh
```

## Additional Resources

- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Certbot Documentation](https://certbot.eff.org/docs/)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)
- [SSL Labs Best Practices](https://github.com/ssllabs/research/wiki/SSL-and-TLS-Deployment-Best-Practices)

## Support

For SSL/TLS certificate issues:

1. Check [Troubleshooting](TROUBLESHOOTING.md)
2. Review Let's Encrypt community forum
3. Open a GitHub issue
4. Contact support

---

**Last Updated**: November 2025
