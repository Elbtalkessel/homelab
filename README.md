# Home Server Infrastructure 🚀

A set of quadlet services

## Overview

- config/containers/systemd: available services.
- config/containers/: local configuration files, directory name = service (or service group) name.
- devops/: butane and ansible.

## Things to do

- Put scripts from devenv.nix (igniter, syncup, etc.) to the bin/ directory.
- Invidious
  - Update companion to use yaml configs instead of env var.
  - How can we store secrets (such as companion key) not in plain text?
  - Continue work on updating UI and change Image= to custom one.
- Backups: borg or something similar. Backup to an NFS mount, preferrable with UI.
- Disable sudo for risus.
- Automate symlinking `ln -s /var/home/risus/.config/containers/systemd/https.socket /var/home/risus/.config/systemd/user`,
  or update the `syncup` script.
