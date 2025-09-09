# CloudNative-PG

CloudNative-PG is a Kubernetes operator that covers the full lifecycle of a PostgreSQL database cluster with a primary/standby architecture, using native streaming replication.

## Installation

### 1. Install the operator
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=cnpg apply
```