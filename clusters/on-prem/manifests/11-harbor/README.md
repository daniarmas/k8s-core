# Harbor Registry

Harbor is an open-source container registry that secures images with role-based access control, vulnerability scanning, and image replication. It provides a robust solution for storing, managing, and serving container images in Kubernetes environments.

## Installation

### 1. Create the namespace
```bash
kubectl create namespace harbor
```

### 2. Create the MinIO access keys secret
```bash
vault kv put secret/s3/minio/access-keys/harbor \
    access_key_id="changeme" \
    secret_access_key="changeme"
```

### 3. Create the Harbor application configuration in Vault
```bash
vault kv put secret/registry/harbor/app/configuration \
    bucket_name="changeme"
```

### 4. Install the operator
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=harbor apply
```