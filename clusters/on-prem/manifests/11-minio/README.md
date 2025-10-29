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

### 4. Create the MinIO API TLS Certificate
```bash
kubectl apply -f clusters/on-prem/manifests/11-minio/02-minio-api-internal-certificate.yaml
```

### 5. Deploy the minio tenant
```bash
kubectl apply -f clusters/on-prem/manifests/11-minio/03-tenant.yaml
```

### 6. Deploy the minio service
```bash
kubectl apply -f clusters/on-prem/manifests/11-minio/04-minio-service.yaml
```

### 7. Deploy the ingresses
```bash
kubectl apply -f clusters/on-prem/manifests/11-minio/05-ingresses.yaml
```