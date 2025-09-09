#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault policy write crunchy-postgres-pgadmin - <<EOF
# Allow reading crunchy-postgres-pgadmin secrets
path "secret/data/harbor/crunchy-postgres/pgadmin/*" {
  capabilities = ["read"]
}

path "secret/metadata/harbor/crunchy-postgres/pgadmin/*" {
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