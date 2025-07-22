# Cilium CNI

eBPF-based networking for Kubernetes with LoadBalancer IPAM, L2 announcements, and Hubble observability.

## Network Configuration

| Component | Description |
|-----------|-------------|
| **Pod CIDR** | `10.10.0.0/16` - IP range for pod networking |
| **LoadBalancer IPAM** | Automatic IP allocation from defined pools |
| **L2 Announcements** | ARP/NDP advertisement for external connectivity |

## Installation

### 1. Install Cilium CLI
Follow the [official installation guide](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/).

**macOS:**
```bash
brew install cilium-cli
```

### 2. Install Hubble CLI
Follow the [Hubble setup guide](https://docs.cilium.io/en/stable/observability/hubble/setup/).

**macOS:**
```bash
brew install hubble
```

### 3. Install Cilium via Helmfile
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=cilium apply
```

### 4: Apply Cilium manifests
```bash
kubectl apply -f clusters/on-prem/manifests/cilium .
```

> **Note:** These manifests set up LoadBalancer IPAM and L2 Announcements.

## Hubble UI
```bash
cilium hubble ui
```

## Verification Commands

### Cilium Status
```bash
# Check Cilium status
cilium status --wait

# Check Cilium agent health
kubectl exec -n kube-system ds/cilium -- cilium-health status

# Check connectivity
cilium connectivity test
```

### LoadBalancer IPAM
```bash
# View LoadBalancer IP pools
kubectl get ciliumloadbalancerippools -A

# Check LoadBalancer service status
kubectl get svc -o wide | grep LoadBalancer

# Describe IP pool details
kubectl describe ciliumloadbalancerippools
```

### L2 Announcements
```bash
# Check L2 announcement policies
kubectl get ciliuml2announcementpolicies -A

# View L2 announcement status
kubectl logs -n kube-system ds/cilium | grep -i l2

# Check ARP table on nodes
kubectl exec -n kube-system ds/cilium -- ip neigh show
```

### Network Policies
```bash
# List Cilium network policies
kubectl get ciliumnetworkpolicies -A

# List Kubernetes network policies
kubectl get networkpolicies -A

# Check policy enforcement
cilium policy get
```

## Troubleshooting

### Common Issues

**L2 Announcements Not Working:**
```bash
# Check network interface configuration
kubectl get nodes -o wide

# Verify interface in values file matches actual interface
kubectl exec -n kube-system ds/cilium -- ip addr show

# Check L2 announcement logs
kubectl logs -n kube-system ds/cilium | grep -i "l2\|announce"
```

**Connectivity Issues:**
```bash
# Check Cilium agent logs
kubectl logs -n kube-system ds/cilium -f

# Verify node connectivity
cilium node list

# Test pod-to-pod connectivity
cilium connectivity test

# Check datapath status
cilium bpf endpoint list
```

## References

- [Cilium Documentation](https://docs.cilium.io/)
- [Cilium Getting Started](https://docs.cilium.io/en/latest/gettingstarted/)
- [Cilium LoadBalancer IPAM](https://docs.cilium.io/en/latest/network/lb-ipam/)
- [Cilium L2 Announcements](https://docs.cilium.io/en/latest/network/l2-announcements/)
- [Hubble Documentation](https://docs.cilium.io/en/latest/observability/hubble/)
- [Cilium Network Policies](https://docs.cilium.io/en/latest/security/policy/)
- [Cilium Service Mesh](https://docs.cilium.io/en/latest/network/servicemesh/)