#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault policy write grafana-loki-configuration - <<EOF
# Allow reading grafana-loki secrets
path "secret/data/grafana-loki/app/configuration" {
  capabilities = ["read"]
}

path "secret/metadata/grafana-loki/app/configuration" {
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