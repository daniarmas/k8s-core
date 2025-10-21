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

### 4. [Cert Manager](./manifests/04-cert-manager/README.md)

### 5. [Ingress Nginx](./manifests/05-ingress-nginx/README.md)

### 6. [Gateway](./manifests/06-gateway/README.md)

### 7. [Vault](./manifests/07-vault/README.md)

### 8. [Internal PKI](./manifests/08-internal-pki/README.md)

### 9. [Vault Secrets Operator](./manifests/09-vault-secrets-operator/README.md)

### 10. [MinIO](./manifests/10-minio/README.md)

### 11. [Harbor](./manifests/11-harbor/README.md)

### 12. [Cnpg](./manifests/12-cnpg/README.md)

### 14. [Ot Redis Operator](./manifests/14-ot-redis-operator/README.md)

### 17. [Grafana Mimir](./manifests/17-grafana-mimir/README.md)

### 18. [Grafana Operator](./manifests/18-grafana-operator/README.md)

### 19. [Prometheus](./manifests/19-prometheus/README.md)

### 20. [Grafana Loki](./manifests/20-grafana-loki/README.md)

### 21. [Grafana Alloy](./manifests/21-grafana-alloy/README.md)

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