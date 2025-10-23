#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault write auth/kubernetes/role/harbor-app \
    bound_service_account_names=harbor-vault-sa \
    bound_service_account_namespaces=harbor \
    policies=harbor-minio-accesskeys,harbor-app \
    ttl=24h