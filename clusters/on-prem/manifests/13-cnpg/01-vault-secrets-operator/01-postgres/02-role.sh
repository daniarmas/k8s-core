#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault write auth/kubernetes/role/core-api-postgres \
    bound_service_account_names=postgres \
    bound_service_account_namespaces=core-api \
    policies=core-api-postgres \
    ttl=24h