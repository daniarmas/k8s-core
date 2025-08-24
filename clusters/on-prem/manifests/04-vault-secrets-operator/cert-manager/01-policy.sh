#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault policy write cert-manager - <<EOF
# Allow reading cert-manager secrets
path "secret/data/cert-manager/*" {
  capabilities = ["read"]
}

path "secret/metadata/cert-manager/*" {
  capabilities = ["read", "list"]
}

# Allow token operations
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}
EOF