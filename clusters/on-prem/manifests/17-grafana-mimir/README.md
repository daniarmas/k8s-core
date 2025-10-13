# Grafana Mimir

Grafana Mimir is an open source, horizontally scalable, and highly available long-term storage solution for Prometheus metrics. It enables efficient querying, retention, and management of large-scale time series data.

## Installation

### 1. Create the vault secret
```bash
vault kv put secret/grafana-mimir/app/configuration \
  common_storage_bucket_name="changeme" \
  alertmanager_storage_bucket_name="changeme" \
  ruler_storage_bucket_name="changeme" \
  endpoint="nyc3.digitaloceanspaces.com" \
  access_key_id="changeme" \
  secret_access_key="changeme"
```

### 2. Create the internal pki certificate
```bash
kubectl apply -f clusters/on-prem/manifests/17-grafana-mimir/02-certificate.yaml
```

### 3. Install the Grafana Mimir
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=grafana-mimir apply
```