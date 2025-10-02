#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault policy write grafana - <<EOF
# Allow reading grafana secrets
path "secret/data/grafana/*" {
  capabilities = ["read"]
}

path "secret/metadata/grafana/*" {
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