#!/usr/bin/env bash

. ./.env

if test -z "$1" || test -z "$2"; then
  echo "Usage: create-nfs-vol.sh <share> <name>"
  echo "Example: create-nfs-vol.sh /volume1/Download download"
  echo "Tip: to get <share>, run showmounts -e ${NFS_SERVER}"
  exit 1
fi
share=${1}
name=${2}

podman volume create \
  --driver local \
  --opt type=nfs \
  --opt "o=addr=${NFS_SERVER},rw,nfsvers=4" \
  --opt "device=:$share" \
  "$name"
