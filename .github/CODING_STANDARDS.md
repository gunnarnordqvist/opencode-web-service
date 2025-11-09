# Coding Standards

## Language Requirements

### ⚠️ CRITICAL: English Only for All Code

**All code, comments, documentation, and technical content MUST be in English.**

This is a non-negotiable standard for the following reasons:

1. **International Collaboration**: Code must be accessible to developers worldwide
2. **Professional Standard**: English is the universal language of software development
3. **Tool Compatibility**: Many development tools assume English
4. **Maintainability**: Future maintainers must understand the code
5. **Open Source Best Practice**: Open source projects use English

### What Must Be in English

✅ **ALL Code**
- Variable names
- Function names
- Class names
- Constants
- All identifiers

✅ **ALL Comments**
- Code comments
- Header comments
- Inline explanations
- TODO/FIXME notes

✅ **ALL Documentation**
- README files
- API documentation
- Code documentation
- Technical specifications
- Configuration files
- Scripts

✅ **ALL Commit Messages**
- Commit titles
- Commit descriptions
- Pull request descriptions
- Issue descriptions

✅ **ALL User-Facing Text in Code**
- Error messages
- Log messages
- API responses
- Status messages

### Examples

#### ❌ WRONG (Swedish)
```bash
#!/bin/bash
# Installationsskript för OpenCode
# Skapar användare och konfigurerar tjänster

ANVÄNDARE="opencode"
HEMKATALOG="/opt/opencode"

skapa_användare() {
    # Skapa systemanvändare
    useradd -r $ANVÄNDARE
    log_info "Användare skapad"
}
```

#### ✅ CORRECT (English)
```bash
#!/bin/bash
# Installation script for OpenCode
# Creates user and configures services

USER_NAME="opencode"
HOME_DIR="/opt/opencode"

create_user() {
    # Create system user
    useradd -r $USER_NAME
    log_info "User created"
}
```

### When Swedish Is Acceptable

Swedish may ONLY be used in:

- README files specifically for Swedish users (e.g., `README.sv.md`)
- User-facing documentation translations
- Marketing materials
- Community discussions
- Issue discussions (but keep code/technical details in English)

### Exception: Communication

When communicating with Swedish-speaking team members or users:
- Use Swedish for **discussion** and **questions**
- Use English for **code**, **technical explanations**, and **documentation**

Example:
```
User: "Kan du hjälpa mig installera detta?" (Swedish - OK)
Response: "Ja, kör följande kommandon:" (Swedish - OK)

# Installation script (MUST be English)
sudo bash scripts/install.sh
```

## Enforcement

### Pre-Commit Checks

We recommend adding a pre-commit hook to check for non-English characters:

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Checking for Swedish characters in code files..."

# Check for Swedish characters in code files
if git diff --cached --name-only | grep -E '\.(sh|js|json|conf|service)$' | xargs grep -l 'å\|ä\|ö\|Å\|Ä\|Ö' 2>/dev/null; then
    echo "❌ ERROR: Swedish characters found in code files!"
    echo "All code must be in English."
    echo "Files with issues listed above."
    exit 1
fi

echo "✅ No Swedish characters found"
```

### Code Review Checklist

All pull requests must verify:
- [ ] All code is in English
- [ ] All comments are in English
- [ ] All commit messages are in English
- [ ] All variable/function names are in English
- [ ] All log messages are in English
- [ ] All error messages are in English

### Automatic Validation

```bash
# Run this to check your code before committing
find . -name "*.sh" -o -name "*.js" -o -name "*.json" | \
  xargs grep -l 'å\|ä\|ö\|Å\|Ä\|Ö' && \
  echo "❌ Swedish found!" || \
  echo "✅ All clear!"
```

## Additional Coding Standards

### Shell Scripts (Bash)

```bash
#!/bin/bash
# Always include shebang

set -e  # Exit on error

# Use meaningful variable names (English)
USER_NAME="opencode"
CONFIG_DIR="/etc/opencode"

# Use functions for reusability
create_user() {
    local user=$1
    useradd -r "$user"
}

# Always quote variables
echo "User: $USER_NAME"

# Use proper error handling
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Error: Config directory not found"
    exit 1
fi
```

### JavaScript/Node.js

```javascript
// Use camelCase for variables and functions
const userName = 'opencode';
const configPath = '/etc/opencode';

// Use PascalCase for classes
class UserManager {
    constructor(name) {
        this.userName = name;
    }
    
    // Method names in English
    createUser() {
        // Implementation
    }
}

// Comments in English
// This function initializes the application
function initializeApp() {
    // ...
}
```

### Configuration Files

```nginx
# Nginx config - comments in English
# OpenCode Web Service Configuration

upstream opencode_backend {
    server 127.0.0.1:3000;
}

server {
    listen 80;
    server_name example.com;
    
    # Proxy to backend
    location / {
        proxy_pass http://opencode_backend;
    }
}
```

### JSON Files

```json
{
  "name": "opencode-web-service",
  "description": "Secure setup for OpenCode",
  "version": "1.0.0",
  "keywords": [
    "opencode",
    "security",
    "automation"
  ]
}
```

## Summary

### The Golden Rule

**If it's code, technical documentation, or appears in a repository file that's not specifically a translation → it MUST be in English.**

### Why This Matters

1. **Professional Quality**: English-only code signals professional quality
2. **Open Source Standards**: Following open source best practices
3. **Global Accessibility**: Anyone can contribute and understand
4. **Tool Compatibility**: Works with all development tools
5. **Career Development**: Developers learn industry standards

### Consequences of Non-Compliance

- Pull requests will be rejected
- Code reviews will fail
- CI/CD pipelines may fail
- Project credibility is diminished
- International contributors are excluded

## Questions?

If you're unsure whether something should be in English:
- **When in doubt → use English**
- Ask in discussions (Swedish OK for questions)
- Review this document
- Check existing code examples

---

**Remember: Code is written once, read many times, by many people, around the world.**

**Keep it professional. Keep it English.** 🌍
