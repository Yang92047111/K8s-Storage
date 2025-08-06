# 🧪 Kubernetes Storage Experiment: PV, PVC, and StorageClass

## 📘 Objective

This experiment demonstrates Kubernetes storage concepts through a hands-on project using:

* **PersistentVolume (PV)** - Static storage provisioning
* **PersistentVolumeClaim (PVC)** - Storage requests from applications  
* **StorageClass** - Dynamic storage provisioning configuration

## 🎯 What You'll Learn

* How to create and configure Kubernetes storage resources
* Storage persistence across pod restarts
* Local storage provisioning with Kind
* Container resource management and health checks
* E2E testing of storage functionality

## 📚 Kubernetes Storage Concepts

### 🗄️ PersistentVolume (PV)
A **PersistentVolume** is a cluster-wide storage resource that exists independently of any pod. Think of it as a "storage slot" that Kubernetes manages.

**Key characteristics:**
- **Cluster-scoped**: Available to all namespaces
- **Lifecycle independent**: Survives pod deletion and recreation
- **Admin-provisioned**: Usually created by cluster administrators
- **Storage abstraction**: Hides underlying storage implementation details

In this project, our PV uses `hostPath` storage, mapping to `/mnt/data` on the Kind node.

### 📋 PersistentVolumeClaim (PVC)
A **PersistentVolumeClaim** is a request for storage by a pod. It's like a "storage reservation" that applications use to claim storage resources.

**Key characteristics:**
- **Namespace-scoped**: Belongs to a specific namespace
- **Resource request**: Specifies size, access modes, and storage class
- **Binding process**: Kubernetes matches PVCs to suitable PVs
- **Pod consumption**: Pods reference PVCs, not PVs directly

Our PVC requests 1Gi of storage with `ReadWriteOnce` access mode.

### ⚙️ StorageClass
A **StorageClass** defines different "classes" of storage with specific characteristics and provisioning methods.

**Key characteristics:**
- **Dynamic provisioning**: Can automatically create PVs when PVCs are created
- **Storage parameters**: Defines performance, replication, and other storage features
- **Provisioner**: Specifies which storage system to use
- **Binding modes**: Controls when volume binding occurs

Our StorageClass uses:
- `kubernetes.io/no-provisioner`: No automatic PV creation (static provisioning)
- `WaitForFirstConsumer`: Delays binding until a pod uses the PVC

### 🔄 How They Work Together

```
┌─────────────┐    requests    ┌─────────────┐    binds to    ┌─────────────┐
│     Pod     │ ──────────────► │     PVC     │ ──────────────► │     PV      │
└─────────────┘                └─────────────┘                └─────────────┘
                                       │                              │
                                       │ uses                         │ created by
                                       ▼                              ▼
                               ┌─────────────┐                ┌─────────────┐
                               │StorageClass │                │   Admin     │
                               └─────────────┘                └─────────────┘
```

1. **Admin creates** PV and StorageClass
2. **Application creates** PVC requesting storage
3. **Kubernetes binds** PVC to suitable PV based on StorageClass
4. **Pod mounts** the PVC as a volume

## 🏗️ Architecture

* **Go REST API** with `/write` endpoint that persists data to mounted volume
* **Static PV** using `hostPath` for local development
* **Custom StorageClass** with `WaitForFirstConsumer` binding
* **Comprehensive testing** including unit tests and E2E validation

---

## 📁 Project Structure

```bash
k8s-storage-experiment/
├── go-app/
│   ├── main.go
│   ├── storage/
│   │   └── writer.go
│   └── main_test.go
├── manifests/
│   ├── pv.yaml
│   ├── pvc.yaml
│   ├── storageclass.yaml
│   └── deployment.yaml
├── scripts/
│   ├── setup-kind.sh
│   ├── deploy.sh
│   ├── test.sh
├── Dockerfile
├── Makefile
└── README.md
```

---

## ✅ Features Implemented

### 🛠️ Infrastructure
* ✅ Kind cluster setup with storage support
* ✅ Custom StorageClass (`local-storage`) with proper binding mode
* ✅ Static PV and PVC configuration
* ✅ Deployment with volume mounts and resource limits

### 🧑‍💻 Application
* ✅ Go REST API with `/write?msg=hello` endpoint
* ✅ Health check endpoint at `/health`
* ✅ Structured storage package with `Writer` interface
* ✅ Multi-stage Docker build with static binary compilation
* ✅ Proper error handling and logging

### 🧪 Testing & Validation
* ✅ Unit tests for storage functionality
* ✅ E2E test script with persistence validation
* ✅ Automated pod restart testing
* ✅ PVC binding status verification
* ✅ Health checks and readiness probes

---

## 🚀 Quick Start

```bash
# Complete setup and testing
make all

# Or step by step
make setup    # Create Kind cluster  
make deploy   # Build and deploy everything
make test     # Run E2E tests
make clean    # Cleanup when done
```

## 📦 Application Endpoints

* `GET /write?msg=<message>` - Write message to persistent storage
* `GET /health` - Health check endpoint

## 🧪 Testing

```bash
# Run unit tests
make unit-test

# Run E2E tests (requires deployed app)
make test
```

---

## 📄 Kubernetes Manifests (`/manifests`)

### 🏷️ `storageclass.yaml` - Storage Configuration

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage                    # Name referenced by PVCs
provisioner: kubernetes.io/no-provisioner # No dynamic provisioning
volumeBindingMode: WaitForFirstConsumer   # Bind when pod is scheduled
```

**Field explanations:**
- `provisioner: kubernetes.io/no-provisioner`: Uses static PVs (no automatic creation)
- `volumeBindingMode: WaitForFirstConsumer`: Delays PVC binding until a pod that uses the PVC is scheduled. This ensures the PV is in the same zone/node as the pod.

### 💾 `pv.yaml` - Physical Storage Definition

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv                         # Unique PV identifier
spec:
  capacity:
    storage: 1Gi                         # Available storage space
  accessModes:
    - ReadWriteOnce                      # Single node read-write access
  storageClassName: local-storage        # Links to StorageClass
  hostPath:
    path: "/mnt/data"                    # Host directory path
```

**Field explanations:**
- `capacity.storage: 1Gi`: Total storage capacity available
- `accessModes: ReadWriteOnce`: Volume can be mounted read-write by a single node
- `storageClassName`: Must match the StorageClass name for proper binding
- `hostPath.path`: Directory on the Kind node where data is stored

**Access Modes:**
- `ReadWriteOnce` (RWO): Mount read-write by single node
- `ReadOnlyMany` (ROX): Mount read-only by many nodes  
- `ReadWriteMany` (RWX): Mount read-write by many nodes

### 📝 `pvc.yaml` - Storage Request

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc                        # PVC name used by pods
spec:
  accessModes:
    - ReadWriteOnce                      # Must match PV access mode
  storageClassName: local-storage        # Requests specific storage class
  resources:
    requests:
      storage: 1Gi                       # Minimum storage needed
```

**Field explanations:**
- `accessModes`: Must be compatible with target PV access modes
- `storageClassName`: Specifies which StorageClass to use for binding
- `resources.requests.storage`: Minimum storage capacity required (can be less than PV capacity)

### `deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: go-app
  template:
    metadata:
      labels:
        app: go-app
    spec:
      containers:
        - name: app
          image: go-app:latest
          imagePullPolicy: Never  # Use local image
          ports:
            - containerPort: 8080
          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 10
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
          resources:
            requests:
              memory: "64Mi"
              cpu: "100m"
            limits:
              memory: "128Mi"
              cpu: "200m"
          volumeMounts:
            - mountPath: /data
              name: storage
      volumes:
        - name: storage
          persistentVolumeClaim:
            claimName: local-pvc
```

---

## 🔧 Key Configuration Details

### Resource Management
```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "100m"
  limits:
    memory: "128Mi" 
    cpu: "200m"
```

### Health Checks
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
readinessProbe:
  httpGet:
    path: /health
    port: 8080
```

### Static Binary Compilation
```dockerfile
RUN CGO_ENABLED=0 GOOS=linux go build -o main .
```

---

## 🐳 Docker Build

Multi-stage build with static binary compilation for Alpine compatibility:

```dockerfile
FROM golang:1.21 as builder
WORKDIR /app
COPY go-app/ .
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

FROM alpine
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]
```

---

## 🧪 Shell Scripts

### `scripts/setup-kind.sh`

```bash
#!/bin/bash
kind create cluster --name storage-demo
```

### `scripts/deploy.sh`

```bash
#!/bin/bash
set -e
kubectl apply -f manifests/storageclass.yaml
kubectl apply -f manifests/pv.yaml
kubectl apply -f manifests/pvc.yaml
docker build -t go-app:latest ./go-app
kind load docker-image go-app:latest
kubectl apply -f manifests/deployment.yaml
```

### `scripts/test.sh`

```bash
#!/bin/bash
set -e
POD=$(kubectl get pod -l app=go-app -o jsonpath="{.items[0].metadata.name}")
kubectl wait --for=condition=Ready pod/$POD --timeout=60s

echo "Sending write request..."
curl "http://localhost:8080/write?msg=kind-storage-test"

sleep 1
kubectl exec $POD -- cat /data/output.txt | grep "kind-storage-test" && echo "✅ Data written successfully"
```

---

## 📋 Prerequisites

* [Docker](https://docs.docker.com/get-docker/)
* [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [Go 1.21+](https://golang.org/doc/install) (for local development)

## 🧪 Usage Examples

### Write Data
```bash
# Port forward to access the service
kubectl port-forward svc/go-app-service 8080:8080 &

# Write some data
curl "http://localhost:8080/write?msg=hello-kubernetes"

# Verify data persistence
kubectl exec -it deployment/go-app -- cat /data/output.txt
```

### Monitor Resources
```bash
# Check pod status
kubectl get pods -l app=go-app

# Check PVC binding
kubectl get pvc

# View logs
kubectl logs -l app=go-app -f
```

---

## 🔍 Troubleshooting

### Common Issues

**ImagePullBackOff**: Ensure `imagePullPolicy: Never` is set and image is loaded into Kind
```bash
kind load docker-image go-app:latest --name storage-demo
```

**Pod CrashLoopBackOff**: Check if binary is compatible with Alpine
```bash
kubectl logs -l app=go-app
```

**PVC Pending**: Verify StorageClass and PV are created
```bash
kubectl get storageclass,pv,pvc
```

## 🧼 Cleanup

```bash
make clean
# or manually:
kind delete cluster --name storage-demo
```

## 🎯 Learning Outcomes

After completing this experiment, you'll understand:

* How Kubernetes storage abstraction works
* The relationship between StorageClass, PV, and PVC
* Storage persistence across pod lifecycles
* Resource management and health checks in Kubernetes
* Local development workflows with Kind

## 📜 License

MIT License
