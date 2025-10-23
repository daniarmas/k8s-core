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
    REGISTRY_STORAGE_S3_ACCESSKEY="changeme" \
    REGISTRY_STORAGE_S3_SECRETKEY="changeme"
```

### 3. Create the Harbor application configuration in Vault
```bash
vault kv put secret/registry/harbor/app/configuration bucket_name="harbor" s3_endpoint="https://minio.minio-tenant.svc.cluster.local:443" harbor_admin_password="HarborAdmin123\!" secret_key="$SECRET_KEY" csrf_key="$CSRF_KEY" database_password="HarborDB123\!"
```

### 4. Export the internal CA certificate
```bash
kubectl get configmap internal-ca-bundle -n kube-system -o jsonpath='{.data.ca-bundle\.crt}' > internal-ca-chain.pem
```

### 5. Create the Harbor internal CA secret
```bash
kubectl create secret generic harbor-internal-ca \
  --from-file=ca.crt=internal-ca-chain.pem \
  -n harbor
```

### 6. Apply the Harbor certificate manifest
```bash
kubectl apply -f clusters/on-prem/manifests/11-harbor/02-certificate.yaml
```

### 6. Install the operator
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=harbor apply
```