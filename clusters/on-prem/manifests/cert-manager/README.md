# Cert-Manager

Automated certificate management for Kubernetes, providing SSL/TLS certificates from various issuers including Let's Encrypt, HashiCorp Vault, and custom CAs.

## Certificate Management

| Component | Description |
|-----------|-------------|
| **Certificate Issuers** | Automated certificate provisioning from trusted authorities |
| **ACME Protocol** | Let's Encrypt integration with HTTP-01 and DNS-01 challenges |
| **Certificate Lifecycle** | Automatic renewal and rotation of expiring certificates |

## Installation

### 1. Install Cert-Manager via Helmfile
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=cert-manager apply
```

### 2. Apply Cert-Manager Manifests
```bash
kubectl apply -f clusters/on-prem/manifests/cert-manager/
```

> **Note:** These manifests configure certificate issuers for Let's Encrypt staging and production environments.

## Certificate Issuer Example

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: cilium
    - dns01:
        cloudflare:
          email: admin@example.com
          apiTokenSecretRef:
            name: cloudflare-api-token
            key: api-token
```

## Certificate Request Example

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-tls
  namespace: default
spec:
  secretName: example-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - example.com
  - www.example.com
```

## Gateway API Integration

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: cilium-gateway
  namespace: default
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  gatewayClassName: cilium
  listeners:
  - name: https
    port: 443
    protocol: HTTPS
    hostname: "*.example.com"
    tls:
      mode: Terminate
      certificateRefs:
      - name: example-tls
        namespace: default
```

## Verification Commands

### Cert-Manager Status
```bash
# Check Cert-Manager pods
kubectl get pods -n cert-manager

# Check Cert-Manager version
kubectl get deployment -n cert-manager cert-manager -o jsonpath='{.spec.template.spec.containers[0].image}'

# View Cert-Manager logs
kubectl logs -n cert-manager deployment/cert-manager -f
```

### Certificate Issuers
```bash
# List cluster issuers
kubectl get clusterissuers

# List namespace issuers
kubectl get issuers -A

# Check issuer status
kubectl describe clusterissuer letsencrypt-prod
```

### Certificates
```bash
# List certificates
kubectl get certificates -A

# Check certificate status
kubectl describe certificate example-tls -n default

# View certificate details
kubectl get certificate example-tls -n default -o yaml

# Check certificate secret
kubectl get secret example-tls -n default -o yaml
```

### Certificate Requests
```bash
# List certificate requests
kubectl get certificaterequests -A

# Check certificate request status
kubectl describe certificaterequest -n default

# View certificate request logs
kubectl logs -n cert-manager deployment/cert-manager | grep certificaterequest
```

### ACME Challenges
```bash
# List ACME challenges
kubectl get challenges -A

# Check challenge status
kubectl describe challenge -n default

# View challenge solver pods
kubectl get pods -l acme.cert-manager.io/http01-solver=true
```

## Troubleshooting

### Common Issues

**Certificate Not Issued:**
```bash
# Check certificate status
kubectl describe certificate example-tls -n default

# Check certificate request
kubectl get certificaterequests -n default

# Check ACME challenge
kubectl get challenges -n default

# View detailed events
kubectl get events --field-selector involvedObject.name=example-tls
```

**HTTP-01 Challenge Failing:**
```bash
# Check if Gateway/Ingress is working
curl -v http://example.com/.well-known/acme-challenge/test

# Check challenge solver pod
kubectl get pods -l acme.cert-manager.io/http01-solver=true

# View solver logs
kubectl logs -l acme.cert-manager.io/http01-solver=true
```

**DNS-01 Challenge Failing:**
```bash
# Check DNS provider credentials
kubectl get secret cloudflare-api-token -o yaml

# Check DNS propagation
dig TXT _acme-challenge.example.com

# View challenge logs
kubectl logs -n cert-manager deployment/cert-manager | grep dns01
```

**Certificate Renewal Issues:**
```bash
# Check certificate expiry
kubectl get certificate example-tls -o jsonpath='{.status.notAfter}'

# Force certificate renewal
kubectl annotate certificate example-tls cert-manager.io/issue-temporary-certificate=true

# Check renewal logs
kubectl logs -n cert-manager deployment/cert-manager | grep renewal
```

**Webhook Issues:**
```bash
# Check webhook connectivity
kubectl get validatingwebhookconfiguration cert-manager-webhook

# Test webhook
kubectl auth can-i create certificates.cert-manager.io

# Check webhook logs
kubectl logs -n cert-manager deployment/cert-manager-webhook
```

## Security Considerations

### RBAC Configuration
```bash
# Check Cert-Manager RBAC
kubectl get clusterroles | grep cert-manager

# View Cert-Manager permissions
kubectl describe clusterrole cert-manager-controller-certificates
```

### Secret Management
```bash
# List certificate secrets
kubectl get secrets -A | grep tls

# Check secret permissions
kubectl auth can-i get secrets --as=system:serviceaccount:cert-manager:cert-manager
```

## References

- [Cert-Manager Documentation](https://cert-manager.io/docs/)
- [Cert-Manager Installation](https://cert-manager.io/docs/installation/)
- [Certificate Issuers](https://cert-manager.io/docs/configuration/)
- [ACME Protocol](https://cert-manager.io/docs/configuration/acme/)
- [Gateway API Integration](https://cert-manager.io/docs/usage/gateway/)
- [Let's Encrypt](https://letsencrypt.org/docs/)
- [Troubleshooting Guide](https://cert-manager.io/docs/troubleshooting/)
- [Security Best Practices](https://cert-manager.io/docs/installation/best-practice/)