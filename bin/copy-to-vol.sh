#!/usr/bin/env bash

source="$1"
target="$2"
if test -z "$source" || test -z "$target"; then
  echo "Usage: copy-to-vol.sh <source> <target>"
  echo "Example: copy-to-vol.sh /mnt/data docker-vol-name"
  exit 1
fi
shift
shift
rest="$@"

podman run \
  --name copy-to-vol \
  --rm \
  -v "${source}:/source" \
  -v "${target}:/target" \
  busybox \
  sh -c "tar Ccvf - ${rest} /source | (cd /target; tar xfp -)"
  
