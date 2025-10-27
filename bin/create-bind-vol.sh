#!/usr/bin/env sh

src=${1}
name=${2}

if test -z "$src" || test -z "$name"; then
  echo "Usage: $0 <src> <name>"
  echo "Example: $0 /media media"
  exit 1
fi

podman volume create -o device="${src}" -o=o=bind "${name}"
