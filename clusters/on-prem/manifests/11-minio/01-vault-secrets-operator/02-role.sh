#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault write auth/kubernetes/role/minio-app \
    bound_service_account_names=minio-vault-sa \
    bound_service_account_namespaces=minio-tenant \
    policies=minio-app \
    ttl=24h