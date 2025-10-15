# Grafana Alloy

Grafana Alloy is an open source, vendor-neutral telemetry collector designed for logs, metrics, and traces. It enables flexible data collection, processing, and forwarding, making it easier to integrate observability data from diverse sources into Grafana and other backends.

## Installation

### 1. Install the Grafana Loki
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=grafana-alloy apply
```