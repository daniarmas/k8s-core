# Overview

This repository contains the core Kubernetes applications required to run and manage a Kubernetes cluster in an on-premise environment, such as a Homelab.

## Project Structure

The project is organized for a single cluster:

### 🖥️ On-Premise Cluster
- **Environment**: Development, staging, and shared production workloads
- **Infrastructure**: Self-hosted k3s cluster
- **Networking**: Cilium CNI with LoadBalancer IPAM and L2 announcements
- **Use Cases**: Development, testing, staging, and some shared production workloads

> ⚠️ **Note**: The project is still a work in progress.