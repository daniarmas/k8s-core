# Harbor Registry

Harbor is an open-source container registry that secures images with role-based access control, vulnerability scanning, and image replication. It provides a robust solution for storing, managing, and serving container images in Kubernetes environments.

## Installation

### 1. Create the namespace
```bash
kubectl create namespace harbor
```

### 2. Install the operator
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=harbor apply
```