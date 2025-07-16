# k8s-core

This repository contains the core Kubernetes applications required to run and manage multiple Kubernetes clusters across different environments.

## Project Structure

The project is organized into two main clusters:

### 🖥️ [On-Premise Cluster](clusters/on-prem/README.md)
- **Environment**: Development, staging and shared production workloads
- **Infrastructure**: Self-hosted k3s cluster
- **Networking**: Cilium CNI with LoadBalancer IPAM and L2 announcements
- **Use Cases**: Development, test staging and share some production workloads

### ☁️ [DigitalOcean Cluster](clusters/digitalocean/README.md)
- **Environment**: Production workloads
- **Infrastructure**: Managed Kubernetes on DigitalOcean
- **Networking**: DigitalOcean infrastructure
- **Use Cases**: Production services, public-facing applications

### Multi-Cluster Management
```bash
# Switch between clusters
export KUBECONFIG=~/.kube/config-onprem
helmfile -f clusters/on-prem/helmfile.yaml apply

export KUBECONFIG=~/.kube/config-digitalocean
helmfile -f clusters/digitalocean/helmfile.yaml apply
```