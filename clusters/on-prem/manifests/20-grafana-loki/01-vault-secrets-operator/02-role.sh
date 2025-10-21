#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault write auth/kubernetes/role/grafana-loki-configuration \
    bound_service_account_names=loki-sa \
    bound_service_account_namespaces=grafana-loki \
    policies=grafana-loki-configuration \
    ttl=24h