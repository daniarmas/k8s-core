#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault policy write core-api-postgres - <<EOF
# Allow reading postgres secrets
path "secret/data/core-api/postgres" {
  capabilities = ["read"]
}

path "secret/metadata/core-api/postgres" {
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