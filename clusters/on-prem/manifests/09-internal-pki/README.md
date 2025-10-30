# Internal PKI

This internal PKI setup leverages cert-manager and HashiCorp Vault to automate certificate management and secure secret storage within the Kubernetes cluster. cert-manager handles certificate issuance and renewal, while Vault provides a robust backend for storing and managing cryptographic keys and secrets.

## Table of Contents
- [Installation](#installation)
- [Verification](#verification)

## Installation

### 1. Enable a root PKI at path "pki" (20 years max TTL)
```bash
vault secrets enable -path=pki pki
```

### 2. Set TTL for the root CA
```bash
vault secrets tune -max-lease-ttl=175200h pki
```

### 3. Generate an internal self-signed Root CA
```bash
vault write pki/root/generate/internal \
  common_name="Internal Root CA" \
  issuer_name="root-2024" \
  key_type=rsa key_bits=4096 \
  ttl=175200h
```

### 4. Configure the CA and CRL URLs
```bash
vault write pki/config/urls \
    issuing_certificates="http://vault.vault.svc.cluster.local:8200/v1/pki/ca" \
    crl_distribution_points="http://vault.vault.svc.cluster.local:8200/v1/pki/crl"
```

### 5. Export the Root CA
```bash
vault read -field=certificate pki/issuer/root-2024 > root-ca.pem
```
> **Note:** Keep this file safe; you’ll also use the intermediate CA chain for workloads’ trust.

### 6. Enable an intermediate PKI at path "pki_int" (10 years max TTL)
```bash
vault secrets enable -path=pki_int pki
```

### 7. Set TTL for the intermediate CA (10 years max TTL)
```bash
vault secrets tune -max-lease-ttl=87600h pki_int
```

### 8. Generate Intermediate CSR
```bash
vault write -field=csr pki_int/intermediate/generate/internal \
  common_name="Kubernetes Intermediate CA" \
  key_type=rsa key_bits=4096 \
  | tee intermediate.csr
```

### 9. Sign the Intermediate CSR with Root
```bash
vault write -format=json pki/root/sign-intermediate \
  csr=@intermediate.csr \
  format=pem_bundle ttl=87600h | jq -r '.data.certificate' > intermediate.cert.pem
```

### 10. Set the signed Intermediate on pki_int
```bash
vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
```

### 11. Export the intermediate CA certificate
```bash
vault read -field=certificate pki_int/cert/ca > intermediate-ca.pem
```
> **Note:** This is the intermediate CA certificate only.

### 12. Configure URLs for Intermediate CA
```bash
vault write pki_int/config/urls \
    issuing_certificates="http://vault.vault.svc.cluster.local:8200/v1/pki_int/ca" \
    crl_distribution_points="http://vault.vault.svc.cluster.local:8200/v1/pki_int/crl"
```

### 13. Create a role for kubernetes services
```bash
vault write pki_int/roles/kubernetes-services \
    allowed_domains="svc.cluster.local" \
    allow_subdomains=true \
    allow_bare_domains=false \
    use_csr_common_name=true \
    use_csr_sans=true \
    require_cn=false \
    server_flag=true \
    client_flag=true \
    max_ttl="8760h" \
    ttl="720h"
```
> **Note:** Role for general Kubernetes services. Allows certificates for any service in the cluster.

### 14. Create a role for minio services
```bash
vault write pki_int/roles/minio \
    allowed_domains="minio-tenant.svc.cluster.local,minio-hl.minio-tenant.svc.cluster.local" \
    allow_subdomains=true \
    allow_bare_domains=true \
    use_csr_common_name=true \
    use_csr_sans=true \
    require_cn=false \
    allow_wildcard_certificates=true \
    server_flag=true \
    client_flag=true \
    max_ttl="8760h" \
    ttl="720h"
```
> **Note:** Role for MinIO services. Allows certificates only for MinIO-specific domains.

### 15. Create a role for harbor services
```bash
vault write pki_int/roles/harbor \
    allowed_domains="harbor.svc.cluster.local,harbor-core.harbor.svc.cluster.local,harbor-registry.harbor.svc.cluster.local,harbor-portal.harbor.svc.cluster.local,harbor-jobservice.harbor.svc.cluster.local,harbor-trivy.harbor.svc.cluster.local,harbor-core,harbor-registry,harbor-portal,harbor-jobservice,harbor-trivy" \
    allow_subdomains=false \
    allow_bare_domains=true \
    use_csr_common_name=true \
    use_csr_sans=true \
    require_cn=false \
    server_flag=true \
    client_flag=true \
    max_ttl="8760h" \
    ttl="720h"
```
> **Note:** Role for Harbor services. Allows certificates only for Harbor-specific domains.

### 16. Create a role for grafana-mimir services
```bash
vault write pki_int/roles/grafana-mimir \
    allowed_domains="grafana-mimir.svc.cluster.local,mimir-ingester.grafana-mimir.svc.cluster.local,mimir-querier.grafana-mimir.svc.cluster.local,mimir-distributor.grafana-mimir.svc.cluster.local,mimir-query-frontend.grafana-mimir.svc.cluster.local,mimir-compactor.grafana-mimir.svc.cluster.local,mimir-store-gateway.grafana-mimir.svc.cluster.local,mimir-ruler.grafana-mimir.svc.cluster.local,mimir-alertmanager.grafana-mimir.svc.cluster.local,mimir-gateway.grafana-mimir.svc.cluster.local,mimir-ingester,mimir-querier,mimir-distributor,mimir-query-frontend,mimir-compactor,mimir-store-gateway,mimir-ruler,mimir-alertmanager,mimir-gateway" \
    allow_subdomains=true \
    allow_bare_domains=true \
    use_csr_common_name=true \
    use_csr_sans=true \
    require_cn=false \
    server_flag=true \
    client_flag=true \
    max_ttl="8760h" \
    ttl="720h"
```
> **Note:** Role for Grafana Mimir services. Allows certificates only for Grafana-Mimir specific domains.

### 17. Create a role for cockroachdb services
```bash
vault write pki_int/roles/cockroachdb \
    allowed_domains="localhost,cockroachdb-public,cockroachdb-public.cockroachdb,cockroachdb-public.cockroachdb.svc.cluster.local,cockroachdb,cockroachdb.cockroachdb,cockroachdb.cockroachdb.svc.cluster.local" \
    allow_subdomains=true \
    allow_bare_domains=true \
    allow_localhost=true \
    allow_ip_sans=true \
    allow_any_name=true \
    enforce_hostnames=false \
    use_csr_common_name=true \
    use_csr_sans=true \
    server_flag=true \
    client_flag=true \
    max_ttl="8760h" \
    ttl="8760h"
```
> **Note:** Role for CockroachDB services. Allows certificates only for CockroachDB specific domains.

### 18. Create policies for cert-manager to issue certificates
```bash
vault policy write cert-manager - <<EOF
path "pki_int/sign/kubernetes-services" {
  capabilities = ["create", "update"]
}
path "pki_int/issue/kubernetes-services" {
  capabilities = ["create"]
}
# MinIO-specific role
path "pki_int/sign/minio" {
  capabilities = ["create", "update"]
}
path "pki_int/issue/minio" {
  capabilities = ["create"]
}
# Harbor-specific role
path "pki_int/sign/harbor" {
  capabilities = ["create", "update"]
}
path "pki_int/issue/harbor" {
  capabilities = ["create"]
}
# Grafana-Mimir specific role
path "pki_int/sign/grafana-mimir" {
  capabilities = ["create", "update"]
}
path "pki_int/issue/grafana-mimir" {
  capabilities = ["create"]
}
# CockroachDB specific role
path "pki_int/sign/cockroachdb" {
  capabilities = ["create", "update"]
}
path "pki_int/issue/cockroachdb" {
  capabilities = ["create"]
}
EOF
```

### 19. Create Kubernetes authentication role for cert-manager
```bash
vault write auth/kubernetes/role/cert-manager \
    bound_service_account_names=cert-manager \
    bound_service_account_namespaces=cert-manager \
    policies=cert-manager \
    ttl=1h \
    max_ttl=24h
```

### 20. Create the ClusterIssuer
```bash
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: vault-issuer
spec:
  vault:
    server: http://vault.vault.svc.cluster.local:8200
    path: pki_int/sign/kubernetes-services
    auth:
      kubernetes:
        mountPath: /v1/auth/kubernetes
        role: cert-manager
        serviceAccountRef:
          name: cert-manager
EOF
```
> **Note:** Currently using HTTP for Vault communication. For production, configure Vault with TLS and update this to use `https://` with a `caBundle`.

### 21. Create the MinIO ClusterIssuer
```bash
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: vault-minio
spec:
  vault:
    server: http://vault.vault.svc.cluster.local:8200
    path: pki_int/sign/minio
    auth:
      kubernetes:
        mountPath: /v1/auth/kubernetes
        role: cert-manager
        serviceAccountRef:
          name: cert-manager
EOF
```
> **Note:** ClusterIssuer for MinIO certificates. Uses the minio PKI role which restricts certificates to MinIO-specific domains.

### 22. Create the Harbor ClusterIssuer
```bash
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: vault-harbor
spec:
  vault:
    server: http://vault.vault.svc.cluster.local:8200
    path: pki_int/sign/harbor
    auth:
      kubernetes:
        mountPath: /v1/auth/kubernetes
        role: cert-manager
        serviceAccountRef:
          name: cert-manager
EOF
```
> **Note:** ClusterIssuer for Harbor certificates. Uses the harbor PKI role which restricts certificates to Harbor-specific domains.

### 23. Create the Grafana Mimir ClusterIssuer
```bash
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: vault-grafana-mimir
spec:
  vault:
    server: http://vault.vault.svc.cluster.local:8200
    path: pki_int/sign/grafana-mimir
    auth:
      kubernetes:
        mountPath: /v1/auth/kubernetes
        role: cert-manager
        serviceAccountRef:
          name: cert-manager
EOF
```
> **Note:** ClusterIssuer for Grafana-Mimir certificates. Uses the grafana-mimir PKI role which restricts certificates to Grafana-Mimir specific domains.

### 24. Create the CockroachDB ClusterIssuer
```bash
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: vault-cockroachdb
spec:
  vault:
    server: http://vault.vault.svc.cluster.local:8200
    path: pki_int/sign/cockroachdb
    auth:
      kubernetes:
        mountPath: /v1/auth/kubernetes
        role: cert-manager
        serviceAccountRef:
          name: cert-manager
EOF
```
> **Note:** ClusterIssuer for Grafana-Mimir certificates. Uses the grafana-mimir PKI role which restricts certificates to Grafana-Mimir specific domains.

### 25. Combine Intermediate and Root CA Certificates
```bash
cat intermediate.cert.pem root-ca.pem > internal-ca-full-chain.pem
```
> **Note:** Certificate chain order: intermediate first, then root. This is the standard order for trust bundles.

### 26. Create the CA Bundle ConfigMap (For trust distribution)
```bash
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: internal-ca-bundle
  namespace: kube-system
data:
  ca-bundle.crt: |
$(sed 's/^/    /' internal-ca-full-chain.pem)
EOF
```
> **Note:** This ConfigMap serves as the source of truth for your internal CA bundle.

## Verification

### Verify PKI Setup
```bash
# Check root CA
vault read pki/issuer/root-2024

# Check intermediate CA
vault read pki_int/issuer/default

# List roles
vault list pki_int/roles

# Verify cert-manager can authenticate
kubectl get clusterissuer vault-issuer -o yaml
```

### Test Certificate Issuance
```bash
# Create a test certificate
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: test-certificate
  namespace: default
spec:
  secretName: test-certificate-tls
  issuerRef:
    name: vault-minio
    kind: ClusterIssuer
  dnsNames:
  - test.default.svc.cluster.local
  duration: 2160h  # 90 days
  renewBefore: 360h  # 15 days before expiry
EOF

# Check certificate status
kubectl describe certificate test-certificate -n default

# Verify the certificate was issued
kubectl get secret test-certificate-tls -n default

# Inspect the certificate
kubectl get secret test-certificate-tls -n default -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -text -noout
```

### Clean Up Test Certificate
```bash
kubectl delete certificate test-certificate -n default
kubectl delete secret test-certificate-tls -n default
```