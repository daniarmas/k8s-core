# Grafana Mimir

Grafana Mimir is an open source, horizontally scalable, and highly available long-term storage solution for Prometheus metrics. It enables efficient querying, retention, and management of large-scale time series data.

## Installation

### 1. Create the namespace
```bash
kubectl create namespace observability
```

### 2. Install the operator
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=harbor apply
```