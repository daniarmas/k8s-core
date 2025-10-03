#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault policy write minio - <<EOF
# Allow reading minio secrets
path "secret/data/minio/*" {
  capabilities = ["read"]
}

path "secret/metadata/minio/*" {
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