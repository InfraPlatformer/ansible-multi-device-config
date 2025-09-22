#!/bin/bash

# Code Cleanup Toolkit - Main Script
# This script processes all repositories for InfraPlatformer

set -euo pipefail

# Configuration
GITHUB_USER="InfraPlatformer"
WORKSPACE_DIR="/workspace"
CLEANUP_DIR="$WORKSPACE_DIR/code_cleanup_toolkit"
LOG_DIR="$CLEANUP_DIR/logs"
REPORT_DIR="$CLEANUP_DIR/reports"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create necessary directories
mkdir -p "$LOG_DIR" "$REPORT_DIR"

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_DIR/cleanup.log"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_DIR/cleanup.log"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_DIR/cleanup.log"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_DIR/cleanup.log"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install required tools
install_tools() {
    log "Installing required tools..."
    
    # Update package lists
    if command_exists apt-get; then
        sudo apt-get update
        sudo apt-get install -y curl jq git python3 python3-pip nodejs npm
    elif command_exists yum; then
        sudo yum update -y
        sudo yum install -y curl jq git python3 python3-pip nodejs npm
    elif command_exists brew; then
        brew install curl jq git python3 node
    else
        error "Package manager not supported. Please install required tools manually."
        exit 1
    fi
    
    # Install Python packages
    pip3 install --user black flake8 mypy pytest ansible-lint yamllint
    pip3 install --user pre-commit safety bandit
    
    # Install Node.js packages
    npm install -g eslint prettier
    
    # Install shellcheck
    if ! command_exists shellcheck; then
        if command_exists apt-get; then
            sudo apt-get install -y shellcheck
        elif command_exists yum; then
            sudo yum install -y shellcheck
        elif command_exists brew; then
            brew install shellcheck
        fi
    fi
    
    success "Tools installed successfully"
}

# Function to get list of repositories
get_repositories() {
    log "Fetching repositories for $GITHUB_USER..."
    
    # Try to get repositories using GitHub API
    if command_exists curl && command_exists jq; then
        local repos_file="$CLEANUP_DIR/repositories.json"
        curl -s "https://api.github.com/users/$GITHUB_USER/repos?per_page=100" > "$repos_file"
        
        if [ -f "$repos_file" ]; then
            jq -r '.[].name' "$repos_file" > "$CLEANUP_DIR/repo_list.txt"
            local repo_count=$(wc -l < "$CLEANUP_DIR/repo_list.txt")
            log "Found $repo_count repositories"
        else
            error "Failed to fetch repositories from GitHub API"
            return 1
        fi
    else
        error "curl or jq not available. Cannot fetch repository list."
        return 1
    fi
}

# Function to clone repository
clone_repo() {
    local repo_name="$1"
    local repo_dir="$CLEANUP_DIR/repos/$repo_name"
    
    if [ -d "$repo_dir" ]; then
        log "Repository $repo_name already exists, updating..."
        cd "$repo_dir"
        git pull origin main || git pull origin master
    else
        log "Cloning repository $repo_name..."
        git clone "https://github.com/$GITHUB_USER/$repo_name.git" "$repo_dir"
    fi
}

# Function to analyze repository
analyze_repo() {
    local repo_name="$1"
    local repo_dir="$CLEANUP_DIR/repos/$repo_name"
    local report_file="$REPORT_DIR/${repo_name}_analysis.json"
    
    log "Analyzing repository: $repo_name"
    
    cd "$repo_dir"
    
    # Initialize analysis report
    cat > "$report_file" << EOF
{
    "repository": "$repo_name",
    "analysis_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "languages": {},
    "files_analyzed": 0,
    "issues_found": [],
    "recommendations": []
}
EOF
    
    # Detect languages and file types
    detect_languages "$repo_dir" "$report_file"
    
    # Run language-specific analysis
    run_language_analysis "$repo_dir" "$report_file"
    
    # Generate recommendations
    generate_recommendations "$report_file"
    
    success "Analysis completed for $repo_name"
}

# Function to detect languages in repository
detect_languages() {
    local repo_dir="$1"
    local report_file="$2"
    
    log "Detecting languages in $repo_dir"
    
    # Count files by extension
    local languages=$(find "$repo_dir" -type f -name "*.py" -o -name "*.sh" -o -name "*.yml" -o -name "*.yaml" -o -name "*.tf" -o -name "*.js" -o -name "*.json" -o -name "Dockerfile" | \
        sed 's/.*\.//' | sort | uniq -c | sort -nr)
    
    # Update report with language counts
    echo "$languages" | while read count ext; do
        if [ -n "$ext" ]; then
            jq --arg lang "$ext" --argjson count "$count" '.languages[$lang] = $count' "$report_file" > "$report_file.tmp" && mv "$report_file.tmp" "$report_file"
        fi
    done
}

# Function to run language-specific analysis
run_language_analysis() {
    local repo_dir="$1"
    local report_file="$2"
    
    cd "$repo_dir"
    
    # Python analysis
    if find . -name "*.py" | head -1 | grep -q .; then
        log "Running Python analysis..."
        run_python_analysis "$report_file"
    fi
    
    # Bash analysis
    if find . -name "*.sh" | head -1 | grep -q .; then
        log "Running Bash analysis..."
        run_bash_analysis "$report_file"
    fi
    
    # Ansible analysis
    if find . -name "*.yml" -o -name "*.yaml" | head -1 | grep -q .; then
        log "Running Ansible analysis..."
        run_ansible_analysis "$report_file"
    fi
    
    # Terraform analysis
    if find . -name "*.tf" | head -1 | grep -q .; then
        log "Running Terraform analysis..."
        run_terraform_analysis "$report_file"
    fi
    
    # Docker analysis
    if find . -name "Dockerfile" | head -1 | grep -q .; then
        log "Running Docker analysis..."
        run_docker_analysis "$report_file"
    fi
}

# Function to run Python analysis
run_python_analysis() {
    local report_file="$1"
    
    # Run flake8
    if command_exists flake8; then
        flake8 . --format=json --output-file="$CLEANUP_DIR/flake8_output.json" 2>/dev/null || true
        if [ -f "$CLEANUP_DIR/flake8_output.json" ]; then
            local flake8_issues=$(jq length "$CLEANUP_DIR/flake8_output.json")
            jq --argjson issues "$flake8_issues" '.issues_found += [{"type": "flake8", "count": $issues}]' "$report_file" > "$report_file.tmp" && mv "$report_file.tmp" "$report_file"
        fi
    fi
    
    # Run black check
    if command_exists black; then
        black --check . > "$CLEANUP_DIR/black_output.txt" 2>&1 || true
        if grep -q "would reformat" "$CLEANUP_DIR/black_output.txt"; then
            jq '.issues_found += [{"type": "black_formatting", "description": "Code needs formatting"}]' "$report_file" > "$report_file.tmp" && mv "$report_file.tmp" "$report_file"
        fi
    fi
    
    # Run mypy
    if command_exists mypy; then
        mypy . --ignore-missing-imports > "$CLEANUP_DIR/mypy_output.txt" 2>&1 || true
        if [ -s "$CLEANUP_DIR/mypy_output.txt" ]; then
            local mypy_issues=$(wc -l < "$CLEANUP_DIR/mypy_output.txt")
            jq --argjson issues "$mypy_issues" '.issues_found += [{"type": "mypy", "count": $issues}]' "$report_file" > "$report_file.tmp" && mv "$report_file.tmp" "$report_file"
        fi
    fi
}

# Function to run Bash analysis
run_bash_analysis() {
    local report_file="$1"
    
    # Run shellcheck
    if command_exists shellcheck; then
        local shellcheck_issues=0
        find . -name "*.sh" -exec shellcheck {} \; > "$CLEANUP_DIR/shellcheck_output.txt" 2>&1 || true
        shellcheck_issues=$(grep -c "SC[0-9]" "$CLEANUP_DIR/shellcheck_output.txt" || echo "0")
        jq --argjson issues "$shellcheck_issues" '.issues_found += [{"type": "shellcheck", "count": $issues}]' "$report_file" > "$report_file.tmp" && mv "$report_file.tmp" "$report_file"
    fi
}

# Function to run Ansible analysis
run_ansible_analysis() {
    local report_file="$1"
    
    # Run ansible-lint
    if command_exists ansible-lint; then
        ansible-lint . > "$CLEANUP_DIR/ansible_lint_output.txt" 2>&1 || true
        if [ -s "$CLEANUP_DIR/ansible_lint_output.txt" ]; then
            local ansible_issues=$(wc -l < "$CLEANUP_DIR/ansible_lint_output.txt")
            jq --argjson issues "$ansible_issues" '.issues_found += [{"type": "ansible_lint", "count": $issues}]' "$report_file" > "$report_file.tmp" && mv "$report_file.tmp" "$report_file"
        fi
    fi
    
    # Run yamllint
    if command_exists yamllint; then
        yamllint . > "$CLEANUP_DIR/yamllint_output.txt" 2>&1 || true
        if [ -s "$CLEANUP_DIR/yamllint_output.txt" ]; then
            local yaml_issues=$(wc -l < "$CLEANUP_DIR/yamllint_output.txt")
            jq --argjson issues "$yaml_issues" '.issues_found += [{"type": "yamllint", "count": $issues}]' "$report_file" > "$report_file.tmp" && mv "$report_file.tmp" "$report_file"
        fi
    fi
}

# Function to run Terraform analysis
run_terraform_analysis() {
    local report_file="$1"
    
    # Run terraform fmt check
    if command_exists terraform; then
        terraform fmt -check=true -diff=true > "$CLEANUP_DIR/terraform_fmt_output.txt" 2>&1 || true
        if [ -s "$CLEANUP_DIR/terraform_fmt_output.txt" ]; then
            jq '.issues_found += [{"type": "terraform_formatting", "description": "Terraform files need formatting"}]' "$report_file" > "$report_file.tmp" && mv "$report_file.tmp" "$report_file"
        fi
    fi
}

# Function to run Docker analysis
run_docker_analysis() {
    local report_file="$1"
    
    # Run hadolint if available
    if command_exists hadolint; then
        find . -name "Dockerfile" -exec hadolint {} \; > "$CLEANUP_DIR/hadolint_output.txt" 2>&1 || true
        if [ -s "$CLEANUP_DIR/hadolint_output.txt" ]; then
            local docker_issues=$(wc -l < "$CLEANUP_DIR/hadolint_output.txt")
            jq --argjson issues "$docker_issues" '.issues_found += [{"type": "hadolint", "count": $issues}]' "$report_file" > "$report_file.tmp" && mv "$report_file.tmp" "$report_file"
        fi
    fi
}

# Function to generate recommendations
generate_recommendations() {
    local report_file="$1"
    
    # Add general recommendations
    jq '.recommendations += [
        "Add .gitignore file if missing",
        "Add README.md with project description and setup instructions",
        "Add LICENSE file",
        "Set up pre-commit hooks for code quality",
        "Add GitHub Actions for CI/CD",
        "Update dependencies to latest versions",
        "Add proper error handling and logging",
        "Add unit tests for critical functions"
    ]' "$report_file" > "$report_file.tmp" && mv "$report_file.tmp" "$report_file"
}

# Function to generate summary report
generate_summary_report() {
    log "Generating summary report..."
    
    local summary_file="$REPORT_DIR/summary_report.md"
    
    cat > "$summary_file" << EOF
# Code Cleanup Summary Report

Generated on: $(date)

## Overview
This report summarizes the code analysis results for all repositories.

## Repository Analysis Results

EOF
    
    # Process each repository report
    for report in "$REPORT_DIR"/*_analysis.json; do
        if [ -f "$report" ]; then
            local repo_name=$(jq -r '.repository' "$report")
            local total_issues=$(jq '.issues_found | length' "$report")
            
            echo "### $repo_name" >> "$summary_file"
            echo "- Total Issues Found: $total_issues" >> "$summary_file"
            
            # List specific issues
            jq -r '.issues_found[] | "- \(.type): \(.count // .description)"' "$report" >> "$summary_file"
            echo "" >> "$summary_file"
        fi
    done
    
    success "Summary report generated: $summary_file"
}

# Main execution
main() {
    log "Starting code cleanup process for InfraPlatformer repositories"
    
    # Install required tools
    install_tools
    
    # Get list of repositories
    get_repositories
    
    # Process each repository
    while IFS= read -r repo_name; do
        if [ -n "$repo_name" ]; then
            log "Processing repository: $repo_name"
            
            # Clone repository
            clone_repo "$repo_name"
            
            # Analyze repository
            analyze_repo "$repo_name"
        fi
    done < "$CLEANUP_DIR/repo_list.txt"
    
    # Generate summary report
    generate_summary_report
    
    success "Code cleanup analysis completed!"
    log "Check the reports directory for detailed analysis: $REPORT_DIR"
}

# Run main function
main "$@"