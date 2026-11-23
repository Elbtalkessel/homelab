# Homelab Infrastructure

Automated homelab management using Podman Quadlets, Fedora CoreOS (Butane), and Ansible.

## Overview

This repository manages the configuration and deployment of containerized services on a remote host using Ansible.

### Key Components

- **`ansible/roles`**: The heart of the configuration.
  - **`core/`**: Remote host configuration.
- **`gitea/`**: Gitea-specific remote host configuration.
- **`networking/`**: Not used at the moment.
- **`quadlet/`**: The main part, containers running on a remote machine.
- **`sablier/`**: `quadlet/traefic` dependency, stops unused containers.
- **`tailscale/`**: Tailscale integration.
- **`wakeup/`**: Wake-On-Lan another host.

Playbooks split onto two parts - for root (`system.yaml`) and user (`user.yaml`).

List of enabled services and their configuration can be found in `ansible/roles/quadlet/defaults/main.yaml`

## Deploying

Quadlets

```bash
# from repo root
ansible-playbook ansible/user.yaml -t containers
# or check it first
ansible-playbook ansible/user.yaml -t containers --check --diff
```
