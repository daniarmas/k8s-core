#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault policy write mimir - <<EOF
# Allow reading mimir secrets
path "secret/data/mimir" {
  capabilities = ["read"]
}

path "secret/metadata/mimir" {
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