#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault policy write grafana-mimir-configuration - <<EOF
# Allow reading grafana-mimir secrets
path "secret/data/grafana-mimir/app/configuration" {
  capabilities = ["read"]
}

path "secret/metadata/grafana-mimir/app/configuration" {
  capabilities = ["read"]
}

# Allow token operations
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}
EOF