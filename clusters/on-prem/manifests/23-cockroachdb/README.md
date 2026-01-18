# CockroachDB

CockroachDB is a distributed, cloud-native SQL database engineered for survivability, horizontal scalability, and strong consistency. It provides ACID transactions, automatic rebalancing, and built‑in replication for fault tolerance and multi‑region deployments while remaining compatible with the PostgreSQL wire protocol.

## Installation

### 1. Install the CockroachDB CRDs
```bash
kubectl apply -f https://raw.githubusercontent.com/cockroachdb/cockroach-operator/master/install/crds.yaml
```

### 2. Install the CockroachDB Operator
```bash
kubectl apply -f https://raw.githubusercontent.com/cockroachdb/cockroach-operator/master/install/operator.yaml
```

### 3. Create the namespace
```bash
kubectl create namespace cockroachdb
```

### 4. Issue the node TLS certificate
```bash
kubectl apply -f clusters/on-prem/manifests/22-cockroachdb/01-node-tls-certificate.yaml
```

### 5. Issue the client TLS certificate
```bash
kubectl apply -f clusters/on-prem/manifests/22-cockroachdb/02-client-tls-certificate.yaml
```

### 6. Create the cluster
```bash
kubectl apply -f clusters/on-prem/manifests/22-cockroachdb/03-cockroach-cluster.yaml
```

### 7. Apply the RBAC
```bash
kubectl apply -f clusters/on-prem/manifests/22-cockroachdb/04-cockroachdb-rbac.yaml
```

### 8. Apply the job
```bash
kubectl apply -f clusters/on-prem/manifests/22-cockroachdb/05-job.yaml
```

### 9. Issue the api_user client TLS certificate
```bash
kubectl apply -f clusters/on-prem/manifests/22-cockroachdb/06-api-user-client-tls-certificate.yaml
```

## How to extract the certificate for development

### 1. Extract CA certificate
```bash
kubectl get secret api-user-tls -n cockroachdb \
  -o jsonpath='{.data.ca\.crt}' | base64 -d > ./cockroach-certs/ca.crt
```

### 2. Extract client certificate
```bash
kubectl get secret api-user-tls -n cockroachdb \
  -o jsonpath='{.data.tls\.crt}' | base64 -d > ./cockroach-certs/tls.crt
```

### 3. Extract client key
```bash
kubectl get secret api-user-tls -n cockroachdb \
  -o jsonpath='{.data.tls\.key}' | base64 -d > ./cockroach-certs/tls.key
```

## Verification

Wait for the cluster to be ready:
```bash
kubectl -n cockroachdb get crdbcluster
kubectl -n cockroachdb get pods
```

Check cluster status:
```bash
kubectl -n cockroachdb exec -it cockroachdb-0 -- /cockroach/cockroach node status --certs-dir=/cockroach/cockroach-certs
```

## Access

Connect to the SQL interface:
```bash
kubectl -n cockroachdb exec -it cockroachdb-0 -- /cockroach/cockroach sql --certs-dir=/cockroach/cockroach-certs
```

## Troubleshooting

- Check operator logs: `kubectl logs -n cockroach-operator-system deployment/cockroach-operator`
- Verify certificates: `kubectl -n cockroachdb get certificates`
- Check pod events: `kubectl -n cockroachdb describe pod <pod-name>`

## Cleanup

```bash
kubectl delete -f clusters/on-prem/manifests/22-cockroachdb/03-cockroach-cluster.yaml
kubectl delete -f clusters/on-prem/manifests/22-cockroachdb/02-client-tls-certificate.yaml
kubectl delete -f clusters/on-prem/manifests/22-cockroachdb/01-node-tls-certificate.yaml
kubectl delete namespace cockroachdb
```