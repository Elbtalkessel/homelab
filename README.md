# Homelab Infrastructure

Automated homelab management using Podman Quadlets, Fedora CoreOS (Butane), and Ansible.

## Overview

This repository manages the configuration and deployment of containerized services on a remote host (typically Fedora CoreOS). It leverages `devenv` for a consistent development environment and uses a git-hook-based sync mechanism to deploy changes.

### Key Components

- **`config/containers/`**: The heart of the configuration.
    - **`systemd/`**: Contains Podman Quadlet files (`.container`, `.network`, `.volume`, etc.).
        - Each service has its own subdirectory (e.g., `traefik/`, `plex/`).
        - Exception: `servarr/` contains all *arr-related applications.
    - **Top-level directories**: Service-specific configuration files (e.g., `traefik.yaml`, `dnsmasq/`). These are mapped 1:1 to service names where possible.
- **`devops/`**: Infrastructure automation.
    - **`butane/`**: Configuration for the first boot of the remote host.
    - **`ansible/`**: Post-boot system configuration (Work-In-Progress, used for reference).
- **`devenv.nix`**: Manages development dependencies and helper scripts.
- **`bin/`**: (Work-In-Progress) Helper scripts and utilities.

## Deployment Workflow

The project uses a "sync-on-commit" model:
1.  Make changes to configurations or Quadlet units.
2.  Commit the changes.
3.  A `pre-commit` hook automatically runs the `syncup` script, which uses `rsync` to push `config/containers/` to `~/.config/containers/` on the remote host.

### Manual Sync
You can manually trigger the sync by running:
```bash
syncup
```
*Note: This requires the `SSH_USER` and `SSH_HOST` environment variables to be set (usually via `.env`).*

## Conventions

- **Service Naming**: Quadlet unit names should match their configuration directory names.
- **Networking**: Shared components (like `public.network`) are defined as standalone units.
- **Socket Activation**: Currently disabled for Traefik due to ACME validation inconsistencies with Step-CA. See detailed notes in the Technical reference section (if applicable).

## Tooling & Dependencies

This project uses [devenv](https://devenv.sh/).
- To enter the development environment: `devenv shell`
- If you add new tools to `devenv.nix`, the session must be restarted to apply changes.

---
*For detailed instructions on how AI agents should interact with this repository, see [AGENTS.md](AGENTS.md).*
