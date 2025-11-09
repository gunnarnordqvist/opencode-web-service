# OpenCode Web Service - Demo Installation Guide

Detta dokument visar hur installationen fungerar och vad du kan förvänta dig.

## Lokal Testinstallation (utan SSL)

### Förutsättningar

```bash
# Kontrollera att du har Ubuntu/Debian
cat /etc/os-release

# Du behöver sudo-rättigheter
sudo -v
```

### Installation Steg-för-Steg

#### Steg 1: Kör installationsskriptet

```bash
cd /home/gunnar/github/opencode-web-service
sudo bash scripts/install-local-test.sh
```

#### Steg 2: Vad händer under installationen

```
========================================================================
   OpenCode Web Service - LOCAL TEST INSTALLATION
   HTTP only (no SSL) - For development/testing
========================================================================

[INFO] Detected OS: ubuntu 24.04
[INFO] Installing dependencies...
[SUCCESS] Dependencies installed

[INFO] Creating OpenCode service user...
[SUCCESS] User opencode created

[INFO] Creating test OpenCode application...
[SUCCESS] Test application created

[INFO] Configuring systemd service...
[SUCCESS] Systemd service configured

[INFO] Configuring Nginx for local testing...
[SUCCESS] Nginx configured (HTTP only on port 8080)

[INFO] Setting up log rotation...
[SUCCESS] Log rotation configured

[INFO] Starting services...
[SUCCESS] Services started

[INFO] Testing installation...
[SUCCESS] OpenCode service is running
[SUCCESS] OpenCode app responds on port 3000
[SUCCESS] Nginx proxy working on port 8080
```

### Vad Installeras

#### 1. Systemanvändare
```bash
# Ny användare skapas
User: opencode
Home: /opt/opencode
Shell: /bin/bash
```

#### 2. Katalogstruktur
```
/opt/opencode/
├── app/
│   └── server.js          # Node.js test-applikation
├── config/                # Konfigurationsfiler
├── logs/                  # Loggfiler
│   ├── opencode.log
│   └── opencode.error.log
└── data/                  # Applikationsdata
```

#### 3. Systemd-tjänst
```bash
# Service file: /etc/systemd/system/opencode.service

[Unit]
Description=OpenCode Web Service (Test)
After=network.target

[Service]
Type=simple
User=opencode
WorkingDirectory=/opt/opencode/app
Environment="PORT=3000"
ExecStart=/usr/bin/node /opt/opencode/app/server.js
Restart=always

[Install]
WantedBy=multi-user.target
```

#### 4. Nginx-konfiguration
```nginx
# Config file: /etc/nginx/sites-available/opencode-test

upstream opencode_backend {
    server 127.0.0.1:3000;
}

server {
    listen 8080;
    server_name localhost;
    
    location / {
        proxy_pass http://opencode_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /health {
        proxy_pass http://opencode_backend;
    }
}
```

#### 5. Test-applikation (Node.js)
```javascript
// /opt/opencode/app/server.js

const http = require('http');
const port = 3000;

const server = http.createServer((req, res) => {
  const response = {
    message: 'OpenCode Web Service - Test Installation',
    status: 'running',
    timestamp: new Date().toISOString(),
    path: req.url,
    method: req.method
  };
  
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'healthy' }));
    return;
  }
  
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(response, null, 2));
});

server.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
```

### Efter Installation

#### Slutresultat
```
========================================================================
OpenCode Web Service TEST installation completed!
========================================================================

Installation Details:
  - OpenCode User: opencode
  - OpenCode Home: /opt/opencode
  - OpenCode Port: 3000
  - Nginx Port: 8080 (HTTP only)

Test URLs:
  - Direct app: http://localhost:3000
  - Via Nginx:  http://localhost:8080
  - Health:     http://localhost:8080/health

Service Management:
  - Start:   sudo systemctl start opencode
  - Stop:    sudo systemctl stop opencode
  - Restart: sudo systemctl restart opencode
  - Status:  sudo systemctl status opencode
  - Logs:    sudo journalctl -u opencode -f

========================================================================
```

### Testa Installationen

#### 1. Testa direkt mot applikationen
```bash
curl http://localhost:3000

# Förväntat svar:
{
  "message": "OpenCode Web Service - Test Installation",
  "status": "running",
  "timestamp": "2025-11-09T...",
  "path": "/",
  "method": "GET"
}
```

#### 2. Testa via Nginx proxy
```bash
curl http://localhost:8080

# Samma svar som ovan
```

#### 3. Testa health check
```bash
curl http://localhost:8080/health

# Förväntat svar:
{
  "status": "healthy"
}
```

#### 4. Kontrollera tjänststatus
```bash
# Kontrollera OpenCode-tjänsten
sudo systemctl status opencode

# Förväntat:
● opencode.service - OpenCode Web Service (Test)
     Loaded: loaded (/etc/systemd/system/opencode.service; enabled)
     Active: active (running) since ...
   Main PID: ...
      Tasks: 11
     Memory: ...
```

#### 5. Se loggar i realtid
```bash
# Systemd-loggar
sudo journalctl -u opencode -f

# Fil-loggar
sudo tail -f /opt/opencode/logs/opencode.log
```

#### 6. Testa från webbläsare
Öppna webbläsare och gå till:
- http://localhost:8080
- http://localhost:8080/health

Du bör se JSON-svar från applikationen.

### Service Management

#### Starta tjänsten
```bash
sudo systemctl start opencode
```

#### Stoppa tjänsten
```bash
sudo systemctl stop opencode
```

#### Starta om tjänsten
```bash
sudo systemctl restart opencode
```

#### Kontrollera status
```bash
sudo systemctl status opencode
```

#### Aktivera auto-start vid boot
```bash
sudo systemctl enable opencode
```

#### Inaktivera auto-start
```bash
sudo systemctl disable opencode
```

### Felsökning

#### Tjänsten startar inte

```bash
# Se detaljerade loggar
sudo journalctl -u opencode -n 50 --no-pager

# Kontrollera om port 3000 redan används
sudo netstat -tlnp | grep :3000

# Kontrollera filrättigheter
sudo ls -la /opt/opencode/app/
```

#### Nginx-fel

```bash
# Testa Nginx-konfiguration
sudo nginx -t

# Se Nginx-felloggar
sudo tail -f /var/log/nginx/opencode-error.log

# Kontrollera om port 8080 är ledig
sudo netstat -tlnp | grep :8080
```

#### Applikationen svarar inte

```bash
# Kontrollera att Node.js är installerat
node --version

# Testa applikationen manuellt
cd /opt/opencode/app
node server.js

# Testa direkt mot port 3000
curl http://localhost:3000
```

### Avinstallera

```bash
# Stoppa och inaktivera tjänsten
sudo systemctl stop opencode
sudo systemctl disable opencode

# Ta bort tjänstfil
sudo rm /etc/systemd/system/opencode.service
sudo systemctl daemon-reload

# Ta bort Nginx-konfiguration
sudo rm /etc/nginx/sites-enabled/opencode-test
sudo rm /etc/nginx/sites-available/opencode-test
sudo systemctl reload nginx

# Ta bort applikationsfiler
sudo rm -rf /opt/opencode

# Ta bort användare (valfritt)
sudo userdel -r opencode

# Ta bort logrotate-konfiguration
sudo rm /etc/logrotate.d/opencode
```

### Nästa Steg

#### För Lokal Utveckling

1. **Modifiera applikationen**
   ```bash
   sudo nano /opt/opencode/app/server.js
   # Gör ändringar
   sudo systemctl restart opencode
   ```

2. **Lägg till endpoints**
   ```javascript
   // Lägg till i server.js
   if (req.url === '/api/users') {
     // Din kod här
   }
   ```

3. **Lägg till miljövariabler**
   ```bash
   sudo nano /etc/systemd/system/opencode.service
   # Lägg till under [Service]:
   # Environment="MY_VAR=value"
   sudo systemctl daemon-reload
   sudo systemctl restart opencode
   ```

#### För Produktion

För en riktig produktionsmiljö behöver du:

1. **Riktig server med publikt IP**
   - VPS (Digital Ocean, Linode, Vultr, etc.)
   - Cloud (AWS EC2, Google Cloud, Azure)
   - Dedikerad server

2. **Domännamn**
   - Registrera domän
   - Konfigurera DNS A-record

3. **Kör full installation**
   ```bash
   sudo bash scripts/install.sh
   # Detta kommer att:
   # - Konfigurera SSL med Let's Encrypt
   # - Öppna rätt portar i brandvägg
   # - Sätta upp Fail2ban
   # - Konfigurera production-security
   ```

4. **Konfigurera IdP**
   ```bash
   sudo bash scripts/setup-idp.sh
   # Välj din IdP (Auth0, Okta, etc.)
   ```

### Tips och Tricks

#### Ändra port

```bash
# Ändra applikationsport
sudo nano /etc/systemd/system/opencode.service
# Ändra: Environment="PORT=3000" till önskad port
sudo systemctl daemon-reload
sudo systemctl restart opencode

# Ändra Nginx-port
sudo nano /etc/nginx/sites-available/opencode-test
# Ändra: listen 8080; till önskad port
sudo nginx -t
sudo systemctl reload nginx
```

#### Lägg till HTTPS lokalt (självsignerat certifikat)

```bash
# Skapa självsignerat certifikat
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/opencode-selfsigned.key \
  -out /etc/ssl/certs/opencode-selfsigned.crt

# Uppdatera Nginx-konfiguration för HTTPS
sudo nano /etc/nginx/sites-available/opencode-test
# Lägg till SSL-konfiguration

sudo systemctl reload nginx
```

#### Övervaka prestanda

```bash
# Systemresurser
htop

# Visa OpenCode-process
ps aux | grep node

# Minneanvändning
sudo systemctl show opencode --property=MemoryCurrent

# CPU-användning
top -p $(pgrep -f "node.*server.js")
```

### Vanliga Frågor

**Q: Varför port 8080 och inte 80?**
A: Port 80 kräver ofta root-rättigheter och kan vara upptagen. Port 8080 är standard för utveckling.

**Q: Kan jag använda riktig OpenCode istället för test-appen?**
A: Ja! Ersätt bara server.js med riktig OpenCode-applikation och uppdatera systemd-konfigurationen.

**Q: Fungerar detta i WSL?**
A: Ja, men du kan inte nå det från andra datorer i nätverket.

**Q: Kan jag lägga till databas?**
A: Ja! Installera t.ex. PostgreSQL och anslut från din applikation.

**Q: Hur lägger jag till authentication?**
A: För produktion, använd setup-idp.sh skriptet. För lokal test, implementera enkel auth i server.js.

### Support

För hjälp:
- GitHub Issues: https://github.com/gunnarnordqvist/opencode-web-service/issues
- Dokumentation: https://github.com/gunnarnordqvist/opencode-web-service
- Lokal test-dokumentation: Denna fil

---

**Lycka till med din installation!** 🚀
