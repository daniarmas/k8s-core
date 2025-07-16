# Cilium CNI

eBPF-based networking for Kubernetes with LoadBalancer IPAM, L2 announcements, and Hubble observability.

## Features

- ✅ **Kube-proxy replacement** - eBPF-based service load balancing
- ✅ **LoadBalancer IPAM** - Automatic IP allocation for LoadBalancer services
- ✅ **L2 announcements** - ARP/NDP advertisement for LoadBalancer IPs
- ✅ **Gateway API support** - Kubernetes Gateway API implementation
- ✅ **Network policies** - Advanced network security policies
- ✅ **Hubble** - Network observability and security monitoring
- ✅ **Cluster mesh** - Multi-cluster networking capability

## Configuration Files

### `helmfile.yaml`
- Cilium Helm chart configuration
- Environment-specific values loading
- Chart version and repository definition

### `values/`
Environment-specific Cilium configurations:
- **`on-prem.yaml`** - On-premise settings with LoadBalancer pools and L2 announcements

## Network Configuration

| Component | Description |
|-----------|-------------|
| **Pod CIDR** | `10.10.0.0/16` - IP range for pod networking |
| **Service CIDR** | `10.43.0.0/16` - IP range for service networking |
| **LoadBalancer IPAM** | Automatic IP allocation from defined pools |
| **L2 Announcements** | ARP/NDP advertisement for external connectivity |

### Cilium CLI Installation

**macOS:**
```bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "arm64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-darwin-${CLI_ARCH}.tar.gz{,.sha256sum}
shasum -a 256 -c cilium-darwin-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-darwin-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-darwin-${CLI_ARCH}.tar.gz{,.sha256sum}
```

### Hubble CLI Installation

**macOS:**
```bash
brew install hubble
```

### LoadBalancer Service Example

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: default
  labels:
    app: nginx
spec:
  type: LoadBalancer
  loadBalancerClass: io.cilium/l2-announcer
  selector:
    app: nginx
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
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

**Hubble UI:**
```bash
cilium hubble ui
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