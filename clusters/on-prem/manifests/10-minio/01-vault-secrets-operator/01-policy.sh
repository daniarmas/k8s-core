#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault policy write minio-app - <<EOF
# Allow reading minio secrets
path "secret/data/s3/minio/app/*" {
  capabilities = ["read"]
}

path "secret/metadata/s3/minio/app/*" {
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

vault policy write harbor-minio-accesskeys - <<EOF
# Allow reading minio secrets
path "secret/data/s3/minio/access-keys/harbor" {
  capabilities = ["read"]
}

path "secret/metadata/s3/minio/access-keys/harbor" {
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

vault policy write grafana-mimir-minio-accesskeys - <<EOF
# Allow reading minio secrets
path "secret/data/s3/minio/access-keys/grafana-mimir" {
  capabilities = ["read"]
}

path "secret/metadata/s3/minio/access-keys/grafana-mimir" {
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