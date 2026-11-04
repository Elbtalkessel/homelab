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

## Remote access via Tailscale

Services are reachable as `*.x.home.arpa` from both the LAN and over a
Tailscale tunnel. Nothing is exposed to the public internet.

### Server (one-time)

1. Generate a reusable auth key at <https://login.tailscale.com/admin/settings/keys> (Reusable: yes, Ephemeral: no).
2. On the host, create the podman secret:

   ```bash
   printf '%s' 'tskey-auth-XXXXXXXXXXXX' | podman secret create tailscale-authkey -
   ```

3. Sync and start the daemon:

   ```bash
   syncup
   systemctl --user daemon-reload
   systemctl --user enable --now tailscaled.service
   ```

4. In the Tailscale admin console:
   - Approve the subnet route `192.168.1.0/24` for the `coreos` node.
   - Add split DNS: nameserver `192.168.1.130`, split for domain `home.arpa`.

### Client (per device)

1. Install the Tailscale client and join the tailnet.
2. Pull the step-ca root CA from the homelab and install it in the
   device trust store. Run on the homelab host:

   ```bash
   bin/issue-stepca-root
   ```

   Transfer `step-ca-root.crt` to the client and follow the printed
   per-OS install steps.

3. Verify: `https://immich.x.home.arpa` should load and the cert should
   verify without warnings.

### What works when

- LAN, internet up or down: unchanged.
- Off-LAN, internet up: works via Tailscale + step-ca cert.
- Off-LAN, internet down: unreachable (Tailscale NAT traversal needs
  DERP). This is an accepted limitation.

### Held in reserve

- `yan.kim` is a Namecheap-registered public domain. It is not used yet;
  it exists as an escape hatch if any service ever needs to be exposed
  publicly (LE wildcard via DNS-01, no step-ca trust angle).

## Tooling & Dependencies

This project uses [devenv](https://devenv.sh/).

- To enter the development environment: `devenv shell`
- If you add new tools to `devenv.nix`, the session must be restarted to apply changes.

## Available Services

- [adguard](./config/containers/systemd/adguard)
- [calibre](./config/containers/systemd/calibre)
- [chtsh](./config/containers/systemd/chtsh)
- [cove](./config/containers/systemd/cove)
- [dnsmasq](./config/containers/systemd/dnsmasq)
- [dovecot](./config/containers/systemd/dovecot) _WIP_
- [gitea](./config/containers/systemd/gitea)
- [i2p](./config/containers/systemd/i2p) _WIP_
- [immich](./config/containers/systemd/immich)
- [invidious](./config/containers/systemd/invidious)
- [litellm](./config/containers/systemd/litellm)
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
