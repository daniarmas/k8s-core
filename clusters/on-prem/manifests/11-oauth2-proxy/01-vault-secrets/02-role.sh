#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault write auth/kubernetes/role/oauth2-proxy \
    bound_service_account_names=oauth2-proxy-secret \
    bound_service_account_namespaces=oauth2-proxy \
    policies=oauth2-proxy \
    ttl=24h