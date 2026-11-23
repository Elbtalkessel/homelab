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
