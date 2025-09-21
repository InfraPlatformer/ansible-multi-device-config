# Code Cleanup Toolkit for InfraPlatformer

This toolkit provides automated tools and scripts to clean up code across all your automation projects on GitHub.

## Features

- **Multi-language support**: Python, Bash, Ansible, Terraform, Docker, and more
- **Automated linting and formatting**: Consistent code style across all repositories
- **Security auditing**: Dependency checks and vulnerability scanning
- **Documentation generation**: Automated README and documentation updates
- **CI/CD integration**: GitHub Actions workflows for automated quality checks

## Quick Start

1. Clone this toolkit to your local machine
2. Run the main cleanup script: `./cleanup_all_repos.sh`
3. Review the generated reports and apply suggested changes

## Tools Included

- `cleanup_all_repos.sh` - Main script to process all repositories
- `language_specific/` - Language-specific cleanup tools
- `ci_cd/` - GitHub Actions workflows
- `templates/` - Documentation and configuration templates
- `security/` - Security audit tools

## Supported Languages

- Python (pytest, black, flake8, mypy)
- Bash (shellcheck, shfmt)
- Ansible (ansible-lint)
- Terraform (terraform fmt, tflint)
- Docker (hadolint)
- YAML (yamllint)
- JSON (jq validation)

## Usage

```bash
# Clean up all repositories
./cleanup_all_repos.sh

# Clean up specific repository
./cleanup_repo.sh <repo-name>

# Run specific language cleanup
./language_specific/python_cleanup.sh
```