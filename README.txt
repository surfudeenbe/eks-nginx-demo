
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

---------------------------------------------------------------------


📊 Monitoring & Alerting Setup with Prometheus, Grafana, and Alertmanager on EKS
This section guides you through installing Prometheus and Grafana on your EKS cluster using Helm, configuring Alertmanager for email alerts via Gmail SMTP, and creating a test alert.

Step 1: Prerequisites


Helm installed locally

Gmail account with App Password enabled for SMTP authentication

Step 2: Add Helm Repositories

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

Step 3: Create Namespace 
kubectl create namespace prometheus

Step 4: Install kube-prometheus-stack via Helm
This stack includes Prometheus, Alertmanager, Grafana, node-exporter, and kube-state-metrics.

helm install stable prometheus-community/kube-prometheus-stack -n prometheus
Verify pods are running:
kubectl get pods -n prometheus

Step 5: Configure Alertmanager for Email Alerts
Created a file named alertmanager-config.yaml inside dev/ with my SMTP email settings:

Step 6: Create Kubernetes Secret for Alertmanager Configuration

kubectl create secret generic alertmanager-stable-kube-prometheus-sta-alertmanager \
  --from-file=alertmanager.yaml=alertmanager-config.yaml \
  -n prometheus --dry-run=client -o yaml | kubectl apply -f -
  
Step 7: Restart Alertmanager Pods to Load New Config

kubectl delete pod -l app.kubernetes.io/name=alertmanager -n prometheus
Verify pods restart:

kubectl get pods -n prometheus

Step 8: Verify Alertmanager UI
Port-forward Alertmanager service:

kubectl port-forward svc/stable-kube-prometheus-sta-alertmanager -n prometheus 9093
Open in browser: http://localhost:9093

Check the status and ensure your email receiver is configured.

Step 9: Create a Test Alert Rule (prometheusRule Object) to create new custom alert rule and this will reflected in grafana and alert-manager as well
Created crashloop.yaml inside dev/ folder:
kubectl apply -f crashloop.yaml

Step 10: Confirm Alert Firing and Email Delivery
Check Alertmanager UI for alert status

Wait ~1-2 minutes to receive an email notification

Step 11: Access Grafana Dashboard
Port-forward Grafana service:
kubectl port-forward svc/stable-grafana -n prometheus 3000:80
Open in browser: http://localhost:3000

Login credentials:

Username: admin

Password: Retrieve with:
kubectl get secret -n prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode

to test with failing pod run :
kubectl run failpod --image=busybox --restart=Always -- /bin/false


