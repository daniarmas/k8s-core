#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault write auth/kubernetes/role/prometheus \
    bound_service_account_names=prometheus-vault-sa \
    bound_service_account_namespaces=prometheus \
    policies=prometheus \
    ttl=24h