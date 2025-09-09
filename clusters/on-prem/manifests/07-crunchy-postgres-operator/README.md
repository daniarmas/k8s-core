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
kubectl apply -f clusters/on-prem/manifests/07-crunchy-postgres-operator/manifests/01-harbor-cluster.yaml
```

### 2. Create the pgadmin secret at vault
```bash
vault kv put secret/harbor/crunchy-postgres/pgadmin email="changeme@email.com" password="changeme"
```
### 3. Create the pgadmin vault policy
```bash
sh clusters/on-prem/manifests/07-crunchy-postgres-operator/manifests/02-pgadmin-vault-policy.sh
```

### 3. Create the pgadmin vault role
```bash
sh clusters/on-prem/manifests/07-crunchy-postgres-operator/manifests/03-pgadmin-vault-role.sh
```

### 4. Apply the deployments
```bash
kubectl apply -f clusters/on-prem/manifests/07-crunchy-postgres-operator/manifests/04-pgadmin.yaml
```