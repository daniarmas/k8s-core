# Vault Secrets Operator

The Vault Secrets Operator (VSO) is a Kubernetes operator that manages the lifecycle of secrets from HashiCorp Vault. It automatically synchronizes secrets from Vault into Kubernetes secrets, providing a secure and automated way to manage sensitive data in your cluster.

## Key Features

- **Automatic Secret Synchronization**: Automatically creates and updates Kubernetes secrets from Vault
- **Multiple Secret Types**: Supports static secrets (KV), dynamic secrets (databases), and PKI certificates
- **Declarative Management**: Use custom resources to define which secrets to sync
- **Auto-Refresh**: Automatically refreshes secrets based on configured intervals
- **Kubernetes Native**: Integrates seamlessly with Kubernetes RBAC and service accounts
- **Multi-Tenant**: Supports multiple Vault connections and authentication methods per namespace
- **Rollout Integration**: Automatically restart deployments when secrets change


## Setup

### 1. Install Vault Secrets Operator using Helmfile
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=vault-secrets-operator apply
```

### 2. Create policy for the operator
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

### 3. Create a role for the operator
```bash
vault write auth/kubernetes/role/vault-secrets-operator \
    bound_service_account_names=vault-secrets-operator \
    bound_service_account_namespaces=vault-secrets-operator-system \
    policies=vault-secrets-operator \
    ttl=24h
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