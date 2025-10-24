# Homelab Infrastructure 🚀

## Table of Contents 📚

- [Directory Structure 📁](#directory-structure)
- [Post CoreOS Installation 🛠️](#post-coreos-installation)
- [Preparing and Sending Configuration Files 📤](#preparing-and-sending-configuration-files)
  - [Syncing Configurations to the Server 🔗](#syncing-configurations-to-the-server)
- [CoreOS Server Configuration 🖥️](#coreos-server-configuration)
  - [Enable Lingering for Rootless Containers 👤](#enable-lingering-for-rootless-containers)
  - [Configure Docker CLI to use Podman 🐳](#configure-docker-cli-to-use-podman)
- [Certificate Authority with step-ca 🔒](#certificate-authority-with-step-ca)
  - [Network Setup and Volumes 🌐](#network-setup-and-volumes)
  - [Step-ca Initialization and Password 🗝️](#step-ca-initialization-and-password)
  - [Managing step-ca on the Server 🎛️](#managing-step-ca-on-the-server)
  - [Copy Root and Intermediate CA Certificates 📑](#copy-root-and-intermediate-ca-certificates)
- [Why Use the ca.x.home.arpa Container Name? ❓](#why-use-the-caxhomearpa-container-name)
- [Installing Certificates in Your Trust Store 🏢](#installing-certificates-in-your-trust-store)
  - [NixOS Example 🐧](#nixos-example)
- [TODO: CoreOS Butane Definition 📝](#todo-coreos-butane-definition)

## Directory Structure 📁

- **stacks/** — Docker/Podman compose files
- **bin/** — Helper scripts
- **coreos/** — CoreOS configurations

## Post CoreOS Installation 🛠️

- Configure your DNS to resolve to the CoreOS server IP.
- Traefik refers to your server as `x.home.arpa`.

## Preparing and Sending Configuration Files 📤

Create a `.env` with your settings:

```env
SSH_HOST=x.home.arpa
SSH_USER=user
REMOTE_DIR=/var/home/user/homelab
```

### Syncing Configurations to the Server 🔗

Use the `syncup` hook (defined in `devenv.nix`) to push `bin/`, `coreos/`, `stacks/` to your server:

```sh
syncup
```

## CoreOS Server Configuration 🖥️

### Enable Lingering for Rootless Containers 👤

Keep containers running independently:

```sh
ssh x.home.arpa
loginctl enable-linger
```

_Or use systemd user services._

### Configure Docker CLI to use Podman 🐳

Set Docker CLI to use Podman for compatibility:

```sh
mkdir -p ~/.bashrc.d
echo "export DOCKER_HOST=unix:///run/user/$UID/podman/podman.sock" > ~/.bashrc.d/environment
```

## Certificate Authority with step-ca 🔒

step-ca issues TLS certificates for homelab services managed by Traefik.

Create a shared network and persistent cert storage:

```sh
docker network create public
docker volume create certs
```

### Step-ca Initialization and Password 🗝️

Optionally set `DOCKER_STEPCA_INIT_PASSWORD` for certificate security. Store securely.
If not set, step-ca will generate it on first run, make sure look at `docker compose logs` and write it down!

### Managing step-ca on the Server 🎛️

Add ACME provisioner for certificate requests:

```sh
cd ~/homelab/stacks/ca
docker compose exec step-ca step ca provisioner add acme --type=ACME
docker compose restart
```

### Copy Root and Intermediate CA Certificates 📑

Get the CA certs then copy to your local machine:

```sh
docker cp ca.x.home.arpa:/home/step/certs/root_ca.crt .
docker cp ca.x.home.arpa:/home/step/certs/intermediate_ca.crt .
scp x.home.arpa:~/root_ca.crt .
scp x.home.arpa:~/intermediate_ca.crt .
```

## Why Use the ca.x.home.arpa Container Name? ❓

The CA container responds over HTTPS,
Hostname set in `DOCKER_STEPCA_INIT_DNS_NAMES` should match HOST header you send.
This container is not part of the Traefik definition to avoid disruption from self-signed certificates.

## Installing Certificates in Your Trust Store 🏢

Install the root and intermediate certificates per your OS guidelines.

### NixOS Example 🐧

Add certificates to your NixOS config:

```nix
security.pki.certificateFiles = [
  /path/to/root_ca.crt
  /path/to/intermediate_ca.crt
];
```

For other distros: See [Linux CA certificate management](https://www.baeldung.com/linux/ca-certificate-management).

## TODO: CoreOS Butane Definition 📝

Provide a Butane config example for automating CoreOS setup, containers, and networking.

With these steps, you’ll automate and secure your homelab server, maintaining flexibility for containerized workloads with trusted HTTPS services.
