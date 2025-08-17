# HashiCorp Vault OSS

HashiCorp Vault is a tool for securely accessing secrets. A secret is anything that you want to tightly control access to, such as API keys, passwords, certificates, and more. This setup deploys Vault OSS (Open Source) on Kubernetes with persistent storage and high availability options.

## Key Features
- **Secret Management**: Secure storage and access to tokens, passwords, certificates, encryption keys
- **Dynamic Secrets**: Generate secrets on-demand for services like databases, cloud platforms
- **Data Encryption**: Encrypt/decrypt data without storing it and manage encryption keys
- **Leasing and Renewal**: All secrets have a lease associated with them for automatic expiration
- **Revocation**: Built-in revocation support for secrets and encryption keys

## Requirements

### 1. Install Vault CLI
Follow the [official installation guide](https://developer.hashicorp.com/vault/install).

**macOS:**
```bash
brew install hashicorp/tap/vault
```

## Installation

### 1. Install Vault
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
     https://vault.home.daniel-enrique.com/ui/vault/auth/oidc/oidc/callback
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
  oidc_client_secret="YOUR_CLIENT_SECRET"
```

### 5. Create the root permissive policy
```bash
vault policy write root-google-policy - <<EOF   
# Full access to all secret engines
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# System backend access (required for UI navigation)
path "sys/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Auth method management
path "auth/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Identity management
path "identity/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Token operations
path "auth/token/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Cubbyhole (user-specific secrets)
path "cubbyhole/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF
```

### 6. Create a Root Role for Your Google Account
```bash
vault write auth/oidc/role/root -<<'JSON'
{
  "user_claim": "email",
  "bound_audiences": "client-id",
  "bound_claims": { "email": ["daniel.armas9706@gmail.com"] },
  "allowed_redirect_uris": ["https://vault.home.daniel-enrique.com/ui/vault/auth/oidc/oidc/callback"],
  "oidc_scopes": ["openid", "email", "profile"],
  "oidc_response_mode": "form_post",
  "token_policies": ["root-google-policy"],
  "ttl": "1h",
  "max_ttl": "24h"
}
JSON
```

### 7. Apply the vault http router
```bash
kubectl apply -f clusters/on-prem/manifests/gateway/vault/01-http-route.yaml
```

## KV Secrets Engine

### 1. Enable KV Secrets Engine
```bash
vault secrets enable -path=secret kv-v2
```

### 2. Verify KV Secrets Engine
```bash
# Check if secrets engine is enabled
vault secrets list
```

## Kubernetes Authentication

This guide sets up Vault login using Kubernetes authentication, allowing applications running in your Kubernetes cluster to authenticate to Vault using their service account tokens. This enables secure, automated access to secrets without manual credential management.

### 1. Create service account secret token
```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: vault-k8s-auth-token
  namespace: vault
  annotations:
    kubernetes.io/service-account.name: vault
type: kubernetes.io/service-account-token
EOF
```

### 2 Create ClusterRole and ClusterRoleBinding
```bash
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: vault-k8s-auth
rules:
  - apiGroups: [""]
    resources: ["serviceaccounts", "pods"]
    verbs: ["get"]
  - apiGroups: ["authentication.k8s.io"]
    resources: ["tokenreviews"]
    verbs: ["create"]
  - apiGroups: ["authorization.k8s.io"]
    resources: ["subjectaccessreviews"]
    verbs: ["create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: vault-k8s-auth
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: vault-k8s-auth
subjects:
  - kind: ServiceAccount
    name: vault
    namespace: vault
EOF
```

### 3. Enable Kubernetes Authentication
```bash
vault auth enable kubernetes
```

### 4. Extract the required data

1. Service account token
```bash
TOKEN=$(kubectl -n vault get secret vault-k8s-auth-token -o jsonpath="{.data.token}" | base64 --decode)
```

2. Kubernetes API server endpoint
```bash
KUBE_HOST=$(kubectl config view --minify -o jsonpath="{.clusters[0].cluster.server}")
```

3. Kubernetes CA certificate
```bash
kubectl -n vault get secret vault-k8s-auth-token -o jsonpath="{.data['ca\.crt']}" | base64 --decode > ca.crt
```

### 5. Configure Vault Kubernetes Auth
```bash
vault write auth/kubernetes/config \
  token_reviewer_jwt="$TOKEN" \
  kubernetes_host="$KUBE_HOST" \
  kubernetes_ca_cert=@ca.crt
```

## Test with Vault CLI

### 1. First create the service account with token secret (required for Kubernetes 1.24+)
```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: testvaultapp
  namespace: default
---
apiVersion: v1
kind: Secret
metadata:
  name: testvaultapp-token
  namespace: default
  annotations:
    kubernetes.io/service-account.name: testvaultapp
type: kubernetes.io/service-account-token
EOF
```

### 2. Create a policy defining secret access permissions
```bash
vault policy write testvaultapp-policy - <<EOF
path "secret/data/testvaultapp/*" {
  capabilities = ["read"]
}
EOF
```

### 3. Create a Kubernetes role linking service accounts to the policy
```bash
vault write auth/kubernetes/role/testvaultapp \
    bound_service_account_names=testvaultapp \
    bound_service_account_namespaces=default \
    policies=testvaultapp-policy \
    ttl=24h
```

### 4. Try a vault cli login
```bash
JWT=$(kubectl create token testvaultapp -n default)
vault write auth/kubernetes/login \
    role="testvaultapp" \
    jwt="$JWT"
```

## Vault Deployment Example

### 1. Create a policy defining secret access permissions
```bash
vault policy write testvaultapp-policy - <<EOF
path "secret/data/testvaultapp/*" {
  capabilities = ["read"]
}
path "secret/metadata/testvaultapp/*" {
  capabilities = ["read", "list"]
}
EOF
```

### 2. Create a Kubernetes role linking service accounts to the policy
```bash
vault write auth/kubernetes/role/testvaultapp \
    bound_service_account_names=testvaultapp \
    bound_service_account_namespaces=default \
    policies=testvaultapp-policy \
    ttl=24h
```

### 3. Create example secrets
```bash
vault kv put secret/testvaultapp/config \
    username="myuser" \
    password="mypassword" \
    api_key="abc123def456"
```

### 4. Create the k8s resources

1. First create the service account with token secret (required for Kubernetes 1.24+)
```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: testvaultapp
  namespace: default
---
apiVersion: v1
kind: Secret
metadata:
  name: testvaultapp-token
  namespace: default
  annotations:
    kubernetes.io/service-account.name: testvaultapp
type: kubernetes.io/service-account-token
EOF
```

2. Then create the deployment and other resources
```bash
kubectl apply -f - <<EOF
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
        vault.hashicorp.com/role: "testvaultapp"
        vault.hashicorp.com/agent-inject-secret-config: "secret/data/testvaultapp/config"
        vault.hashicorp.com/agent-pre-populate: "false"
        vault.hashicorp.com/agent-pre-populate-only: "false"
        vault.hashicorp.com/template-static-secret-render-interval: "30s"
        vault.hashicorp.com/agent-cache-use-auto-auth-token: "true"
        vault.hashicorp.com/agent-inject-template-config: |
          {{- with secret "secret/data/testvaultapp/config" -}}
          DATABASE_URL="postgresql://{{ .Data.data.username }}:{{ .Data.data.password }}@postgres:5432/testvaultapp"
          API_KEY="{{ .Data.data.api_key }}"
          {{- end }}
    spec:
      serviceAccountName: testvaultapp
      containers:
        - name: app
          image: python:3-alpine
          ports:
            - containerPort: 80
          command: ["/bin/sh"]
          args:
            - "-c"
            - "cd /vault/secrets && python -m http.server 80"
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
EOF
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