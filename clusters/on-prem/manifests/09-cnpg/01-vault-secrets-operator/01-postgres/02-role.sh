#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault write auth/kubernetes/role/harbor-postgres \
    bound_service_account_names=harbor \
    bound_service_account_namespaces=harbor \
    policies=harbor-postgres \
    ttl=24h