# Grafana

Grafana is an open-source analytics and monitoring platform that enables users to visualize, query, and analyze metrics from various data sources. It is commonly used for creating interactive dashboards and alerting on system performance.

## Installation

### 1. Create the grafana-credentials secret
```bash
vault kv put secret/grafana/grafana-credentials admin-user="changeme" admin-password="changeme"
```

### 2. Create the grafana secret for oauth2
```bash
vault kv put secret/grafana/grafana-google-oauth GOOGLE_CLIENT_ID="changeme" GOOGLE_CLIENT_SECRET="changeme"
```

### 3. Install Prometheus
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=grafana apply
```