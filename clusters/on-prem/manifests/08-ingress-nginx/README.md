# Ingress-Nginx

Ingress-Nginx is a Kubernetes Ingress controller that manages external access to services within your cluster, typically via HTTP and HTTPS. It provides advanced routing, SSL termination, and other features to help expose and secure your applications.

## Installation

### 1. Install Ingress-Nginx
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=ingress-nginx apply
```

### 2. Apply the vault ingress
```bash
kubectl apply -f clusters/on-prem/manifests/06-ingress-nginx/vault/01-ingress.yaml
```