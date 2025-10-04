#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault policy write harbor-pgadmin4 - <<EOF
# Allow reading pgadmin4 secrets
path "secret/data/harbor/pgadmin4" {
  capabilities = ["read"]
}

path "secret/metadata/harbor/pgadmin4" {
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