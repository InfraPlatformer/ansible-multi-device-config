#!/bin/bash

# Python Code Cleanup Script
# This script cleans up Python code in automation projects

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
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_DIR/python_cleanup.log"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_DIR/python_cleanup.log"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_DIR/python_cleanup.log"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Python tools
install_python_tools() {
    log "Installing Python cleanup tools..."
    
    pip3 install --user --upgrade \
        black \
        flake8 \
        mypy \
        pytest \
        pytest-cov \
        pre-commit \
        safety \
        bandit \
        isort \
        autopep8 \
        pylint \
        radon
    
    success "Python tools installed successfully"
}

# Function to format Python code with black
format_code() {
    local target_dir="$1"
    log "Formatting Python code in $target_dir with black..."
    
    cd "$target_dir"
    
    if command_exists black; then
        black --line-length 88 --target-version py38 . 2>&1 | tee -a "$LOG_DIR/python_cleanup.log"
        success "Code formatted with black"
    else
        error "black not found. Please install it first."
        return 1
    fi
}

# Function to sort imports with isort
sort_imports() {
    local target_dir="$1"
    log "Sorting imports in $target_dir with isort..."
    
    cd "$target_dir"
    
    if command_exists isort; then
        isort --profile black --line-length 88 . 2>&1 | tee -a "$LOG_DIR/python_cleanup.log"
        success "Imports sorted with isort"
    else
        error "isort not found. Please install it first."
        return 1
    fi
}

# Function to run linting with flake8
run_linting() {
    local target_dir="$1"
    log "Running flake8 linting in $target_dir..."
    
    cd "$target_dir"
    
    if command_exists flake8; then
        # Create .flake8 config if it doesn't exist
        if [ ! -f ".flake8" ]; then
            cat > .flake8 << EOF
[flake8]
max-line-length = 88
extend-ignore = E203, W503
exclude = 
    .git,
    __pycache__,
    .venv,
    venv,
    .env,
    .pytest_cache,
    .coverage,
    htmlcov,
    .tox,
    .mypy_cache,
    .eggs,
    *.egg
EOF
        fi
        
        flake8 . 2>&1 | tee -a "$LOG_DIR/python_cleanup.log" || true
        success "Flake8 linting completed"
    else
        error "flake8 not found. Please install it first."
        return 1
    fi
}

# Function to run type checking with mypy
run_type_checking() {
    local target_dir="$1"
    log "Running mypy type checking in $target_dir..."
    
    cd "$target_dir"
    
    if command_exists mypy; then
        # Create mypy config if it doesn't exist
        if [ ! -f "mypy.ini" ]; then
            cat > mypy.ini << EOF
[mypy]
python_version = 3.8
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
disallow_incomplete_defs = True
check_untyped_defs = True
disallow_untyped_decorators = True
no_implicit_optional = True
warn_redundant_casts = True
warn_unused_ignores = True
warn_no_return = True
warn_unreachable = True
strict_equality = True
EOF
        fi
        
        mypy . --ignore-missing-imports 2>&1 | tee -a "$LOG_DIR/python_cleanup.log" || true
        success "MyPy type checking completed"
    else
        error "mypy not found. Please install it first."
        return 1
    fi
}

# Function to run security check with bandit
run_security_check() {
    local target_dir="$1"
    log "Running security check with bandit in $target_dir..."
    
    cd "$target_dir"
    
    if command_exists bandit; then
        bandit -r . -f json -o "$LOG_DIR/bandit_report.json" 2>&1 | tee -a "$LOG_DIR/python_cleanup.log" || true
        success "Security check completed"
    else
        error "bandit not found. Please install it first."
        return 1
    fi
}

# Function to check for outdated dependencies
check_dependencies() {
    local target_dir="$1"
    log "Checking for outdated dependencies in $target_dir..."
    
    cd "$target_dir"
    
    if [ -f "requirements.txt" ]; then
        if command_exists safety; then
            safety check --json --output "$LOG_DIR/safety_report.json" 2>&1 | tee -a "$LOG_DIR/python_cleanup.log" || true
            success "Dependency security check completed"
        fi
        
        if command_exists pip; then
            pip list --outdated --format=json > "$LOG_DIR/outdated_packages.json" 2>&1 || true
            success "Outdated packages check completed"
        fi
    else
        warning "No requirements.txt found in $target_dir"
    fi
}

# Function to add pre-commit hooks
setup_pre_commit() {
    local target_dir="$1"
    log "Setting up pre-commit hooks in $target_dir..."
    
    cd "$target_dir"
    
    if [ ! -f ".pre-commit-config.yaml" ]; then
        cat > .pre-commit-config.yaml << EOF
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict
      - id: debug-statements

  - repo: https://github.com/psf/black
    rev: 23.3.0
    hooks:
      - id: black
        language_version: python3

  - repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
      - id: isort
        args: ["--profile", "black"]

  - repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
      - id: flake8

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.3.0
    hooks:
      - id: mypy
        additional_dependencies: [types-all]
        args: [--ignore-missing-imports]

  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.5
    hooks:
      - id: bandit
        args: ['-c', 'pyproject.toml']
EOF
        success "Pre-commit configuration created"
    else
        log "Pre-commit configuration already exists"
    fi
    
    # Install pre-commit hooks
    if command_exists pre-commit; then
        pre-commit install 2>&1 | tee -a "$LOG_DIR/python_cleanup.log" || true
        success "Pre-commit hooks installed"
    fi
}

# Function to create pytest configuration
setup_pytest() {
    local target_dir="$1"
    log "Setting up pytest configuration in $target_dir..."
    
    cd "$target_dir"
    
    if [ ! -f "pytest.ini" ]; then
        cat > pytest.ini << EOF
[tool:pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = 
    --verbose
    --tb=short
    --cov=.
    --cov-report=html
    --cov-report=term-missing
    --cov-fail-under=80
markers =
    slow: marks tests as slow (deselect with '-m "not slow"')
    integration: marks tests as integration tests
    unit: marks tests as unit tests
EOF
        success "Pytest configuration created"
    else
        log "Pytest configuration already exists"
    fi
}

# Function to create pyproject.toml
create_pyproject_toml() {
    local target_dir="$1"
    log "Creating pyproject.toml in $target_dir..."
    
    cd "$target_dir"
    
    if [ ! -f "pyproject.toml" ]; then
        cat > pyproject.toml << EOF
[build-system]
requires = ["setuptools>=45", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "$(basename "$target_dir")"
version = "0.1.0"
description = "Automation project"
authors = [{name = "InfraPlatformer", email = "your-email@example.com"}]
license = {text = "MIT"}
readme = "README.md"
requires-python = ">=3.8"
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
]

[tool.black]
line-length = 88
target-version = ['py38']
include = '\.pyi?$'
extend-exclude = '''
/(
  # directories
  \.eggs
  | \.git
  | \.hg
  | \.mypy_cache
  | \.tox
  | \.venv
  | venv
  | _build
  | buck-out
  | build
  | dist
)/
'''

[tool.isort]
profile = "black"
line_length = 88
multi_line_output = 3
include_trailing_comma = true
force_grid_wrap = 0
use_parentheses = true
ensure_newline_before_comments = true

[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
warn_unreachable = true
strict_equality = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = [
    "--verbose",
    "--tb=short",
    "--cov=.",
    "--cov-report=html",
    "--cov-report=term-missing",
    "--cov-fail-under=80",
]
markers = [
    "slow: marks tests as slow (deselect with '-m \"not slow\"')",
    "integration: marks tests as integration tests",
    "unit: marks tests as unit tests",
]

[tool.bandit]
exclude_dirs = ["tests", "venv", ".venv"]
skips = ["B101", "B601"]
EOF
        success "pyproject.toml created"
    else
        log "pyproject.toml already exists"
    fi
}

# Function to create basic test structure
create_test_structure() {
    local target_dir="$1"
    log "Creating test structure in $target_dir..."
    
    cd "$target_dir"
    
    # Create tests directory if it doesn't exist
    mkdir -p tests
    
    # Create __init__.py in tests directory
    if [ ! -f "tests/__init__.py" ]; then
        touch "tests/__init__.py"
    fi
    
    # Create example test file
    if [ ! -f "tests/test_example.py" ]; then
        cat > tests/test_example.py << EOF
"""
Example test file for the project.
"""
import pytest


def test_example():
    """Example test function."""
    assert True


class TestExample:
    """Example test class."""
    
    def test_example_method(self):
        """Example test method."""
        assert 1 + 1 == 2
EOF
        success "Test structure created"
    else
        log "Test structure already exists"
    fi
}

# Function to clean up Python code
cleanup_python_code() {
    local target_dir="$1"
    
    log "Starting Python code cleanup for $target_dir"
    
    # Install tools if needed
    install_python_tools
    
    # Format code
    format_code "$target_dir"
    
    # Sort imports
    sort_imports "$target_dir"
    
    # Run linting
    run_linting "$target_dir"
    
    # Run type checking
    run_type_checking "$target_dir"
    
    # Run security check
    run_security_check "$target_dir"
    
    # Check dependencies
    check_dependencies "$target_dir"
    
    # Setup pre-commit hooks
    setup_pre_commit "$target_dir"
    
    # Setup pytest
    setup_pytest "$target_dir"
    
    # Create pyproject.toml
    create_pyproject_toml "$target_dir"
    
    # Create test structure
    create_test_structure "$target_dir"
    
    success "Python code cleanup completed for $target_dir"
}

# Main execution
main() {
    local target_dir="${1:-.}"
    
    if [ ! -d "$target_dir" ]; then
        error "Target directory $target_dir does not exist"
        exit 1
    fi
    
    cleanup_python_code "$target_dir"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi