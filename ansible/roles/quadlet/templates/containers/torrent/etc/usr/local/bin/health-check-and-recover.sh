#!/usr/bin/env bash
# On container crash / kill qBittorrent the lockfile remains under
# the /config/qBittorrent/ directory blocking container restart.
# I didn't find option to change location of the lockfile to a non-persistent
# place.
# The script checks if the lockfile exists, if PID (first line in the file) points
# to an existing process and if not - removes broken lock file and exits with non-zero status,
# container will be killed and recreated.

set -euo pipefail

PORT=${1:?missing}
LOCKFILE=/config/qBittorrent/lockfile


is_webui_alive() {
  curl --fail --silent "http://localhost:${PORT}" >/dev/null
}


if ! [ -f "$LOCKFILE" ]; then
  is_webui_alive
  exit 0
fi


PID=$(sed '1q;d' "$LOCKFILE")
if ! kill -0 "$PID" 2>/dev/null; then
  rm -- "$LOCKFILE"
  exit 2
else
  is_webui_alive
  exit 0
fi
