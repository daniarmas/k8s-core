# Crunchy Postgres Operator

The Crunchy Postgres Operator automates the deployment and management of PostgreSQL clusters on Kubernetes, providing high availability, backup, and monitoring capabilities.

## Installation

### 1. Install the operator
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=crunchy-postgres-operator apply
```

## Setup

### 1. Create the harbor cluster
```bash
kubectl apply -f clusters/on-prem/manifests/postgres-operator/manifests/01-harbor-cluster.yaml
```

