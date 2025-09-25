# Vault Secrets Operator

The Vault Secrets Operator (VSO) is a Kubernetes operator that manages the lifecycle of secrets from HashiCorp Vault. It automatically synchronizes secrets from Vault into Kubernetes secrets, providing a secure and automated way to manage sensitive data in your cluster.

## Installation

### 1. Create policy for the operator
```bash
vault policy write vault-secrets-operator - <<EOF
# Allow reading secrets
path "secret/data/*" {
  capabilities = ["read"]
}

path "secret/metadata/*" {
  capabilities = ["read", "list"]
}

# Allow token operations
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}
EOF
```

### 2. Create a role for the operator
```bash
vault write auth/kubernetes/role/vault-secrets-operator \
    bound_service_account_names=vault-secrets-operator \
    bound_service_account_namespaces=vault-secrets-operator-system \
    policies=vault-secrets-operator \
    ttl=24h
```

### 3. Install Vault Secrets Operator using Helmfile
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=vault-secrets-operator apply
```

## References

### Official Documentation
- [Vault Secrets Operator Documentation](https://developer.hashicorp.com/vault/docs/platform/k8s/vso)
- [Vault Secrets Operator Helm Chart](https://github.com/hashicorp/vault-secrets-operator/tree/main/chart)
- [Vault Secrets Operator GitHub Repository](https://github.com/hashicorp/vault-secrets-operator)

### Custom Resources
- [VaultConnection API Reference](https://developer.hashicorp.com/vault/docs/platform/k8s/vso/api-reference#vaultconnection)
- [VaultAuth API Reference](https://developer.hashicorp.com/vault/docs/platform/k8s/vso/api-reference#vaultauth)
- [VaultStaticSecret API Reference](https://developer.hashicorp.com/vault/docs/platform/k8s/vso/api-reference#vaultstaticsecret)
- [VaultDynamicSecret API Reference](https://developer.hashicorp.com/vault/docs/platform/k8s/vso/api-reference#vaultdynamicsecret)

### Tutorials and Examples
- [Getting Started with VSO](https://developer.hashicorp.com/vault/tutorials/kubernetes/vault-secrets-operator)
- [VSO Examples Repository](https://github.com/hashicorp/vault-secrets-operator/tree/main/config/samples)
- [Static Secrets Tutorial](https://developer.hashicorp.com/vault/tutorials/kubernetes/vault-secrets-operator-kv)

### Troubleshooting
- [VSO Troubleshooting Guide](https://developer.hashicorp.com/vault/docs/platform/k8s/vso/troubleshooting)
- [Common Issues and Solutions](https://github.com/hashicorp/vault-secrets-operator/blob/main/docs/troubleshooting.md)