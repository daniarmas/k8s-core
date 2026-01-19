# CloudNative-PG

CloudNative-PG is a Kubernetes operator that covers the full lifecycle of a PostgreSQL database cluster with a primary/standby architecture, using native streaming replication.

## Installation

### 1. Create the namespace
```bash
kubectl create namespace cnpg
```

### 2. Install the operator
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=cnpg apply
```

### 3. Create core-api-postgres secret
```bash
vault kv put secret/core-api/postgres username="app" password="changeme"
```

### 4. Setup the vault secrets

### 5. Create the postgresql cluster for core-api
```bash
kubectl apply -f clusters/on-prem/manifests/13-cnpg/02-cluster.yaml
```

### 6. Create the pgadmin4 vault secret (replace values)
```bash
vault kv put secret/harbor/pgadmin4 email="changeme@email.com" password="changeme"
```

### 7. Apply the pgadmin4 manifests
```bash
kubectl apply -f clusters/on-prem/manifests/09-cnpg/03-pgadmin4/.
```