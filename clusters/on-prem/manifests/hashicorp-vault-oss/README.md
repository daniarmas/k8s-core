# HashiCorp Vault OSS

HashiCorp Vault is a tool for securely accessing secrets. A secret is anything that you want to tightly control access to, such as API keys, passwords, certificates, and more. This setup deploys Vault OSS (Open Source) on Kubernetes with persistent storage and high availability options.

## Key Features
- **Secret Management**: Secure storage and access to tokens, passwords, certificates, encryption keys
- **Dynamic Secrets**: Generate secrets on-demand for services like databases, cloud platforms
- **Data Encryption**: Encrypt/decrypt data without storing it and manage encryption keys
- **Leasing and Renewal**: All secrets have a lease associated with them for automatic expiration
- **Revocation**: Built-in revocation support for secrets and encryption keys

## Installation

### 1. Install Vault CLI
Follow the [official installation guide](https://developer.hashicorp.com/vault/install).

**macOS:**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/vault
```

### 2. Install Vault using Helmfile
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=vault apply
```

## Setup

### 1. Port-forward Vault (in a new terminal tab or background)
```bash
kubectl port-forward -n vault svc/vault 8200:8200
```

### 2. Export Vault API address
```bash
export VAULT_ADDR=http://127.0.0.1:8200
```

### 3. Initialize Vault
```bash
vault operator init \
  -key-shares=5 \
  -key-threshold=3 \
  -format=json > vault-keys.json
```

> ⚠️ **Critical Security Note**: Store these keys in multiple secure locations. You need at least 3 keys to unseal Vault. Without them, your data will be permanently inaccessible!

### 4. Unseal Vault
```bash
vault operator unseal "$(jq -r '.unseal_keys_b64[0]' vault-keys.json)"
vault operator unseal "$(jq -r '.unseal_keys_b64[1]' vault-keys.json)"
vault operator unseal "$(jq -r '.unseal_keys_b64[2]' vault-keys.json)"
```

### 5. Login to Vault CLI using root token
```bash
vault login $(jq -r .root_token vault-keys.json)
```

### 6. Verify Vault is unsealed and operational
```bash
vault status
```

## Kubernetes Authentication

This guide sets up Vault login using Kubernetes authentication, allowing applications running in your Kubernetes cluster to authenticate to Vault using their service account tokens. This enables secure, automated access to secrets without manual credential management.

### 1. Enable Kubernetes Authentication
```bash
vault auth enable kubernetes
```

### 2. Create a dedicated service account
```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-auth
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: vault-tokenreviewer
rules:
  - apiGroups: [""]
    resources: ["serviceaccounts", "secrets"]
    verbs: ["get", "list"]
  - apiGroups: ["authentication.k8s.io"]
    resources: ["tokenreviews"]
    verbs: ["create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: vault-tokenreviewer-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: vault-tokenreviewer
subjects:
  - kind: ServiceAccount
    name: vault-auth
    namespace: kube-system
EOF
```

### 3. Extract the required data

1. Service account token
```bash
TOKEN=$(kubectl -n kube-system get secret \
  $(kubectl -n kube-system get sa vault-auth -o jsonpath="{.secrets[0].name}") \
  -o jsonpath="{.data.token}" | base64 --decode)
```

2. Kubernetes API server endpoint
```bash
KUBE_HOST=$(kubectl config view --minify -o jsonpath="{.clusters[0].cluster.server}")
```

3. Kubernetes CA certificate
```bash
kubectl -n kube-system get secret \
  $(kubectl -n kube-system get sa vault-auth -o jsonpath="{.secrets[0].name}") \
  -o jsonpath="{.data['ca\.crt']}" | base64 --decode > ca.crt
```

### 4. Configure Vault Kubernetes Auth
```bash
vault write auth/kubernetes/config \
  token_reviewer_jwt="$TOKEN" \
  kubernetes_host="$KUBE_HOST" \
  kubernetes_ca_cert=@ca.crt
```

## OIDC Authentication with Google Sign In

This guide sets up Vault login using Google accounts via OIDC, including access via the Vault UI. It works with free Gmail accounts and does **not require** Google Workspace.

### Prerequisites

- Vault is deployed and accessible (e.g., `http://localhost:8200`)
- You have access to [Google Cloud Console](https://console.cloud.google.com/)

### 1. Create an OAuth 2.0 Client in Google Cloud

1. Go to: [Google Cloud Console → Credentials](https://console.cloud.google.com/apis/credentials)
2. Create a new **OAuth 2.0 Client ID**:
   - **Application Type**: Web application
   - **Authorized redirect URI**:  
     ```
     http://localhost:8200/ui/vault/auth/oidc/oidc/callback
     ```
3. Copy the generated:
   - **Client ID**
   - **Client Secret**

### 2. Configure the OAuth Consent Screen

1. In the Cloud Console, go to **OAuth consent screen**
2. Choose **External**
3. Fill in required fields (App name, support email, etc.)
4. Under **Scopes**, add:
   - `openid`
   - `email`
   - `profile`
5. Save and **publish** the consent screen

### 3. Enable and Configure OIDC in Vault
```bash
vault auth enable oidc
```

### 4. Set up the OIDC provider using your Google client credentials
```bash
vault write auth/oidc/config \
  oidc_discovery_url="https://accounts.google.com" \
  oidc_client_id="YOUR_CLIENT_ID" \
  oidc_client_secret="YOUR_CLIENT_SECRET" \
  default_role="gmail"
```

### 5. Create a Role for Your Google Account
```bash
vault write auth/oidc/role/gmail \
  user_claim="email" \
  bound_claims.email="yourgmail@gmail.com" \
  allowed_redirect_uris="http://localhost:8200/ui/vault/auth/oidc/oidc/callback" \
  oidc_scopes="openid email" \
  oidc_response_mode="form_post" \
  policies="default" \
  ttl="1h"
```

### 6. Port forward Vault UI
```bash
kubectl port-forward svc/vault -n vault 8200:8200
```

### 7. Select OIDC as the login method and Sign In with Google

## Vault Deployment Example

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: myapp
  namespace: default
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vault-consumer-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vault-consumer
  template:
    metadata:
      labels:
        app: vault-consumer
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "myapp"
        vault.hashicorp.com/agent-inject-secret-config: "secret/data/myapp/config"
        vault.hashicorp.com/agent-inject-template-config: |
          {{- with secret "secret/data/myapp/config" -}}
          DATABASE_URL="postgresql://{{ .Data.data.username }}:{{ .Data.data.password }}@postgres:5432/myapp"
          API_KEY="{{ .Data.data.api_key }}"
          {{- end }}
    spec:
      serviceAccountName: myapp
      containers:
        - name: app
          image: hashicorp/http-echo
          args:
            - "-listen=:80"
            - "-file=/vault/secrets/config"
          ports:
            - containerPort: 80
          volumeMounts:
            - name: vault-secrets
              mountPath: /vault/secrets
              readOnly: true
      volumes:
        - name: vault-secrets
          emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: vault-consumer-service
  namespace: default
spec:
  selector:
    app: vault-consumer
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
```

## Verification Commands

### Check Vault Installation
```bash
# Verify Vault pods are running
kubectl get pods -n vault

# Expected output:
# NAME                                    READY   STATUS    RESTARTS   AGE
# vault-0                                 1/1     Running   0          10m
# vault-agent-injector-xxxx               1/1     Running   0          10m
```

### Check Vault Status
```bash
# Check if Vault is initialized and unsealed
kubectl exec -n vault vault-0 -- vault status

# Expected output should show:
# Sealed: false
# Initialized: true
```

### Check Persistent Storage
```bash
# Verify persistent volume claims
kubectl get pvc -n vault

# Expected output:
# NAME                   STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# data-vault-0          Bound    pvc-xxx    10Gi       RWO            longhorn       10m
```

### Test Secret Operations
```bash
# Create a test secret
vault kv put secret/myapp/config \
    username="myuser" \
    password="mypassword" \
    api_key="abc123"

# Read the secret
vault kv get secret/myapp/config

# List secrets
vault kv list secret/myapp/
```

### Test Kubernetes Authentication
```bash
# Test authentication from a pod
kubectl run vault-test --image=vault:latest -it --rm -- sh

# Inside the pod:
# export VAULT_ADDR="http://vault.vault.svc.cluster.local:8200"
# JWT=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
# vault write auth/kubernetes/login role=myapp jwt=$JWT
```

### Access Vault UI
```bash
# Port forward to access UI
kubectl port-forward -n vault svc/vault-ui 8200:8200

# Open browser to http://localhost:8200
# Login with root token or Kubernetes auth
```

## Troubleshooting

### Vault Pod Not Starting
```bash
# Check pod status and events
kubectl describe pod vault-0 -n vault

# Check logs
kubectl logs vault-0 -n vault

# Common issues:
# - Storage class not available
# - Insufficient resources
# - Security context issues
```

### Vault Sealed After Restart
```bash
# Check seal status
kubectl exec -n vault vault-0 -- vault status

# If sealed, unseal again
kubectl exec -n vault vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY_1
kubectl exec -n vault vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY_2
kubectl exec -n vault vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY_3
```

### Authentication Issues
```bash
# Check if auth method is enabled
vault auth list

# Verify Kubernetes auth configuration
vault read auth/kubernetes/config

# Check service account token
kubectl get serviceaccount myapp -o yaml
kubectl describe secret $(kubectl get serviceaccount myapp -o jsonpath='{.secrets[0].name}')
```

### Agent Injection Not Working
```bash
# Check agent injector logs
kubectl logs -n vault deployment/vault-agent-injector

# Verify annotations on pod template
kubectl describe deployment vault-consumer-app

# Check if ServiceAccount has proper permissions
kubectl describe serviceaccount myapp
```

### Storage Issues
```bash
# Check PVC status
kubectl get pvc -n vault
kubectl describe pvc data-vault-0 -n vault

# Check storage class
kubectl get storageclass longhorn

# Verify Longhorn is working
kubectl get pods -n longhorn-system
```

### High Availability Setup Issues
```bash
# For HA deployments, check all Vault instances
kubectl get pods -n vault -l app.kubernetes.io/name=vault

# Check raft cluster status
kubectl exec -n vault vault-0 -- vault operator raft list-peers

# Check if leader election is working
kubectl exec -n vault vault-0 -- vault status
kubectl exec -n vault vault-1 -- vault status
kubectl exec -n vault vault-2 -- vault status
```

### Network Connectivity Issues
```bash
# Test internal service connectivity
kubectl run debug --image=busybox -it --rm -- sh
# Inside pod: wget -qO- http://vault.vault.svc.cluster.local:8200/v1/sys/health

# Check service and endpoints
kubectl get svc -n vault
kubectl get endpoints -n vault
```

### Certificate/TLS Issues
```bash
# For TLS-enabled setups, check certificate
kubectl get secret vault-tls -n vault
kubectl describe secret vault-tls -n vault

# Verify certificate is valid
openssl x509 -in <cert-file> -text -noout
```

## References

### Official Documentation
- [Vault Documentation](https://www.vaultproject.io/docs)
- [Vault on Kubernetes](https://www.vaultproject.io/docs/platform/k8s)
- [Vault Helm Chart](https://github.com/hashicorp/vault-helm)

### Kubernetes Integration
- [Vault Agent Injector](https://www.vaultproject.io/docs/platform/k8s/injector)
- [Vault CSI Provider](https://github.com/hashicorp/vault-csi-provider)
- [Kubernetes Auth Method](https://www.vaultproject.io/docs/auth/kubernetes)

### Security Best Practices
- [Vault Production Hardening](https://learn.hashicorp.com/tutorials/vault/production-hardening)
- [Vault Security Model](https://www.vaultproject.io/docs/internals/security)
- [Auto-unseal with Cloud KMS](https://www.vaultproject.io/docs/concepts/seal#auto-unseal)

### Troubleshooting Resources
- [Vault Troubleshooting Guide](https://learn.hashicorp.com/tutorials/vault/troubleshooting-vault)
- [Common Vault Issues](https://www.vaultproject.io/docs/troubleshooting)
- [Kubernetes Troubleshooting](https://kubernetes.io/docs/tasks/debug-application-cluster/)

### Advanced Topics
- [Vault Enterprise Features](https://www.vaultproject.io/docs/enterprise)
- [Vault Secrets Operator](https://github.com/hashicorp/vault-secrets-operator)
- [Vault Agent Caching](https://www.vaultproject.io/docs/agent/caching)

### Best Practices
-