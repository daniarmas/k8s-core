# On-Premise Kubernetes Cluster

This directory contains the configuration for deploying applications to the on-premise Kubernetes cluster using Helmfile and manifests.

## Prerequisites

- k3s cluster
- Helmfile installed (`brew install helmfile`)
- Helm diff plugin installed (`helm plugin install https://github.com/databus23/helm-diff`)

## Installation

### 1. [Cilium](./manifests/01-cilium/README.md)

### 2. [Longhorn](./manifests/02-longhorn/README.md)

### 3. [MetalLB](./manifests/03-metallb/README.md)

### 4. [Ingress Nginx](./manifests/04-ingress-nginx/README.md)

### 5. [Vault](./manifests/05-vault/README.md)

### 6. [Vault Secrets Operator](./manifests/06-vault-secrets-operator/README.md)

### 7. [Cert Manager](./manifests/07-cert-manager/README.md)

### 8. [Gateway](./manifests/08-gateway/README.md)

### 7. [Cloud Native PG](./manifests/09-cnpg/README.md)

## Applications Deployed

### Networking
- **CNI**: [Cilium](./manifests/cilium/README.md)
- **LoadBalancer Controller**: [Cilium](./manifests/cilium/README.md)
- **Gateway API**: [Cilium](./manifests/gateway/README.md)

### Storage
- **Block Storage**: [Longhorn](./manifests/longhorn/README.md)
  
### Security & PKI
- **Certificate Manager**: [Cert-Manager](./manifests/cert-manager/README.md)
- **Secret Managment**: [Vault](./manifests/vault/README.md) & [Vault Secrets Operator](./manifests/vault-secrets-operator/README.md)