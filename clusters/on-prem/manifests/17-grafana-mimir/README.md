# Grafana Mimir

Grafana Mimir is an open source, horizontally scalable, and highly available long-term storage solution for Prometheus metrics. It enables efficient querying, retention, and management of large-scale time series data.

## Installation

### 1. Create the vault secret
```bash
vault kv put secret/grafana-mimir/app/configuration \
  common_storage_bucket_name="changeme" \
  alertmanager_storage_bucket_name="changeme" \
  ruler_storage_bucket_name="changeme" \
  endpoint="minio.minio-tenant.svc.cluster.local:443" \
  access_key_id="changeme" \
  secret_access_key="changeme"
```
### 2. Import the ca bundle as a secret
```bash
kubectl create secret generic internal-ca-bundle -n grafana-mimir \
  --from-file=ca.crt=<(kubectl get configmap internal-ca-bundle -n kube-system -o jsonpath='{.data.ca-bundle\.crt}') \
  --dry-run=client -o yaml | kubectl apply -f -
```

### 3. Create the internal certificate
```bash
kubectl apply -f clusters/on-prem/manifests/17-grafana-mimir/02-certificate.yaml
```

### 4. Install the Grafana Mimir
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=grafana-mimir apply
```