# MetalLB

MetalLB is a load-balancer implementation for Kubernetes clusters running on-premises. It provides network load balancing using standard protocols, enabling external access to services in environments that do not have built-in cloud load balancers.

## Installation

### 1. Install Ingress-Nginx
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=metallb apply
```

### 2. Apply the address pool
```bash
kubectl apply -f clusters/on-prem/manifests/03-metallb/01-address-pool.yaml
```

### 3. Apply the L2 Advertisement
```bash
kubectl apply -f clusters/on-prem/manifests/03-metallb/02-l2-advertisement.yaml
```