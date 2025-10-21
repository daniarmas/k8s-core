#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault policy write harbor-app - <<EOF
# Allow reading harbor secrets
path "secret/data/registry/harbor/app/*" {
  capabilities = ["read"]
}

path "secret/metadata/registry/harbor/app/*" {
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