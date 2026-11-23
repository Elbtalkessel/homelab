#!/bin/sh
# Generate a Playwright MCP config that scopes TLS error suppression to the
# Homelab step-ca certificate authority. Chromium honors
# --ignore-certificate-errors-spki-list for certificates whose chain contains
# a pinned SPKI, so this is narrower than blanket --ignore-https-errors.
#
# We pin every CA certificate in the shared step-ca volume, not just the root.
# Servers typically present the intermediate CA (not the root), so pinning only
# root_ca.crt would not match the chain Chromium sees during verification.
set -e

apk add --no-cache openssl

spki_list=""
for cert in /certs/*.crt; do
  [ -f "$cert" ] || continue
  spki=$(openssl x509 -pubkey -noout -in "$cert" \
    | openssl pkey -pubin -outform der \
    | openssl dgst -sha256 -binary \
    | base64)
  if [ -n "$spki_list" ]; then
    spki_list="${spki_list},${spki}"
  else
    spki_list="$spki"
  fi
done

if [ -z "$spki_list" ]; then
  echo "No CA certificates found in /certs" >&2
  exit 1
fi

cat > /config/playwright-mcp.json <<EOF
{"browser":{"launchOptions":{"args":["--ignore-certificate-errors-spki-list=${spki_list}"]}}}
EOF

chmod 644 /config/playwright-mcp.json
