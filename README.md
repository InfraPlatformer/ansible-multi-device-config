# ansible-multi-device-config

Ansible playbook to configure multiple network devices (Cisco/Juniper)

## Overview

This repository contains Ansible playbooks for network device configuration and management.

## Prerequisites

- Ansible >= 2.9
- Python 3.6+
- Network device credentials

## Installation

\\\ash
# Clone the repository
git clone https://github.com/InfraPlatformer/ansible-multi-device-config.git
cd ansible-multi-device-config

# Install Ansible
pip install ansible

# Install required Ansible collections
ansible-galaxy collection install cisco.ios
ansible-galaxy collection install junipernetworks.junos
\\\

## Usage

\\\ash
# Run playbook against inventory
ansible-playbook -i inventory/hosts playbook.yml

# Run with specific tags
ansible-playbook -i inventory/hosts playbook.yml --tags "config"

# Run in check mode (dry run)
ansible-playbook -i inventory/hosts playbook.yml --check
\\\

## Configuration

1. Update \inventory/hosts\ with your device IPs
2. Configure credentials in \group_vars/all.yml\
3. Customize playbook variables as needed

## Project Structure

\\\
ansible-multi-device-config/
├── playbooks/             # Ansible playbooks
├── roles/                 # Ansible roles
├── inventory/             # Inventory files
├── group_vars/            # Group variables
├── host_vars/             # Host variables
├── ansible.cfg            # Ansible configuration
├── requirements.yml       # Ansible requirements
├── README.md              # This file
└── .gitignore             # Git ignore rules
\\\

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with \nsible-playbook --check\
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Last Updated

2025-09-21

## Author

[Alam Ahmed](https://github.com/InfraPlatformer)
