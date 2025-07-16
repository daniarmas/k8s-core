# On-Premise Kubernetes Cluster

This directory contains the configuration for deploying applications to the on-premise Kubernetes cluster using Helmfile and manifests.

## Prerequisites

- k3s cluster with default CNI (Flannel) and kube-proxy disabled
- Helmfile installed (`brew install helmfile`)
- Helm diff plugin installed (`helm plugin install https://github.com/databus23/helm-diff`)
- kubectl configured to access the cluster

## Installation

### 1. Deploy Entire Cluster
```bash
# From the project root
helmfile -f clusters/on-prem/helmfile.yaml apply
```

### 2. Apply the Cilium manifests

```bash
kubectl apply -f clusters/on-prem/manifests/cilium
```

## Applications Deployed

### Core Networking
- **[Cilium CNI](../../apps/cilium/README.md)** - eBPF-based networking with LoadBalancer IPAM and L2 announcements

<!-- ### Gateway & Ingress
- **[Gateway API](../../apps/gateway/README.md)** - Kubernetes Gateway API implementation
  - External traffic management
  - SSL termination

### Observability
- **[Monitoring Stack](../../apps/monitoring/README.md)** - Prometheus, Grafana, and alerting
  - Metrics collection
  - Dashboards and alerts

### Storage
- **[Persistent Storage](../../apps/storage/README.md)** - Local path provisioner
  - Dynamic volume provisioning -->