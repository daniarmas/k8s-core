# Gateway

Gateway API provides a modern, extensible way to manage ingress traffic in Kubernetes clusters. This setup configures Cilium as the Gateway controller, providing load balancing, TLS termination, and traffic routing capabilities for applications.

## Requirements

### 1. Install Gateway API CRDs
```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
```

### 2. Install TLSRoute (Optional - Experimental Feature)
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.3.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml
```

## Installation

### 1. Install gateway manifests
```bash
kubectl apply -f clusters/on-prem/manifests/06-gateway/.
```

## Verification Commands

### Check Gateway API CRDs Installation
```bash
# Verify Gateway API CRDs are installed
kubectl get crd | grep gateway.networking.k8s.io

# Expected output:
# gatewayclasses.gateway.networking.k8s.io
# gateways.gateway.networking.k8s.io
# httproutes.gateway.networking.k8s.io
```

### Check GatewayClass Status
```bash
# Check if GatewayClass is ready
kubectl get gatewayclass
kubectl describe gatewayclass cilium

# Expected status: Accepted = True
```

### Check Gateway Status
```bash
# Check Gateway status and IP assignment
kubectl get gateway cilium-gateway
kubectl describe gateway cilium-gateway

# Verify LoadBalancer IP is assigned
kubectl get svc -o wide | grep cilium-gateway
```

### Test HTTP to HTTPS Redirect
```bash
# Test HTTP redirect (replace with your actual IP)
curl -I http://<external-ip> -H "Host: hostname"

# Expected: HTTP/1.1 301 Moved Permanently
# Location: https://hostname/
```

### Test HTTPS Traffic
```bash
# Test HTTPS endpoint
curl -k -I https://<external-ip> -H "Host: hostname"

# Expected: HTTP/1.1 200 OK (if backend is running)
```

### Check HTTPRoute Status
```bash
# Verify HTTPRoute is accepted
kubectl get httproute nginx-route
kubectl describe httproute nginx-route

# Check route attachment to Gateway
kubectl get httproute nginx-route -o yaml | grep -A10 status
```

### Check Certificate Status
```bash
# Verify SSL certificate is ready
kubectl get certificate
kubectl describe certificate wildcard-home-cert

# Check certificate secret
kubectl get secret wildcard-home-tls
```

## Troubleshooting

### Gateway Not Getting IP Address
```bash
# Check Cilium LoadBalancer IPAM pool
kubectl get ciliumloadbalancerippools

# Check L2 announcement policy
kubectl get ciliuml2announcementpolicy

# Check Cilium agent logs
kubectl logs -n cilium-system daemonset/cilium | grep -i "loadbalancer\|l2"
```

### HTTPRoute Not Working
```bash
# Check if HTTPRoute is attached to Gateway
kubectl describe httproute <route-name>

# Look for conditions:
# - Accepted: True
# - ResolvedRefs: True

# Check Gateway listeners
kubectl describe gateway <gateway-name>
```

### SSL Certificate Issues
```bash
# Check certificate request status
kubectl get certificaterequests
kubectl describe certificaterequest <cert-request-name>

# Check DNS-01 challenges (for Let's Encrypt)
kubectl get challenges
kubectl describe challenge <challenge-name>

# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager
```

### HTTP Redirect Not Working
```bash
# Check if redirect HTTPRoute exists and is accepted
kubectl get httproute http-redirect
kubectl describe httproute http-redirect

# Verify Gateway has both HTTP (80) and HTTPS (443) listeners
kubectl get gateway <gateway-name> -o yaml | grep -A20 listeners
```

### Backend Service Not Reachable
```bash
# Check if service exists and has endpoints
kubectl get service <service-name>
kubectl get endpoints <service-name>

# Check if pods are running
kubectl get pods -l app=<app-label>

# Test service connectivity from within cluster
kubectl run debug --image=busybox -it --rm -- sh
# Inside pod: wget -qO- http://<service-name>.<namespace>.svc.cluster.local
```

### DNS Resolution Issues
```bash
# Check if domain resolves to LoadBalancer IP
nslookup nginx.home.daniel-enrique.com

# Test with LoadBalancer IP directly
curl -I http://<loadbalancer-ip> -H "Host: nginx.home.daniel-enrique.com"
```

## References

### Official Documentation
- [Gateway API Documentation](https://gateway-api.sigs.k8s.io/)
- [Gateway API Getting Started](https://gateway-api.sigs.k8s.io/guides/)
- [Cilium Gateway API Guide](https://docs.cilium.io/en/latest/network/servicemesh/gateway-api/)

### Cilium Specific
- [Cilium LoadBalancer IPAM](https://docs.cilium.io/en/latest/network/lb-ipam/)
- [Cilium L2 Announcements](https://docs.cilium.io/en/latest/network/l2-announcements/)
- [Cilium Service Mesh](https://docs.cilium.io/en/latest/network/servicemesh/)

### Gateway API Specifications
- [Gateway API v1.3.0 Release](https://github.com/kubernetes-sigs/gateway-api/releases/tag/v1.3.0)
- [HTTPRoute Specification](https://gateway-api.sigs.k8s.io/api-types/httproute/)
- [Gateway Specification](https://gateway-api.sigs.k8s.io/api-types/gateway/)

### Troubleshooting Resources
- [Gateway API Troubleshooting](https://gateway-api.sigs.k8s.io/guides/troubleshooting/)
- [Cilium Troubleshooting Guide](https://docs.cilium.io/en/latest/operations/troubleshooting/)
- [Cert-Manager Troubleshooting](https://cert-manager.io/docs/troubleshooting/)

### Best Practices
- [Gateway API Security Best Practices](https://gateway-api.sigs.k8s.io/guides/security/)
- [Multi-tenancy with Gateway API](https://gateway-api.sigs.k8s.io/concepts/security-model/)