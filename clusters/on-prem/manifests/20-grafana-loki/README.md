# Grafana Loki

Grafana Loki is an open source, horizontally scalable, and highly available log aggregation system inspired by Prometheus. It efficiently stores and queries logs, making it easy to correlate logs with metrics for observability at scale.

## Installation

### 1. Create the vault secret
```bash
vault kv put secret/grafana-loki/app/configuration \
  chunks_storage_bucket_name="changeme" \
  admin_storage_bucket_name="changeme" \
  ruler_storage_bucket_name="changeme" \
  endpoint="minio.minio-tenant.svc.cluster.local:443" \
  access_key_id="changeme" \
  secret_access_key="changeme"
```

### 2. Install the Grafana Loki
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=grafana-loki apply
```