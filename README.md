# Home Server Infrastructure 🚀

A set of quadlet services

## Overview

- config/containers/systemd: available services.
- config/containers/: local configuration files, directory name = service (or service group) name.
- hosts/: butane files describing a coreos host where services are intended to run.

## Available services

- mumble: untested.
- step-ca: Certificate Authority.
- plex
- torrent: qbittorrent service for \*arr services.
- adguard: dns query filter.
- traefik: edge proxy.
- sablier: traefik's plugin for suspending services.
- vaultwarden: password manager.
- calibre: e-book manager.
- gitea: git service.
- invidious: alternative youtube frontend.
- immich: photo manager.
- servarr
  - lidarr
  - prowlarr
  - radarr
  - sonarr
  - overseerr

## Things to do

- Put scripts from devenv.nix (igniter, syncup, etc.) to the bin/ directory.
- Create ansible playbook to provision host after first boot.
  - Make sure podman-auto-update.timer is started for user.
  - Move todo items from hosts/default.yml to the playbook.
- Invidious
  - Update companion to use yaml configs instead of env var.
  - How can we store secrets (such as companion key) not in plain text?
  - Continue work on updating UI and change Image= to custom one.
- Backups: borg or something similar. Backup to an NFS mount, preferrable with UI.
- Disable sudo for risus.
- Adguard + Traefik
  - Pass correct client ip, https://github.com/AdguardTeam/AdGuardHome/wiki/FAQ#how-to-configure-a-reverse-proxy-server-for-adguard-home
