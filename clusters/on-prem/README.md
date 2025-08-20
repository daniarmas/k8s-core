# On-Premise Kubernetes Cluster

This directory contains the configuration for deploying applications to the on-premise Kubernetes cluster using Helmfile and manifests.

## Prerequisites

- k3s cluster with default CNI (Flannel) and kube-proxy disabled
- Helmfile installed (`brew install helmfile`)
- Helm diff plugin installed (`helm plugin install https://github.com/databus23/helm-diff`)
- kubectl configured to access the cluster

## Installation

### 1. [Cilium](./manifests/cilium/README.md)

### 2. [Longhorn](./manifests/longhorn/README.md)

### 3. [Vault](./manifests/vault/README.md)

> ⚠️ **Note**: OIDC Auth with Google Sign needs a fully functional Gateway deployment.

### 4. [Vault Secrets Operator](./manifests/vault-secrets-operator/README.md)

### 5. [Cert Manager](./manifests/cert-manager/README.md)

### 6. [Gateway](./manifests/gateway/README.md)

## Applications Deployed

### Networking
- **CNI**: [Cilium](./manifests/cilium/README.md)
- **LoadBalancer Controller**: [Cilium](./manifests/cilium/README.md)
- **Gateway API Controller**: [Cilium](./manifests/gateway/README.md)

### Storage
- **Block Storage**: [Longhorn](./manifests/longhorn/README.md)
  
### Security & PKI
- **Certificate Manager**: [Cert-Manager](./manifests/cert-manager/README.md)