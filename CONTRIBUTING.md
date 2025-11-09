# Contributing to OpenCode Web Service

Thank you for your interest in contributing to OpenCode Web Service! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Submitting Changes](#submitting-changes)

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

### Our Standards

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Accept constructive criticism gracefully
- Focus on what's best for the community
- Show empathy towards other community members

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/opencode-web-service.git
   cd opencode-web-service
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/opencode-web-service.git
   ```
4. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Prerequisites

- Linux-based OS (Ubuntu, Debian, CentOS, etc.) or WSL2 on Windows
- Bash 4.0+
- Git
- Node.js 14+ (for package.json validation)
- Docker (optional, for testing)

### Local Setup

```bash
# Install dependencies (if any)
npm install

# Run tests
npm test

# Test scripts locally (in a VM or container)
sudo bash scripts/install.sh
```

### Testing Environment

We recommend testing in a virtual machine or container to avoid affecting your system:

```bash
# Using Docker
docker run -it ubuntu:22.04 /bin/bash

# Or using Vagrant
vagrant init ubuntu/jammy64
vagrant up
vagrant ssh
```

## How to Contribute

### Reporting Bugs

When reporting bugs, please include:

1. **Description**: Clear description of the issue
2. **Steps to Reproduce**: Step-by-step instructions
3. **Expected Behavior**: What you expected to happen
4. **Actual Behavior**: What actually happened
5. **Environment**:
   - OS and version
   - Script version
   - Relevant logs
6. **Screenshots**: If applicable

Use the bug report template when creating an issue.

### Suggesting Features

When suggesting features:

1. **Use Case**: Describe the problem you're trying to solve
2. **Proposed Solution**: How you think it should work
3. **Alternatives**: Other solutions you've considered
4. **Additional Context**: Any other relevant information

Use the feature request template when creating an issue.

### Code Contributions

We welcome contributions in these areas:

- Bug fixes
- New features
- Documentation improvements
- Test coverage improvements
- Performance optimizations
- Support for new Linux distributions
- Support for new IdP providers

## Coding Standards

### Bash Scripts

Follow these guidelines for shell scripts:

```bash
#!/bin/bash
###############################################################################
# Script Description
# Detailed explanation of what this script does
###############################################################################

set -e  # Exit on error

# Use meaningful variable names
VARIABLE_NAME="value"

# Use functions for reusability
function_name() {
    local local_var="value"
    # Function code
}

# Add comments for complex logic
# This does X because Y

# Use proper error handling
if [ condition ]; then
    # Handle success
else
    # Handle error
    exit 1
fi
```

### Style Guidelines

1. **Indentation**: Use 4 spaces (no tabs)
2. **Line Length**: Keep lines under 100 characters
3. **Comments**: Add comments for complex logic
4. **Error Handling**: Always handle errors appropriately
5. **Logging**: Use the log functions (log_info, log_success, log_error)
6. **Variables**: 
   - Use UPPER_CASE for constants
   - Use lower_case for local variables
   - Quote all variable expansions: `"$VARIABLE"`

### Shell Script Checks

Before submitting, run these checks:

```bash
# Check syntax
bash -n script.sh

# Run shellcheck (install: apt install shellcheck)
shellcheck script.sh

# Test the script
bash script.sh --help
```

## Testing

### Running Tests

```bash
# Run all tests
npm test

# Run specific test
bash tests/run-tests.sh
```

### Adding Tests

When adding new features, include tests:

```bash
# Create test file in tests/ directory
tests/test-new-feature.sh

# Add test cases
test_new_feature() {
    log_info "Testing new feature"
    
    # Test code
    if [ expected_result ]; then
        log_success "Test passed"
        return 0
    else
        log_error "Test failed"
        return 1
    fi
}
```

### Testing Checklist

Before submitting:

- [ ] All tests pass
- [ ] New features have tests
- [ ] Scripts work on Ubuntu 22.04
- [ ] Scripts work on Debian 11
- [ ] Scripts work on CentOS 8 (if applicable)
- [ ] Documentation is updated
- [ ] No hardcoded credentials or secrets

## Documentation

### Documentation Standards

1. **Markdown**: Use Markdown for all documentation
2. **Structure**: Follow existing documentation structure
3. **Examples**: Include code examples where helpful
4. **Links**: Use relative links for internal references
5. **TOC**: Include table of contents for long documents

### Updating Documentation

When making changes that affect documentation:

1. Update relevant `.md` files
2. Update code comments
3. Update `README.md` if needed
4. Add examples to help users

### Documentation Checklist

- [ ] README.md updated (if needed)
- [ ] Relevant docs/ files updated
- [ ] Code comments added/updated
- [ ] Examples provided
- [ ] Links tested

## Submitting Changes

### Pull Request Process

1. **Update your fork**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Make your changes**:
   ```bash
   # Make changes
   git add .
   git commit -m "Description of changes"
   ```

3. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

4. **Create Pull Request**:
   - Go to GitHub
   - Click "New Pull Request"
   - Select your branch
   - Fill in the PR template

### Commit Messages

Write clear commit messages:

```
type: Brief description (50 chars or less)

More detailed explanation if needed. Wrap at 72 characters.
Explain what and why, not how.

Fixes #123
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Adding or updating tests
- `refactor`: Code refactoring
- `style`: Code style changes
- `chore`: Maintenance tasks

Examples:
```
feat: Add support for Fedora 38

Added installation support for Fedora 38, including package
manager detection and firewalld configuration.

Closes #45
```

```
fix: Correct Nginx configuration for OAuth2

Fixed issue where OAuth2 callback URL was not properly configured
in Nginx, causing authentication failures.

Fixes #67
```

### Pull Request Template

Use this template for PRs:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring
- [ ] Other (specify)

## Testing
- [ ] Tested on Ubuntu 22.04
- [ ] Tested on Debian 11
- [ ] Tested on CentOS 8
- [ ] Tests added/updated
- [ ] All tests pass

## Documentation
- [ ] Documentation updated
- [ ] README updated (if needed)
- [ ] Code comments added

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] No hardcoded secrets
- [ ] Commit messages are clear

## Related Issues
Closes #(issue number)
```

### Review Process

1. **Automated Checks**: CI/CD will run tests
2. **Code Review**: Maintainers will review your code
3. **Feedback**: Address any requested changes
4. **Approval**: Once approved, your PR will be merged

### After Your PR is Merged

1. **Delete your branch**:
   ```bash
   git branch -d feature/your-feature-name
   git push origin --delete feature/your-feature-name
   ```

2. **Update your fork**:
   ```bash
   git checkout main
   git fetch upstream
   git merge upstream/main
   git push origin main
   ```

## Support for New Distributions

To add support for a new Linux distribution:

1. **Test compatibility**: Verify the script works on the new distribution
2. **Update detection**: Add OS detection in `install.sh`:
   ```bash
   case $OS in
       ubuntu|debian|raspbian)
           # Existing code
           ;;
       your-new-distro)
           # New installation commands
           ;;
   esac
   ```
3. **Update documentation**: Add the distribution to README.md
4. **Add tests**: Create test case for the new distribution
5. **Submit PR**: Follow the PR process above

## Support for New IdP Providers

To add a new IdP provider:

1. **Create provider function** in `setup-idp.sh`:
   ```bash
   configure_new_provider() {
       log_info "Configuring New Provider..."
       # Configuration code
   }
   ```
2. **Add to selection menu**:
   ```bash
   select_idp_provider() {
       echo "X) New Provider"
       # Update case statement
   }
   ```
3. **Create documentation**: Add `docs/providers/NEW_PROVIDER.md`
4. **Update main docs**: Add to IdP setup guide
5. **Test thoroughly**: Verify authentication flow works
6. **Submit PR**: Follow the PR process

## Getting Help

If you need help:

1. Check existing documentation
2. Search closed issues
3. Ask in discussions
4. Open a new issue with the "question" label

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Given credit in commit history

Thank you for contributing to OpenCode Web Service!

---

**Questions?** Open an issue with the "question" label or reach out to the maintainers.
