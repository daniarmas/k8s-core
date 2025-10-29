# Trust-Manager

Automatically distributes CA certificate bundles to all namespaces in a Kubernetes 
cluster. Syncs trusted root certificates from a source (Secret/ConfigMap) to target 
ConfigMaps/Secrets across namespaces, keeping them updated when the source changes. 
Works alongside cert-manager to provide a consistent trust store for workloads.

## Installation

### 1. Install Trust-Manager
```bash
helmfile -f clusters/on-prem/helmfile.yaml -l name=trust-manager apply
```

### 2. Apply the RBAC permissions
```bash
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: trust-manager-secrets
  labels:
    app.kubernetes.io/name: trust-manager
rules:
  # Full secret permissions cluster-wide
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: trust-manager-secrets
  labels:
    app.kubernetes.io/name: trust-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: trust-manager-secrets
subjects:
  - kind: ServiceAccount
    name: trust-manager
    namespace: cert-manager
EOF
```

### 3. Apply the bundle resource
```bash
kubectl apply -f clusters/on-prem/manifests/10-trust-manager/01-internal-ca-bundle.yaml
```
> ⚠️ **Dependencies**: helmfile -f clusters/on-prem/helmfile.yaml -l name=prometheus-crds apply
