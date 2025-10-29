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

### 4. Apply the Harbor certificate manifest
```bash
kubectl apply -f clusters/on-prem/manifests/12-harbor/02-certificate.yaml
```

### 5. Install Harbor
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=harbor apply
```
---

## Uninstallation

### 1. Uninstall Harbor via Helmfile
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=harbor destroy
```

### 2. Delete PersistentVolumeClaims
Harbor PVCs are retained by default to prevent data loss. Delete them manually:
```bash
# List Harbor PVCs
kubectl get pvc -n harbor

# Delete all PVCs in the harbor namespace
kubectl delete pvc -n harbor --all
```

### 3. Clean Up Detached Volumes

After deleting PVCs, PersistentVolumes may remain in a "Released" state (orphaned/detached). Clean them up:

#### Option A: Delete All Released PVs
```bash
# Review orphaned PVs first
kubectl get pv | grep Released

# Delete all Released PVs
kubectl get pv | grep Released | awk '{print $1}' | xargs kubectl delete pv
```

#### Option B: Delete Harbor-Specific Released PVs
```bash
# List Released PVs that were bound to Harbor
kubectl get pv | grep harbor | grep Released

# Delete them
kubectl get pv | grep harbor | grep Released | awk '{print $1}' | xargs kubectl delete pv
```

#### Option C: Force Delete Stuck PVs
If PVs are stuck in "Terminating" state:
```bash
# Remove finalizers to force deletion
kubectl get pv | grep Released | awk '{print $1}' | xargs -I {} kubectl patch pv {} -p '{"metadata":{"finalizers":null}}'
```

### 4. Delete Namespace (Optional)
```bash
kubectl delete namespace harbor
```

### 5. Clean Up Vault Secrets (Optional)
```bash
# Remove Harbor secrets from Vault
vault kv delete secret/s3/minio/access-keys/harbor
vault kv delete secret/registry/harbor/app/configuration
```

---

## Verification

### Check Harbor Status
```bash
# Check pods
kubectl get pods -n harbor

# Check services
kubectl get svc -n harbor

# Check ingress
kubectl get ingress -n harbor
```

### Check Storage
```bash
# List PVCs
kubectl get pvc -n harbor

# List PVs bound to Harbor
kubectl get pv | grep harbor

# Check for orphaned PVs
kubectl get pv | grep Released
```

### Access Harbor UI
```
URL: https://harbor.yourdomain.com
Username: admin
Password: [from Vault secret]
```

---
## Troubleshooting

### PVs Not Deleting
If PersistentVolumes remain after cleanup:
```bash
# Check PV status
kubectl get pv -o wide

# Check PV details
kubectl describe pv 

# If stuck, remove finalizers
kubectl patch pv  -p '{"metadata":{"finalizers":null}}'
```

### Harbor Pods Not Starting
Check storage availability:
```bash
# Check PVC status
kubectl get pvc -n harbor

# Check events
kubectl get events -n harbor --sort-by='.lastTimestamp'

# Check pod logs
kubectl logs -n harbor 
```

### Storage Backend Issues
Verify MinIO connectivity:
```bash
# Test MinIO endpoint
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl -k https://minio.minio-tenant.svc.cluster.local:443

# Check Harbor registry configuration
kubectl get configmap -n harbor harbor-core -o yaml | grep -A 10 storage
```