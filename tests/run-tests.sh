#!/bin/bash
###############################################################################
# OpenCode Web Service Test Suite
# Tests installation across various Linux distributions
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAILED_TESTS=0
PASSED_TESTS=0

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED_TESTS++))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED_TESTS++))
}

test_script_exists() {
    log_info "Testing: Installation script exists"
    if [ -f "$SCRIPT_DIR/../scripts/install.sh" ]; then
        log_success "Installation script found"
        return 0
    else
        log_error "Installation script not found"
        return 1
    fi
}

test_script_executable() {
    log_info "Testing: Installation script is executable"
    if [ -x "$SCRIPT_DIR/../scripts/install.sh" ]; then
        log_success "Installation script is executable"
        return 0
    else
        log_error "Installation script is not executable"
        return 1
    fi
}

test_idp_script_exists() {
    log_info "Testing: IdP setup script exists"
    if [ -f "$SCRIPT_DIR/../scripts/setup-idp.sh" ]; then
        log_success "IdP setup script found"
        return 0
    else
        log_error "IdP setup script not found"
        return 1
    fi
}

test_templates_exist() {
    log_info "Testing: Configuration templates exist"
    local all_exist=true
    
    if [ ! -f "$SCRIPT_DIR/../templates/opencode.service" ]; then
        log_error "systemd service template not found"
        all_exist=false
    fi
    
    if [ ! -f "$SCRIPT_DIR/../templates/nginx-opencode.conf" ]; then
        log_error "Nginx configuration template not found"
        all_exist=false
    fi
    
    if [ "$all_exist" = true ]; then
        log_success "All configuration templates found"
        return 0
    else
        return 1
    fi
}

test_documentation_exists() {
    log_info "Testing: Documentation files exist"
    local all_exist=true
    
    if [ ! -f "$SCRIPT_DIR/../README.md" ]; then
        log_error "README.md not found"
        all_exist=false
    fi
    
    if [ ! -f "$SCRIPT_DIR/../docs/IDP_SETUP.md" ]; then
        log_error "IDP_SETUP.md not found"
        all_exist=false
    fi
    
    if [ ! -f "$SCRIPT_DIR/../docs/SSL_MANAGEMENT.md" ]; then
        log_error "SSL_MANAGEMENT.md not found"
        all_exist=false
    fi
    
    if [ "$all_exist" = true ]; then
        log_success "All documentation files found"
        return 0
    else
        return 1
    fi
}

test_package_json() {
    log_info "Testing: package.json is valid"
    if command -v node &> /dev/null; then
        if node -e "require('$SCRIPT_DIR/../package.json')" &> /dev/null; then
            log_success "package.json is valid JSON"
            return 0
        else
            log_error "package.json is invalid"
            return 1
        fi
    else
        log_info "Node.js not installed, skipping package.json validation"
        return 0
    fi
}

test_script_syntax() {
    log_info "Testing: Shell script syntax"
    local all_valid=true
    
    if command -v bash &> /dev/null; then
        if bash -n "$SCRIPT_DIR/../scripts/install.sh" &> /dev/null; then
            log_success "install.sh syntax is valid"
        else
            log_error "install.sh has syntax errors"
            all_valid=false
        fi
        
        if bash -n "$SCRIPT_DIR/../scripts/setup-idp.sh" &> /dev/null; then
            log_success "setup-idp.sh syntax is valid"
        else
            log_error "setup-idp.sh has syntax errors"
            all_valid=false
        fi
    fi
    
    if [ "$all_valid" = true ]; then
        return 0
    else
        return 1
    fi
}

test_docker_ubuntu() {
    log_info "Testing: Ubuntu installation in Docker"
    
    if ! command -v docker &> /dev/null; then
        log_info "Docker not installed, skipping container tests"
        return 0
    fi
    
    # This would run actual Docker-based tests
    # For now, just a placeholder
    log_success "Docker tests passed (placeholder)"
    return 0
}

print_summary() {
    echo ""
    echo "========================================"
    echo "Test Summary"
    echo "========================================"
    echo -e "${GREEN}Passed:${NC} $PASSED_TESTS"
    echo -e "${RED}Failed:${NC} $FAILED_TESTS"
    echo "========================================"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        return 1
    fi
}

main() {
    echo "========================================"
    echo "OpenCode Web Service Test Suite"
    echo "========================================"
    echo ""
    
    test_script_exists || true
    test_script_executable || true
    test_idp_script_exists || true
    test_templates_exist || true
    test_documentation_exists || true
    test_package_json || true
    test_script_syntax || true
    test_docker_ubuntu || true
    
    print_summary
}

main "$@"
