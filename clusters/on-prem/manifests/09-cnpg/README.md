# CloudNative-PG

CloudNative-PG is a Kubernetes operator that covers the full lifecycle of a PostgreSQL database cluster with a primary/standby architecture, using native streaming replication.

## Installation

### 1. Install the operator
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=cnpg apply
```

### 2. Create the postgresql cluster for harbor
```bash
kubectl apply -f clusters/on-prem/manifests/09-cnpg/01-cluster.yaml
```

### 3. Create the pgadmin4 vault secret (replace values)
```bash
vault kv put secret/harbor/pgadmin4 email="changeme@email.com" password="changeme"
```

### 4. Apply the pgadmin4 manifests
```bash
kubectl apply -f clusters/on-prem/manifests/09-cnpg/02-pgadmin4/.
```