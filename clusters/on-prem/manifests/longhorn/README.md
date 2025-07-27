# Longhorn

Longhorn is a lightweight, reliable, and feature-rich distributed block storage system for Kubernetes. It creates distributed replicated block storage using containers and microservices, providing backup, snapshot, and restore capabilities for persistent volumes.

## Key Features

- **Distributed Storage**: Replicated block storage across multiple nodes for high availability
- **Backup and Restore**: Built-in backup to S3, NFS, or other compatible storage
- **Volume Snapshots**: Point-in-time snapshots for data protection and recovery
- **Cross-Node Scheduling**: Volumes can be accessed from any node in the cluster
- **Web UI**: Intuitive web interface for storage management and monitoring
- **CSI Driver**: Full Container Storage Interface (CSI) compliance
- **Disaster Recovery**: Cross-cluster volume replication and recovery

## Prerequisites

- Kubernetes cluster v1.21+
- Each node requires:
  - `iscsiadm` installed (for iSCSI support)
  - `curl`, `findmnt`, `grep`, `awk`, `blkid`, `lsblk` utilities
  - Root filesystem supports file extents (ext4, XFS)
- Minimum 4GB RAM per node recommended

## Installation

### 1. Install Longhorn using Helmfile
```bash
# Install Longhorn via helmfile
helmfile -f clusters/on-prem/helmfile.yaml -l name=longhorn apply

# Wait for deployment to complete
kubectl get pods -n longhorn-system -w
```

### 2. Access Longhorn UI (Optional)
```bash
# Port forward to access Longhorn UI
kubectl port-forward -n longhorn-system svc/longhorn-frontend 8080:80

# Access UI at: http://localhost:8080
```

## Verification Commands

### Check Longhorn Installation
```bash
# Verify all Longhorn pods are running
kubectl get pods -n longhorn-system

# Check Longhorn manager status
kubectl get pods -n longhorn-system -l app=longhorn-manager

# Verify Longhorn UI service
kubectl get svc -n longhorn-system longhorn-frontend
```

### Verify Storage Class
```bash
# Check if Longhorn storage class is created and set as default
kubectl get storageclass

# Expected output should show:
# NAME                 PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE   ...
# longhorn (default)   driver.longhorn.io   Delete          Immediate           ...
```

### Test Volume Creation
```bash
# Create a test PVC to verify Longhorn works
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: longhorn-test-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 1Gi
EOF

# Check PVC status
kubectl get pvc longhorn-test-pvc

# Expected: STATUS should be "Bound"
```

### Check Longhorn Nodes
```bash
# Verify nodes are detected by Longhorn
kubectl get nodes.longhorn.io -n longhorn-system

# Check node details
kubectl describe nodes.longhorn.io -n longhorn-system
```

### Verify Volume Replication
```bash
# Check if volumes are properly replicated
kubectl get volumes.longhorn.io -n longhorn-system

# Check replica details
kubectl get replicas.longhorn.io -n longhorn-system
```

### Test Backup Configuration (if configured)
```bash
# Check backup target settings
kubectl get settings.longhorn.io backup-target -n longhorn-system -o yaml

# List available backups (if any)
kubectl get backups.longhorn.io -n longhorn-system
```

## Troubleshooting

### Disk allocation problems
```bash
# Configure disks for all worker nodes
for worker in k8s-worker-1 k8s-worker-2 k8s-worker-3 k8s-worker-4; do
  echo "Configuring disk for $worker..."
  kubectl patch nodes.longhorn.io $worker -n longhorn-system --type merge -p '{
    "spec": {
      "disks": {
        "default-disk": {
          "allowScheduling": true,
          "evictionRequested": false,
          "path": "/var/lib/longhorn",
          "storageReserved": 17179869184,
          "tags": []
        }
      }
    }
  }'
done
```

### Longhorn Pods Not Starting
```bash
# Check pod status and events
kubectl describe pods -n longhorn-system -l app=longhorn-manager

# Check node requirements
kubectl logs -n longhorn-system -l app=longhorn-manager | grep -i error

# Verify required packages on nodes
for node in $(kubectl get nodes -o name); do
  echo "=== $node ==="
  kubectl debug $node -it --image=busybox -- chroot /host which iscsiadm
done
```

### Storage Class Issues
```bash
# Check if CSI driver is registered
kubectl get csidriver

# Verify CSI pods are running
kubectl get pods -n longhorn-system | grep csi

# Check storage class details
kubectl describe storageclass longhorn
```

### Volume Mount Issues
```bash
# Check volume attachment
kubectl get volumeattachments

# Check CSI node pods logs
kubectl logs -n longhorn-system -l app=longhorn-csi-plugin

# Verify volume and replica status
kubectl get volumes.longhorn.io -n longhorn-system
kubectl get replicas.longhorn.io -n longhorn-system
```

### Network Connectivity Issues
```bash
# Check if required ports are open between nodes
# Test from one node to another
nc -zv <node-ip> 9500

# Check Longhorn instance manager logs
kubectl logs -n longhorn-system -l app=longhorn-instance-manager
```

### Performance Issues
```bash
# Check disk usage on nodes
kubectl get nodes.longhorn.io -n longhorn-system -o wide

# Monitor volume performance
kubectl top pods -n longhorn-system

# Check if nodes have sufficient disk space
kubectl describe nodes.longhorn.io -n longhorn-system | grep -A 5 "Conditions"
```

### Backup and Restore Issues
```bash
# Check backup target connectivity
kubectl logs -n longhorn-system -l app=longhorn-manager | grep -i backup

# Verify backup credentials (if using S3)
kubectl get secret -n longhorn-system | grep backup

# Test backup target access
kubectl exec -n longhorn-system deployment/longhorn-manager -- \
  curl -I <backup-target-url>
```

### Clean Up Test Resources
```bash
# Remove test PVC
kubectl delete pvc longhorn-test-pvc

# Remove test pods if any
kubectl delete pods -l app=longhorn-test
```

## Configuration Examples

### Custom Storage Class
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: longhorn-fast
provisioner: driver.longhorn.io
allowVolumeExpansion: true
reclaimPolicy: Retain
volumeBindingMode: Immediate
parameters:
  numberOfReplicas: "2"
  staleReplicaTimeout: "30"
  fromBackup: ""
  diskSelector: "ssd"
  nodeSelector: "storage"
```

### Backup to S3
```yaml
# Configure S3 backup target
apiVersion: longhorn.io/v1beta1
kind: Setting
metadata:
  name: backup-target
  namespace: longhorn-system
spec:
  value: "s3://your-backup-bucket@region/"
---
apiVersion: v1
kind: Secret
metadata:
  name: s3-secret
  namespace: longhorn-system
type: Opaque
data:
  AWS_ACCESS_KEY_ID: <base64-encoded-access-key>
  AWS_SECRET_ACCESS_KEY: <base64-encoded-secret-key>
```

## Security Considerations

### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: longhorn-system
  namespace: longhorn-system
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: longhorn-system
  - from: []
    ports:
    - protocol: TCP
      port: 9500
    - protocol: TCP
      port: 9501
    - protocol: TCP
      port: 9502
    - protocol: TCP
      port: 9503
    - protocol: TCP
      port: 9504
```

### Resource Limits
```yaml
# Set resource limits for Longhorn components
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 200m
    memory: 256Mi
```

## References

### Official Documentation
- [Longhorn Documentation](https://longhorn.io/docs/)
- [Longhorn Installation Guide](https://longhorn.io/docs/1.9.0/deploy/install/)
- [Longhorn Best Practices](https://longhorn.io/docs/1.9.0/best-practices/)

### Configuration and Management
- [Longhorn Settings Reference](https://longhorn.io/docs/1.9.0/references/settings/)
- [Backup and Restore](https://longhorn.io/docs/1.9.0/snapshots-and-backups/)
- [Disaster Recovery](https://longhorn.io/docs/1.9.0/advanced-resources/deploy/recovery-volume/)

### Troubleshooting Resources
- [Longhorn Troubleshooting](https://longhorn.io/docs/1.9.0/troubleshooting/)
- [Known Issues](https://longhorn.io/docs/1.9.0/troubleshooting/known-issues/)
- [Performance Tuning](https://longhorn.io/docs/1.9.0/best-practices/performance/)

### Integration Guides
- [CSI Driver](https://longhorn.io/docs/1.9.0/deploy/install/install-with-kubectl/)
- [Monitoring with Prometheus](https://longhorn.io/docs/1.9.0/monitoring/)
- [Helm Installation](https://longhorn.io/docs/1.9.0/deploy/install/install-with-helm/)

### Community Resources
- [Longhorn GitHub Repository](https://github.com/longhorn/longhorn)
- [Longhorn Slack Community](https://slack.cncf.io/)
- [Longhorn Discussions](https://github.com/longhorn/longhorn/discussions)