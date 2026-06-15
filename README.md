## Quadlet services layout

### Overview

- `config/containers/systemd/`
  Systemd quadlet units (services, sockets, networks, volumes).

- `config/containers/systemd/*.container.d`
  Quadlet drop-ins for overriding a service.

- `config/containers/`
  Per-service configuration directories. Each service (or service group) has its own directory containing config files, templates, and runtime assets.

- `devops/`
  Infrastructure automation:
  - Butane configs (system provisioning)
  - Ansible playbooks (system configuration and orchestration)

---

## Conventions

- Service name should match:
  - quadlet unit name (`.container`, `.network`, etc.)
  - configuration directory name (1:1 mapping preferred)
- Shared infrastructure components (e.g. `public.network`) are defined as standalone quadlets.

---

## Improvements / TODO

### Tooling

- Move helper scripts from `devenv.nix` into `bin/`
  - `igniter`
  - `syncup`
  - any environment bootstrap utilities

- Ensure `bin/` is included in `PATH` for both host and dev shells

### Invidious

- Migrate companion configuration from environment variables to YAML-based config files
- Introduce proper secret handling:
  - avoid plaintext keys in repo
  - evaluate:
    - systemd credentials (`LoadCredential=`)
    - `pass` / `gopass`
    - or SOPS (preferred if repo-managed secrets are needed)
- Continue UI customization work:
  - replace default container image with custom build
  - track UI changes as part of reproducible image pipeline

### Backups

- Introduce backup solution (preferably BorgBackup or similar)
- Target:
  - NFS-mounted storage backend
- Requirements:
  - deduplication
  - encryption
  - optional UI (web or TUI)
- Define backup scope per-service (not global-only backups)

### Security / Users

- Disable direct `sudo` usage for user `risus`
- Replace with controlled escalation model:
  - systemd-run / polkit where applicable
  - limited admin group or sudo ruleset (if absolutely required)
- Ensure container management remains possible without full root shell escalation

### Socket activation

Why: mostly because it fixes `X-Real-IP`, without the request IP = traefik internal IP.

`http*.socket` units are stored in `attic/config/systemd/user/` and must be linked into the user systemd directory (either via symlink or manual copy). They are currently not enabled; `traefik.container` is configured without socket activation (socket-related lines are commented out).

Socket activation is currently disabled because it introduces instability in the ACME validation flow with Step-CA. When enabled, Step-CA cannot reliably complete HTTP-01 validation against Traefik, resulting in certificate issuance failures.

Observed behavior:

- With socket activation enabled, Traefik is reached inconsistently from container-originated requests used during ACME validation.
- Host-originated requests work reliably, but container-originated validation requests fail during certificate issuance.
- Switching ACME configuration between `tlsChallenge` and `httpChallenge` (`entryPoint: web`) does not resolve the issue; it only changes the error type returned by Step-CA (still validation failure).

Attempts to mitigate:

- Adding `NetworkAlias=whoami.x.home.arpa` to service definitions improved internal DNS resolution, but did not resolve ACME validation failure.
- Relying on container-to-host routing via `192.168.1.130` remains unreliable under socket activation.
- No firewall or rp_filter misconfiguration has been identified as the cause.

Current conclusion:

- Socket activation changes the request path enough to break deterministic ACME HTTP-01 validation in this topology (Podman bridge + Traefik + Step-CA).
- The issue is not DNS or certificate policy, but inconsistent reachability of the Traefik HTTP endpoint during validation.

Planned improvement:

- Automate symlinking of socket units from `~/.config/containers/systemd/` into `~/.config/systemd/user/`.
- Update `syncup` script to manage socket activation units consistently.
- Revisit socket activation only after ACME flow is stable under non-activated Traefik.

Open question:

- Whether Traefik with socket activation can be made deterministic enough for ACME HTTP-01 in a Podman bridge setup, or whether socket activation should be permanently excluded for ingress services.

### Migration to Caddy

If Caddy as lightweight as Nginx it will be a good replacement for Traefik since I use it just a reverse proxy + ACME client. Traefik is resource hungry.
