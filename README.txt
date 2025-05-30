
# EKS Sample Project with NGINX Web Server using Terraform and Ingress

This project provisions an Amazon EKS cluster using Terraform and deploys a sample HTML page served via an NGINX web server, exposed publicly using the NGINX Ingress Controller.

---

## 📁 Project Structure

- `modules/eks/`
  - Contains Terraform modules to:
    - Create IAM roles for EKS cluster and worker nodes:
      - `AmazonEKSClusterPolicy`
      - `AmazonEKSWorkerNodePolicy`
      - `AmazonEKS_CNI_Policy`
      - `AmazonEC2ContainerRegistryReadOnly`
    - Provision VPC with:
      - 2 public subnets (for LoadBalancer/Ingress Controller)
      - 2 private subnets (for EKS control plane and worker nodes)
      - Internet Gateway and NAT Gateway
      - Route tables for public and private routing

- `environments/dev/`
  - `main.tf`: Uses the module from `modules/eks`
  - `terraform.tfvars`: Contains environment-specific variable values

---

## ⚙️ Prerequisites

- AWS CLI v2
- Terraform v1.3+ (or compatible)
- `kubectl`
- Properly configured AWS credentials (IAM user/role with EKS and EC2 access)
- IAM permissions for creating clusters, VPC, IAM roles, etc.

---

## 🚀 Step-by-Step Instructions to Deploy the EKS Cluster and App

### 1. Navigate to the dev environment folder

```bash
cd environments/dev
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Validate the Terraform code

```bash
terraform validate
```

### 4. Preview the planned changes

```bash
terraform plan
```

### 5. Apply the Terraform plan to provision infrastructure

```bash
terraform apply
```

> This step creates the EKS cluster, VPC, IAM roles, and node groups.

---

## 🔐 Configure `kubectl` to Access the EKS Cluster

Once the Terraform apply completes successfully, run the following command:

```bash
aws eks update-kubeconfig --name devcluster --region us-west-2
```

> This command updates your local kubeconfig file so you can interact with the cluster using `kubectl`.

---

## 📦 Deploy the Web Application

### 1. Create a Kubernetes namespace

```bash
kubectl apply -f ns.yaml
```

### 2. Create a ConfigMap with sample HTML content

```bash
kubectl apply -f index-configmap.yaml
```

### 3. Install the NGINX Ingress Controller (for AWS)

```bash
curl -o ingress-nginx.yaml https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.2/deploy/static/provider/aws/deploy.yaml
kubectl apply -f ingress-nginx.yaml
```

> This step creates an external AWS LoadBalancer in the public subnet.

### 4. Deploy the NGINX web server with HTML content

```bash
kubectl apply -f deployment.yaml
```

---

## 🌐 Access the Web Application

### 1. Get the LoadBalancer’s DNS name

```bash
kubectl get svc -n ingress-nginx
```

Look for the `EXTERNAL-IP` under the `ingress-nginx-controller` service.

### 2. Open the app in your browser

```
http://<external-loadbalancer-dns>
```

---

## ✅ Useful `kubectl` Commands

- View all namespaces:

```bash
kubectl get ns
```

- View all pods in all namespaces:

```bash
kubectl get pods -A
```

- Describe a pod (for debugging):

```bash
kubectl describe pod <pod-name> -n <namespace>
```

- Check ingress resources:

```bash
kubectl get ingress -A
```

---

## 🧹 Clean Up

To delete all infrastructure created by Terraform:

```bash
cd environments/dev
terraform destroy
```

To clean up Kubernetes resources:

```bash
kubectl delete -f deployment.yaml
kubectl delete -f ingress-nginx.yaml
kubectl delete -f index-configmap.yaml
kubectl delete -f ns.yaml
```

---

## 📂 Required YAML Files

Ensure the following YAML files are present and correctly configured:

- `ns.yaml`: Creates the `devproject` namespace
- `index-configmap.yaml`: Stores sample HTML content as a ConfigMap (with `index.html` key)
- `deployment.yaml`: Creates Deployment, Service, and Ingress to serve the web content

---
