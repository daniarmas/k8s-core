# Prometheus

Prometheus is an open-source monitoring and alerting toolkit designed for reliability and scalability. It collects metrics from configured targets, stores them efficiently, and provides powerful querying capabilities for analysis and visualization.

## Installation

### 1. Create the grafana-credentials secret
```bash
vault kv put secret/prometheus/grafana-credentials admin-user="changeme" admin-password="changeme"
```

### 2. Create the grafana secret for oauth2
```bash
vault kv put secret/prometheus/grafana-google-oauth GOOGLE_CLIENT_ID="changeme" GOOGLE_CLIENT_SECRET="changeme"
```

### 3. Install Prometheus CRDs
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=prometheus-crds apply
```

### 4. Install Prometheus
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=prometheus apply
```