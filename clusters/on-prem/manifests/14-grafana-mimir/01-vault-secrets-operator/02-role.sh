#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault write auth/kubernetes/role/mimir \
    bound_service_account_names=mimir-sa \
    bound_service_account_namespaces=grafana-mimir \
    policies=mimir \
    ttl=24h