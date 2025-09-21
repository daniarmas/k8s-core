#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault write auth/kubernetes/role/cert-manager \
    bound_service_account_names=cert-manager \
    bound_service_account_namespaces=cert-manager \
    policies=cert-manager \
    ttl=24h