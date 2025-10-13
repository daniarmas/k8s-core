#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault write auth/kubernetes/role/grafana-mimir-configuration \
    bound_service_account_names=mimir-sa \
    bound_service_account_namespaces=grafana-mimir \
    policies=grafana-mimir-configuration \
    ttl=24h