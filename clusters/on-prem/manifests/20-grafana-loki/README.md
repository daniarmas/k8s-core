# Grafana Loki

Grafana Loki is an open source, horizontally scalable, and highly available log aggregation system inspired by Prometheus. It efficiently stores and queries logs, making it easy to correlate logs with metrics for observability at scale.

## Installation

### 1. Install the Grafana Loki
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=grafana-loki apply
```