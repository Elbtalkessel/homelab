# Homelab Infra

- [stacks](./stacks) docker / podman compose files
- [bin](./bin) helper scripts
- [coreos](./coreos) coreos related

## Setting up

Before doing it, upload ssh key to a host where homelab is running.

Create .env file:

```env
SSH_HOST=127.0.0.1
SSH_USER=user
REMOTE_DIR=/var/home/user/homelab
```

Note: `devenv.nix` defines the `syncup` hook which will push `bin`, `coreos` and `stacks` directory to the
remote host into `REMOTE_DIR`. You can use `syncup` script directly.

### Certificate Authority

Project uses _step-ca_ as certificate authority. In turn traefik will use it to issue certificates to services.

Both traefik and step-ca container must be on the same network, to simplify we'll reuse the same network name
for all our services connected to traefik:

```sh
podman network create public
podman volume create certs
```

Next we need a password for our root certificate.
Unfortunatelly podman doesn't supports secrets with custom targets (not sure if it supports it at all tho)

Use your preferred method to create a random string and set `DOCKER_STEPCA_INIT_PASSWORD` in `stacks/ca/.env`

Note: without the password you won't be able to issue or renew certificates.

Run `syncup` to send changed to remote host, ssh into it and start step-ca service.

On the remote host in the ca stacks directory run:

```sh
podman-compose exec step-ca step ca provisioner add acme --type=ACME
podman cp step-ca:/home/step/certs/root_ca.crt .
podman-compose restart
```

It will add ACMER provisioner we'll need later and copy root certificate on host.
The root certificate will be used to sign other certificates.

Read more [here](https://www.baeldung.com/linux/ca-certificate-management).

On NixOS you can add this cert to trust store like this:

```nix
security.pki.certificateFiles = [ /path/to/root_ca.crt ];
```

You can now remove `root_ca.crt` from server.
