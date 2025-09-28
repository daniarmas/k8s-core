# Prometheus

Prometheus is an open-source monitoring and alerting toolkit designed for reliability and scalability. It collects metrics from configured targets, stores them efficiently, and provides powerful querying capabilities for analysis and visualization.

## Installation

### 2. Install Prometheus
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=prometheus apply
```