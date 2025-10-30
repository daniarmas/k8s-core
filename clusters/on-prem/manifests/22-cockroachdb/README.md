# CockroachDB

CockroachDB is a distributed, cloud-native SQL database engineered for survivability, horizontal scalability, and strong consistency. It provides ACID transactions, automatic rebalancing, and built‑in replication for fault tolerance and multi‑region deployments while remaining compatible with the PostgreSQL wire protocol.

## Installation

### 1. Install the CockroachDB CRDs
```bash
kubectl apply -f https://raw.githubusercontent.com/cockroachdb/cockroach-operator/master/install/crds.yaml
```

### 2. Install the CockroachDB CRDs
```bash
kubectl apply -f https://raw.githubusercontent.com/cockroachdb/cockroach-operator/master/install/operator.yaml
```

### 3. Create the namespace
```bash
kubectl create namespace cockroachdb
```

### 4. Issue the node tls certificate
```bash
kubectl apply -f clusters/on-prem/manifests/22-cockroachdb/01-node-tls-certificate.yaml
```

### 5. Issue the client tls certificate
```bash
kubectl apply -f clusters/on-prem/manifests/22-cockroachdb/02-client-tls-certificate.yaml
```

### 6. Create the cluster
```bash
kubectl apply -f clusters/on-prem/manifests/22-cockroachdb/03-cockroach-cluster.yaml
```