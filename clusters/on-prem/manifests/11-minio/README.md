# MinIO

MinIO is a high-performance, open-source object storage solution compatible with Amazon S3 APIs. It is designed for storing unstructured data such as photos, videos, log files, backups, and container images. MinIO is commonly used for building scalable storage infrastructure in cloud-native environments.

## Installation

### 1. Install MinIO Operator
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=minio apply
```

### 2. Create the storage configuration secret
```bash
vault kv put secret/s3/minio/app/storage-configuration \
  MINIO_ROOT_USER=changeme \
  MINIO_ROOT_PASSWORD=changeme \
  MINIO_STORAGE_CLASS_STANDARD="EC:2" \
  MINIO_BROWSER=on
```

### 3. Create the minio console secret
```bash
vault kv put secret/s3/minio/app/minio-console-credentials \
  CONSOLE_ACCESS_KEY=changeme \
  CONSOLE_SECRET_KEY=changeme
```

### 4. Create the minio mc access keys secret
```bash
vault kv put secret/s3/minio/access-keys/minio-mc \
  access-key=changeme \
  secret-key=changeme
```

### 5. Configure Vault Secrets Operator
```bash
# Create Vault policies
sh ./clusters/on-prem/manifests/11-minio/01-vault-secrets-operator/01-policy.sh

# Create Vault roles  
sh ./clusters/on-prem/manifests/11-minio/01-vault-secrets-operator/02-role.sh

# Apply Kubernetes resources
kubectl apply -f clusters/on-prem/manifests/11-minio/01-vault-secrets-operator/03-vaultauth.yaml
kubectl apply -f clusters/on-prem/manifests/11-minio/01-vault-secrets-operator/04-secrets.yaml
```

### 6. Create the MinIO API TLS Certificate
```bash
kubectl apply -f clusters/on-prem/manifests/11-minio/02-minio-api-internal-certificate.yaml
```

### 7. Deploy the minio tenant
```bash
kubectl apply -f clusters/on-prem/manifests/11-minio/03-tenant.yaml
```

### 8. Deploy the minio service
```bash
kubectl apply -f clusters/on-prem/manifests/11-minio/04-minio-service.yaml
```

### 9. Deploy the ingresses
```bash
kubectl apply -f clusters/on-prem/manifests/11-minio/05-ingresses.yaml
```

### 10. Create buckets
```bash
kubectl apply -f clusters/on-prem/manifests/11-minio/06-bucket-creation-job.yaml
```

### 11. Create minio access keys
```bash
kubectl apply -f clusters/on-prem/manifests/11-minio/07-minio-access-keys.yaml
```