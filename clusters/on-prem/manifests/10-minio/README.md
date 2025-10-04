# MinIO

MinIO is a high-performance, open-source object storage solution compatible with Amazon S3 APIs. It is designed for storing unstructured data such as photos, videos, log files, backups, and container images. MinIO is commonly used for building scalable storage infrastructure in cloud-native environments.

## Installation

### 1. Install MinIO Operator
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=minio apply
```

### 2. Create the storage configuration secret
```bash
vault kv put secret/minio/storage-configuration \
  MINIO_ROOT_USER=changeme \
  MINIO_ROOT_PASSWORD=changeme \
  MINIO_STORAGE_CLASS_STANDARD="EC:2" \
  MINIO_BROWSER=on
```

### 3. Create the minio console secret
```bash
vault kv put secret/minio/minio-console-credentials \
  CONSOLE_ACCESS_KEY=changeme \
  CONSOLE_SECRET_KEY=changeme
```

### 4. Deploy the minio tenant
```bash
kubectl apply -f clusters/on-prem/manifests/20-minio/02-tenant-base.yaml
```

### 5. Deploy the ingresses
```bash
kubectl apply -f clusters/on-prem/manifests/20-minio/03-ingresses.yaml
```