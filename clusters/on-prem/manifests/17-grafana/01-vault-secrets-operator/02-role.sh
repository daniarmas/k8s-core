#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault write auth/kubernetes/role/grafana \
    bound_service_account_names=grafana-vault-sa \
    bound_service_account_namespaces=grafana \
    policies=grafana \
    ttl=24h