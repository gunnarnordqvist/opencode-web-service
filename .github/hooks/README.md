# Git Hooks

This directory contains Git hooks for code quality enforcement.

## Installation

To enable the pre-commit hook:

```bash
# From repository root
cp .github/hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

Or create a symlink:

```bash
# From repository root
ln -s ../../.github/hooks/pre-commit .git/hooks/pre-commit
```

## Available Hooks

### pre-commit

**Purpose**: Ensures all code and technical content is in English

**What it checks**:
- Shell scripts (.sh)
- JavaScript files (.js)
- JSON files (.json)
- Configuration files (.conf, .cfg, .yaml, .yml)
- Service files (.service)

**What it blocks**:
- Swedish characters (å, ä, ö, Å, Ä, Ö) in code files
- Non-English comments
- Non-English variable names

**How to bypass** (NOT recommended):
```bash
# Only if you absolutely must (NOT for code files!)
git commit --no-verify
```

## Why This Matters

All code must be in English for:
- International collaboration
- Professional standards
- Tool compatibility
- Open source best practices
- Global accessibility

See [CODING_STANDARDS.md](../CODING_STANDARDS.md) for full details.

## Testing the Hook

```bash
# Create a test file with Swedish
echo "# Användare" > test.sh
git add test.sh
git commit -m "Test"

# Should fail with:
# ❌ COMMIT REJECTED: Non-English content detected

# Fix it
echo "# User" > test.sh
git add test.sh
git commit -m "Test"

# Should succeed
```

## Automatic Installation

Add to your setup script:

```bash
#!/bin/bash
# setup-hooks.sh

REPO_ROOT=$(git rev-parse --show-toplevel)
HOOK_SOURCE="$REPO_ROOT/.github/hooks/pre-commit"
HOOK_TARGET="$REPO_ROOT/.git/hooks/pre-commit"

if [ -f "$HOOK_SOURCE" ]; then
    cp "$HOOK_SOURCE" "$HOOK_TARGET"
    chmod +x "$HOOK_TARGET"
    echo "✅ Pre-commit hook installed"
else
    echo "❌ Hook source not found: $HOOK_SOURCE"
    exit 1
fi
```

## Troubleshooting

### Hook doesn't run

```bash
# Check if hook is executable
ls -la .git/hooks/pre-commit

# Make it executable
chmod +x .git/hooks/pre-commit
```

### Hook runs but doesn't catch issues

```bash
# Test the pattern matching
grep -E 'å|ä|ö|Å|Ä|Ö' your-file.sh

# Run hook manually
.git/hooks/pre-commit
```

### Need to commit despite warning

**DO NOT** use `--no-verify` for code files!

If you have a legitimate reason (e.g., Swedish in documentation):
1. Move Swedish content to separate documentation files
2. Exclude documentation from hook checks
3. Only use `--no-verify` for non-code commits

## Contributing

To improve the hooks:
1. Edit `.github/hooks/pre-commit`
2. Test thoroughly
3. Update this README
4. Submit a pull request

---

**Remember: These hooks protect code quality and professional standards.**
