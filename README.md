# Homelab Infrastructure

Automated homelab management using Podman Quadlets, Fedora CoreOS (Butane), and Ansible.

## Overview

This repository manages the configuration and deployment of containerized services on a remote host (typically Fedora CoreOS). It leverages `devenv` for a consistent development environment and uses a git-hook-based sync mechanism to deploy changes.

### Key Components

- **`config/containers/`**: The heart of the configuration.
  - **`systemd/`**: Contains Podman Quadlet files (`.container`, `.network`, `.volume`, etc.).
    - Each service has its own subdirectory (e.g., `traefik/`, `plex/`).
    - Exception: `servarr/` contains all \*arr-related applications.
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

_Note: This requires the `SSH_USER` and `SSH_HOST` environment variables to be set (usually via `.env`)._

## Conventions

- **Service Naming**: Quadlet unit names should match their configuration directory names.
- **Networking**: Shared components (like `public.network`) are defined as standalone units.
- **Socket Activation**: Currently disabled for Traefik due to ACME validation inconsistencies with Step-CA. See detailed notes in the Technical reference section (if applicable).

## Tooling & Dependencies

This project uses [devenv](https://devenv.sh/).

- To enter the development environment: `devenv shell`
- If you add new tools to `devenv.nix`, the session must be restarted to apply changes.

## Available Services

- [adguard](./config/containers/systemd/adguard)
- [calibre](./config/containers/systemd/calibre)
- [chtsh](./config/containers/systemd/chtsh)
- [dnsmasq](./config/containers/systemd/dnsmasq)
- [dovecot](./config/containers/systemd/dovecot) _WIP_
- [gitea](./config/containers/systemd/gitea)
- [i2p](./config/containers/systemd/i2p) _WIP_
- [immich](./config/containers/systemd/immich)
- [invidious](./config/containers/systemd/invidious)
- [plex](./config/containers/systemd/plex)
- [postfix](./config/containers/systemd/postfix) _WIP_
- [romm](./config/containers/systemd/romm)
- [roundcube](./config/containers/systemd/roundcube) _WIP_
- [sablier](./config/containers/systemd/sablier)
- [searxng](./config/containers/systemd/searxng)
- [flaresolverr](./config/containers/systemd/servarr/flaresolverr)
- [lidarr](./config/containers/systemd/servarr/lidarr)
- [prowlarr](./config/containers/systemd/servarr/prowlarr)
- [radarr](./config/containers/systemd/servarr/radarr)
- [seerr](./config/containers/systemd/servarr/seerr)
- [sonarr](./config/containers/systemd/servarr/sonarr)
- [whisparr](./config/containers/systemd/servarr/whisparr)
- [stash](./config/containers/systemd/stash)
- [stasharr](./config/containers/systemd/stasharr)
- [status](./config/containers/systemd/status)
- [step-ca](./config/containers/systemd/step-ca)
- [torrent](./config/containers/systemd/torrent)
- [traefik](./config/containers/systemd/traefik)
- [vaultwarden](./config/containers/systemd/vaultwarden)
- [whoami](./config/containers/systemd/whoami)

---

_For detailed instructions on how AI agents should interact with this repository, see [AGENTS.md](AGENTS.md)._
