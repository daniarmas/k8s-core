# Grafana-Operator

Grafana-Operator is an open-source Kubernetes operator that automates the deployment, management, and configuration of Grafana instances. It simplifies the process of provisioning dashboards, data sources, and alerting rules within a Kubernetes environment.

## Installation

### 1. Install Grafana-Operator
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=grafana-operator apply
```