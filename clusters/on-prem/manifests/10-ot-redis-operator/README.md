# Redis-Operator (OpsTree)

The OpsTree Redis Operator automates the deployment and management of Redis clusters on Kubernetes. It streamlines tasks such as provisioning, scaling, and updating Redis instances, helping ensure high availability and reliability for your applications.

## Installation

### 2. Install the operator
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=ot-redis-operator apply
```