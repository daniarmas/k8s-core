#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

vault write auth/kubernetes/role/harbor-crunchy-postgres-pgadmin \
    bound_service_account_names=crunchy-postgres-pgadmin \
    bound_service_account_namespaces=harbor \
    policies=crunchy-postgres-pgadmin \
    ttl=24h