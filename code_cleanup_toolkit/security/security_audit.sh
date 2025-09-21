#!/bin/bash

# Security Audit Script for Automation Projects
# This script performs comprehensive security checks

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLEANUP_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$CLEANUP_DIR/logs"
SECURITY_DIR="$CLEANUP_DIR/security"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_DIR/security_audit.log"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_DIR/security_audit.log"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_DIR/security_audit.log"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_DIR/security_audit.log"
}

# Function to check for hardcoded secrets
check_hardcoded_secrets() {
    local target_dir="$1"
    log "Checking for hardcoded secrets in $target_dir..."
    
    cd "$target_dir"
    
    # Common secret patterns
    local secret_patterns=(
        "password\s*=\s*['\"][^'\"]+['\"]"
        "api_key\s*=\s*['\"][^'\"]+['\"]"
        "secret\s*=\s*['\"][^'\"]+['\"]"
        "token\s*=\s*['\"][^'\"]+['\"]"
        "private_key\s*=\s*['\"][^'\"]+['\"]"
        "aws_access_key"
        "aws_secret_key"
        "github_token"
        "slack_token"
        "discord_token"
    )
    
    local secrets_found=0
    
    for pattern in "${secret_patterns[@]}"; do
        if grep -r -i -E "$pattern" . --exclude-dir=.git --exclude-dir=venv --exclude-dir=.venv --exclude-dir=node_modules 2>/dev/null; then
            warning "Potential hardcoded secret found: $pattern"
            ((secrets_found++))
        fi
    done
    
    if [ $secrets_found -eq 0 ]; then
        success "No hardcoded secrets found"
    else
        error "Found $secrets_found potential hardcoded secrets"
    fi
}

# Function to check for insecure configurations
check_insecure_configs() {
    local target_dir="$1"
    log "Checking for insecure configurations in $target_dir..."
    
    cd "$target_dir"
    
    # Check for debug mode enabled
    if grep -r -i "debug\s*=\s*true" . --exclude-dir=.git 2>/dev/null; then
        warning "Debug mode may be enabled in production"
    fi
    
    # Check for insecure HTTP URLs
    if grep -r -i "http://" . --exclude-dir=.git 2>/dev/null; then
        warning "Insecure HTTP URLs found (consider using HTTPS)"
    fi
    
    # Check for weak encryption
    if grep -r -i "md5\|sha1" . --exclude-dir=.git 2>/dev/null; then
        warning "Weak encryption algorithms found (MD5/SHA1)"
    fi
    
    success "Insecure configuration check completed"
}

# Function to check dependencies for vulnerabilities
check_dependency_vulnerabilities() {
    local target_dir="$1"
    log "Checking dependencies for vulnerabilities in $target_dir..."
    
    cd "$target_dir"
    
    # Python dependencies
    if [ -f "requirements.txt" ]; then
        if command -v safety >/dev/null 2>&1; then
            safety check --json --output "$SECURITY_DIR/safety_report.json" 2>&1 | tee -a "$LOG_DIR/security_audit.log" || true
        fi
    fi
    
    # Node.js dependencies
    if [ -f "package.json" ]; then
        if command -v npm >/dev/null 2>&1; then
            npm audit --json > "$SECURITY_DIR/npm_audit_report.json" 2>&1 || true
        fi
    fi
    
    success "Dependency vulnerability check completed"
}

# Function to check file permissions
check_file_permissions() {
    local target_dir="$1"
    log "Checking file permissions in $target_dir..."
    
    cd "$target_dir"
    
    # Find files with overly permissive permissions
    find . -type f -perm 777 -not -path "./.git/*" 2>/dev/null | while read -r file; do
        warning "File with overly permissive permissions: $file"
    done
    
    # Find files with world-writable permissions
    find . -type f -perm 666 -not -path "./.git/*" 2>/dev/null | while read -r file; do
        warning "World-writable file: $file"
    done
    
    success "File permissions check completed"
}

# Function to check for exposed sensitive files
check_exposed_files() {
    local target_dir="$1"
    log "Checking for exposed sensitive files in $target_dir..."
    
    cd "$target_dir"
    
    # Sensitive file patterns
    local sensitive_files=(
        "*.pem"
        "*.key"
        "*.p12"
        "*.pfx"
        "*.crt"
        "*.pem"
        "id_rsa"
        "id_dsa"
        "known_hosts"
        ".env"
        "secrets.yaml"
        "credentials.json"
        "config.json"
        "vault_pass"
    )
    
    for pattern in "${sensitive_files[@]}"; do
        if find . -name "$pattern" -not -path "./.git/*" 2>/dev/null | grep -q .; then
            warning "Sensitive file found: $pattern"
        fi
    done
    
    success "Exposed files check completed"
}

# Function to generate security report
generate_security_report() {
    local target_dir="$1"
    log "Generating security report for $target_dir..."
    
    local report_file="$SECURITY_DIR/security_report_$(basename "$target_dir").md"
    
    cat > "$report_file" << EOF
# Security Audit Report

**Target Directory:** $target_dir  
**Audit Date:** $(date)  
**Auditor:** Code Cleanup Toolkit

## Summary

This report contains the results of automated security checks performed on the target directory.

## Checks Performed

1. ✅ Hardcoded Secrets Detection
2. ✅ Insecure Configuration Check
3. ✅ Dependency Vulnerability Scan
4. ✅ File Permissions Audit
5. ✅ Exposed Sensitive Files Check

## Recommendations

### Immediate Actions
- Review and remove any hardcoded secrets
- Update vulnerable dependencies
- Fix overly permissive file permissions
- Move sensitive files to secure locations

### Best Practices
- Use environment variables for sensitive data
- Implement proper secret management
- Regular dependency updates
- Principle of least privilege for file permissions
- Use HTTPS for all communications
- Enable debug mode only in development

## Next Steps

1. Review all warnings and errors
2. Implement recommended fixes
3. Re-run security audit
4. Set up automated security scanning in CI/CD

---
*This report was generated by the Code Cleanup Toolkit*
EOF
    
    success "Security report generated: $report_file"
}

# Function to run comprehensive security audit
run_security_audit() {
    local target_dir="$1"
    
    log "Starting security audit for $target_dir"
    
    # Create security directory
    mkdir -p "$SECURITY_DIR"
    
    # Run all security checks
    check_hardcoded_secrets "$target_dir"
    check_insecure_configs "$target_dir"
    check_dependency_vulnerabilities "$target_dir"
    check_file_permissions "$target_dir"
    check_exposed_files "$target_dir"
    
    # Generate report
    generate_security_report "$target_dir"
    
    success "Security audit completed for $target_dir"
}

# Main execution
main() {
    local target_dir="${1:-.}"
    
    if [ ! -d "$target_dir" ]; then
        error "Target directory $target_dir does not exist"
        exit 1
    fi
    
    run_security_audit "$target_dir"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi