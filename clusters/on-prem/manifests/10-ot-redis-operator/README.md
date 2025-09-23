# Redis-Operator (OpsTree)

The OpsTree Redis Operator automates the deployment and management of Redis clusters on Kubernetes. It streamlines tasks such as provisioning, scaling, and updating Redis instances, helping ensure high availability and reliability for your applications.

## Installation

### 1. Install the operator
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=ot-redis-operator apply
```

### 2. Create the redis standalone
```bash
kubectl apply -f clusters/on-prem/manifests/10-ot-redis-operator/01-redis/01-redis-standalone.yaml
```

### 3. Apply the RedisInsight deployment
```bash
kubectl apply -f clusters/on-prem/manifests/10-ot-redis-operator/02-redis-insight/01-deployment.yaml
```