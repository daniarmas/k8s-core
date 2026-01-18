# K8s Monitoring

This directory contains the configuration for monitoring Kubernetes clusters using Grafana stack. It provides observability through metrics collection, logging, and tracing with Grafana Alloy as the telemetry collector.

## Installation

### 1. Install the K8s Monitoring
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=k8s-monitoring apply
```