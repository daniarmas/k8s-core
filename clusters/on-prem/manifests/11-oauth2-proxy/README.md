# OAuth2-Proxy

OAuth2-Proxy is a reverse proxy that provides authentication using OAuth2 providers. It is commonly used to secure applications by requiring users to authenticate before accessing protected resources.

## Installation

### 2. Create the namespace
```bash
kubectl create namespace oauth2-proxy
```

### 2. Create the google provider secret
```bash
vault kv put secret/oauth2-proxy client_id="changeme" client_secret="changeme" cookie_secret="changeme"
```

### 3. Install the operator
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=oauth2-proxy apply
```

### 4. Apply ingress manifest
```bash
kubectl apply -f clusters/on-prem/manifests/11-oauth2-proxy/02-ingress-service.yaml
```