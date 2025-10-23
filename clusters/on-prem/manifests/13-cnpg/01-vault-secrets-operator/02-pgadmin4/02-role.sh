#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault write auth/kubernetes/role/harbor-pgadmin4 \
    bound_service_account_names=harbor-pgadmin4 \
    bound_service_account_namespaces=harbor \
    policies=harbor-pgadmin4 \
    ttl=24h