# Trust-Manager

Automatically distributes CA certificate bundles to all namespaces in a Kubernetes 
cluster. Syncs trusted root certificates from a source (Secret/ConfigMap) to target 
ConfigMaps/Secrets across namespaces, keeping them updated when the source changes. 
Works alongside cert-manager to provide a consistent trust store for workloads.

## Installation

### 1. Install Trust-Manager
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=trust-manager apply
```