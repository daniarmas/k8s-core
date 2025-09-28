# Grafana Mimir

Grafana Mimir is an open source, horizontally scalable, and highly available long-term storage solution for Prometheus metrics. It enables efficient querying, retention, and management of large-scale time series data.

## Installation

### 1. Create the vault secret
```bash
vault kv put secret/mimir bucket_name="app" endpoint="changeme" access_key_id="changeme" secret_access_key="changeme"
```

### 2. Install the Grafana Mimir
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=mimir apply
```