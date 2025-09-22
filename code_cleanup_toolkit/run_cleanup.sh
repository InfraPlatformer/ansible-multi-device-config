#!/bin/bash

# Main Code Cleanup Runner
# This script orchestrates the entire code cleanup process

set -euo pipefail

# Configuration
CLEANUP_DIR="/workspace/code_cleanup_toolkit"
LOG_DIR="$CLEANUP_DIR/logs"
REPORT_DIR="$CLEANUP_DIR/reports"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_DIR/main_cleanup.log"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_DIR/main_cleanup.log"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_DIR/main_cleanup.log"
}

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS] [TARGET_DIRECTORY]

Code Cleanup Toolkit for InfraPlatformer

OPTIONS:
    -h, --help          Show this help message
    -a, --all           Clean up all repositories (requires GitHub access)
    -p, --python        Clean up Python code only
    -b, --bash          Clean up Bash scripts only
    -s, --security      Run security audit only
    -f, --format        Format code only
    -l, --lint          Run linting only
    -t, --test          Run tests only
    -c, --ci            Set up CI/CD workflows
    -d, --docs          Generate documentation
    --dry-run           Show what would be done without making changes

EXAMPLES:
    $0                          # Clean up current directory
    $0 /path/to/project         # Clean up specific project
    $0 --all                    # Clean up all GitHub repositories
    $0 --python --format        # Format Python code only
    $0 --security               # Run security audit only

EOF
}

# Function to create necessary directories
setup_directories() {
    log "Setting up directories..."
    mkdir -p "$LOG_DIR" "$REPORT_DIR" "$CLEANUP_DIR/security"
    success "Directories created"
}

# Function to run Python cleanup
run_python_cleanup() {
    local target_dir="$1"
    log "Running Python cleanup for $target_dir"
    
    if [ -f "$CLEANUP_DIR/language_specific/python_cleanup.sh" ]; then
        "$CLEANUP_DIR/language_specific/python_cleanup.sh" "$target_dir"
        success "Python cleanup completed"
    else
        error "Python cleanup script not found"
        return 1
    fi
}

# Function to run Bash cleanup
run_bash_cleanup() {
    local target_dir="$1"
    log "Running Bash cleanup for $target_dir"
    
    if [ -f "$CLEANUP_DIR/language_specific/bash_cleanup.sh" ]; then
        "$CLEANUP_DIR/language_specific/bash_cleanup.sh" "$target_dir"
        success "Bash cleanup completed"
    else
        error "Bash cleanup script not found"
        return 1
    fi
}

# Function to run security audit
run_security_audit() {
    local target_dir="$1"
    log "Running security audit for $target_dir"
    
    if [ -f "$CLEANUP_DIR/security/security_audit.sh" ]; then
        "$CLEANUP_DIR/security/security_audit.sh" "$target_dir"
        success "Security audit completed"
    else
        error "Security audit script not found"
        return 1
    fi
}

# Function to set up CI/CD
setup_cicd() {
    local target_dir="$1"
    log "Setting up CI/CD workflows for $target_dir"
    
    cd "$target_dir"
    
    # Create .github/workflows directory
    mkdir -p .github/workflows
    
    # Copy GitHub Actions workflow
    if [ -f "$CLEANUP_DIR/ci_cd/github_actions.yml" ]; then
        cp "$CLEANUP_DIR/ci_cd/github_actions.yml" ".github/workflows/code-quality.yml"
        success "GitHub Actions workflow created"
    else
        error "GitHub Actions template not found"
        return 1
    fi
}

# Function to generate documentation
generate_docs() {
    local target_dir="$1"
    log "Generating documentation for $target_dir"
    
    cd "$target_dir"
    
    # Copy README template if no README exists
    if [ ! -f "README.md" ] && [ -f "$CLEANUP_DIR/templates/README_template.md" ]; then
        cp "$CLEANUP_DIR/templates/README_template.md" "README.md"
        # Replace placeholder with actual repo name
        local repo_name=$(basename "$target_dir")
        sed -i "s/REPO_NAME/$repo_name/g" "README.md"
        success "README.md created from template"
    fi
    
    # Copy .gitignore template if no .gitignore exists
    if [ ! -f ".gitignore" ] && [ -f "$CLEANUP_DIR/templates/.gitignore_template" ]; then
        cp "$CLEANUP_DIR/templates/.gitignore_template" ".gitignore"
        success ".gitignore created from template"
    fi
}

# Function to run comprehensive cleanup
run_comprehensive_cleanup() {
    local target_dir="$1"
    local dry_run="$2"
    
    log "Starting comprehensive cleanup for $target_dir"
    
    if [ "$dry_run" = "true" ]; then
        log "DRY RUN MODE - No changes will be made"
    fi
    
    # Detect project type and run appropriate cleanup
    if find "$target_dir" -name "*.py" | head -1 | grep -q .; then
        log "Python project detected"
        if [ "$dry_run" = "false" ]; then
            run_python_cleanup "$target_dir"
        fi
    fi
    
    if find "$target_dir" -name "*.sh" | head -1 | grep -q .; then
        log "Bash project detected"
        if [ "$dry_run" = "false" ]; then
            run_bash_cleanup "$target_dir"
        fi
    fi
    
    # Always run security audit
    if [ "$dry_run" = "false" ]; then
        run_security_audit "$target_dir"
    fi
    
    # Set up CI/CD
    if [ "$dry_run" = "false" ]; then
        setup_cicd "$target_dir"
    fi
    
    # Generate documentation
    if [ "$dry_run" = "false" ]; then
        generate_docs "$target_dir"
    fi
    
    success "Comprehensive cleanup completed for $target_dir"
}

# Main execution
main() {
    local target_dir="."
    local run_all=false
    local python_only=false
    local bash_only=false
    local security_only=false
    local format_only=false
    local lint_only=false
    local test_only=false
    local ci_only=false
    local docs_only=false
    local dry_run=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -a|--all)
                run_all=true
                shift
                ;;
            -p|--python)
                python_only=true
                shift
                ;;
            -b|--bash)
                bash_only=true
                shift
                ;;
            -s|--security)
                security_only=true
                shift
                ;;
            -f|--format)
                format_only=true
                shift
                ;;
            -l|--lint)
                lint_only=true
                shift
                ;;
            -t|--test)
                test_only=true
                shift
                ;;
            -c|--ci)
                ci_only=true
                shift
                ;;
            -d|--docs)
                docs_only=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            -*)
                error "Unknown option $1"
                usage
                exit 1
                ;;
            *)
                target_dir="$1"
                shift
                ;;
        esac
    done
    
    # Setup
    setup_directories
    
    # Handle different modes
    if [ "$run_all" = "true" ]; then
        log "Running cleanup for all repositories"
        if [ -f "$CLEANUP_DIR/cleanup_all_repos.sh" ]; then
            "$CLEANUP_DIR/cleanup_all_repos.sh"
        else
            error "Main cleanup script not found"
            exit 1
        fi
    elif [ "$python_only" = "true" ]; then
        run_python_cleanup "$target_dir"
    elif [ "$bash_only" = "true" ]; then
        run_bash_cleanup "$target_dir"
    elif [ "$security_only" = "true" ]; then
        run_security_audit "$target_dir"
    elif [ "$ci_only" = "true" ]; then
        setup_cicd "$target_dir"
    elif [ "$docs_only" = "true" ]; then
        generate_docs "$target_dir"
    else
        run_comprehensive_cleanup "$target_dir" "$dry_run"
    fi
    
    success "Code cleanup process completed!"
    log "Check the logs directory for detailed information: $LOG_DIR"
    log "Check the reports directory for analysis results: $REPORT_DIR"
}

# Run main function
main "$@"