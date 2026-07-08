# Agent Guidelines

This document provides instructions and context for AI agents working on this repository.

## Repository Layout for Agents

- **Service Configuration**: `config/containers/<service_name>/`
- **Quadlet Units**: `config/containers/systemd/<service_name>/<unit>.container` (or `.network`, `.volume`, etc.)
- **Exceptions**: The `servarr` directory in `config/containers/systemd/` groups multiple services (`sonarr`, `radarr`, etc.). Keep them together.
- **Future systemd user units**: `config/systemd/` is reserved for future use. **CRITICAL**: When implementing sync for this directory, ensure it does NOT remove remote files that are not present in the local repo.

## Workflow

### 1. Adding a New Service
1.  Identify the configuration needs (YAML files, environment variables, etc.).
2.  Create a directory in `config/containers/<service_name>` for these files.
3.  Create a directory in `config/containers/systemd/<service_name>` for the Quadlet files.
4.  Ensure the `.container` unit references the config files correctly (usually mapped via volumes).
5.  If the service needs to be exposed via Traefik:
    - Add it to the `public.network`.
    - Configure Traefik labels in the `.container` file.

## Quadlet Templates

Follow these templates when creating new services. Use `config/containers/systemd/immich/` as a reference.

### 1. Container Unit (`.container`)
- **Location**: `config/containers/systemd/<service_name>/<name>.container`
- **Key Fields**: `Image`, `ContainerName`, `Network`, `Volume`, `Environment`, `Secret`.
- **Note**: Use `AutoUpdate=registry` for automatic updates.
- **Example**:
  ```ini
  [Container]
  Image=ghcr.io/immich-app/immich-server:release
  ContainerName=immich
  AutoUpdate=registry
  Network=public.network
  Network=immich.network
  Volume=/var/mnt/s1/immich:/usr/src/app/upload
  Environment="DB_HOSTNAME=immich-db"
  Secret="immich-db-password,type=env,target=DB_PASSWORD"
  ```

### 2. Network Unit (`.network`)
- **Location**: `config/containers/systemd/<service_name>/<name>.network`
- **Purpose**: Internal communication between containers in the same service group.
- **Example**:
  ```ini
  [Network]
  NetworkName=immich_internal
  ```

### 3. Volume Unit (`.volume`)
- **Location**: `config/containers/systemd/<service_name>/<name>.volume`
- **Purpose**: Persistent storage for databases or app data.
- **Example**:
  ```ini
  [Volume]
  VolumeName=immich_db
  ```

## Networking Guidelines

- **`public.network`**: Use this for containers accessible from outside (via Traefik). It is a shared network.
- **Internal Networks**: Create a dedicated `.network` unit for each service group (e.g., `immich.network`). This separates internal components (like databases) from the outside world.
- **Service Isolation**: Internal components (DBs, Redis, etc.) should ONLY be on the internal service network. Only the main application container should be on both `public.network` and the internal service network if it needs external access.

### 2. Dependency Management
- All tools should be managed via `devenv.nix`.
- **Constraint**: If you need to install a new tool, add it to `packages` in `devenv.nix`.
- **Protocol**: After modifying `devenv.nix`, you **must** inform the user that a session restart is required to activate the new tools.

### 3. Testing and Deployment
- The `syncup` script is the primary deployment tool. It runs on every commit via a git hook.
- If you need to verify changes without committing, you can attempt to run the `syncup` command directly if the environment allows.
- **Verification**: Always check if `bu-check` passes if you modify Butane files (`devops/butane/`).

## Remote Host State
- The remote host is running Fedora CoreOS.
- Quadlets are synced to `~/.config/containers/`.
- User systemd units (future) will be synced to `~/.config/systemd/`.
- Ansible (`devops/ansible/`) is currently for **reference only**. Do not assume Ansible playbooks are functional or being used for active deployment unless instructed otherwise.

## Guidelines for Writing Code
- **Quadlets**: Prefer using Podman Quadlets over raw `podman run` commands or docker-compose.
- **Idempotency**: Ensure that configurations are idempotent.
- **Secrets**: Avoid hardcoding secrets. Check `.env` or ask the user for the preferred secret management strategy (SOPS is mentioned in README as preferred).
