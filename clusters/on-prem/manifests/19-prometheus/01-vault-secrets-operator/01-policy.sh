#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault policy write prometheus - <<EOF
# Allow reading prometheus secrets
path "secret/data/prometheus/*" {
  capabilities = ["read"]
}

path "secret/metadata/prometheus/*" {
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