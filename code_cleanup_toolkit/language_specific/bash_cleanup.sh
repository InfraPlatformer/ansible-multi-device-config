#!/bin/bash

# Bash Code Cleanup Script
# This script cleans up Bash scripts in automation projects

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLEANUP_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$CLEANUP_DIR/logs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_DIR/bash_cleanup.log"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_DIR/bash_cleanup.log"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_DIR/bash_cleanup.log"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Bash tools
install_bash_tools() {
    log "Installing Bash cleanup tools..."
    
    # Install shellcheck
    if ! command_exists shellcheck; then
        if command_exists apt-get; then
            sudo apt-get install -y shellcheck
        elif command_exists yum; then
            sudo yum install -y shellcheck
        elif command_exists brew; then
            brew install shellcheck
        else
            error "Cannot install shellcheck. Please install it manually."
            return 1
        fi
    fi
    
    # Install shfmt
    if ! command_exists shfmt; then
        if command_exists go; then
            go install mvdan.cc/sh/v3/cmd/shfmt@latest
        else
            error "Go not found. Cannot install shfmt. Please install it manually."
        fi
    fi
    
    success "Bash tools installed successfully"
}

# Function to run shellcheck
run_shellcheck() {
    local target_dir="$1"
    log "Running shellcheck in $target_dir..."
    
    cd "$target_dir"
    
    if command_exists shellcheck; then
        find . -name "*.sh" -type f -exec shellcheck {} \; 2>&1 | tee -a "$LOG_DIR/shellcheck_output.txt" || true
        success "Shellcheck completed"
    else
        error "shellcheck not found. Please install it first."
        return 1
    fi
}

# Function to format Bash code with shfmt
format_bash_code() {
    local target_dir="$1"
    log "Formatting Bash code in $target_dir with shfmt..."
    
    cd "$target_dir"
    
    if command_exists shfmt; then
        find . -name "*.sh" -type f -exec shfmt -w -i 4 -ci -sr {} \; 2>&1 | tee -a "$LOG_DIR/bash_cleanup.log"
        success "Bash code formatted with shfmt"
    else
        error "shfmt not found. Please install it first."
        return 1
    fi
}

# Function to add shebang and set options
fix_shebang_and_options() {
    local target_dir="$1"
    log "Fixing shebang and options in Bash scripts..."
    
    cd "$target_dir"
    
    find . -name "*.sh" -type f | while read -r file; do
        # Add shebang if missing
        if ! head -1 "$file" | grep -q "^#!/"; then
            sed -i '1i#!/bin/bash' "$file"
            log "Added shebang to $file"
        fi
        
        # Add set options if missing
        if ! grep -q "set -euo pipefail" "$file"; then
            sed -i '2i\set -euo pipefail' "$file"
            log "Added set options to $file"
        fi
    done
    
    success "Shebang and options fixed"
}

# Function to create .shellcheckrc
create_shellcheck_config() {
    local target_dir="$1"
    log "Creating .shellcheckrc configuration..."
    
    cd "$target_dir"
    
    if [ ! -f ".shellcheckrc" ]; then
        cat > .shellcheckrc << EOF
# Shellcheck configuration for automation projects
# Disable specific warnings that are common in automation scripts

# SC1090: Can't follow non-constant source
disable=SC1090

# SC1091: Not following sourced files
disable=SC1091

# SC2034: Variable appears unused
disable=SC2034

# SC2155: Declare and assign separately
disable=SC2155

# SC2164: Use cd ... || exit
disable=SC2164

# SC2181: Check exit code directly
disable=SC2181
EOF
        success ".shellcheckrc configuration created"
    else
        log ".shellcheckrc already exists"
    fi
}

# Function to clean up Bash code
cleanup_bash_code() {
    local target_dir="$1"
    
    log "Starting Bash code cleanup for $target_dir"
    
    # Install tools if needed
    install_bash_tools
    
    # Create shellcheck config
    create_shellcheck_config "$target_dir"
    
    # Fix shebang and options
    fix_shebang_and_options "$target_dir"
    
    # Format code
    format_bash_code "$target_dir"
    
    # Run shellcheck
    run_shellcheck "$target_dir"
    
    success "Bash code cleanup completed for $target_dir"
}

# Main execution
main() {
    local target_dir="${1:-.}"
    
    if [ ! -d "$target_dir" ]; then
        error "Target directory $target_dir does not exist"
        exit 1
    fi
    
    cleanup_bash_code "$target_dir"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi