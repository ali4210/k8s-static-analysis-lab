# KCNA Complete Master Guide
## Kubernetes and Cloud Native Associate Certification Labs

**Author:** Saleem Ali  
**Course:** AIOps - Al-Nafi International College  
**Certification:** KCNA (Kubernetes and Cloud Native Associate)  
**Level:** Entry-Level | **Duration:** 90 minutes | **Passing Score:** 75%  
**GitHub:** https://github.com/ali4210  
**LinkedIn:** https://www.linkedin.com/in/saleem-ali-189719325/

---

## 🎯 About KCNA Certification

The **Kubernetes and Cloud Native Associate (KCNA)** is an entry-level certification by the Cloud Native Computing Foundation (CNCF) that validates your understanding of Kubernetes and cloud-native technologies.

**Exam Format:**
- 60 multiple-choice questions
- 90 minutes duration
- 75% passing score
- Online proctored exam
- $250 USD exam fee
- 3-year validity

---

## 🖥️ Lab Environment Options

This guide supports **TWO** Kubernetes environments. Choose based on your learning goals:

### Option 1: Minikube (Single-Node) - Recommended for Beginners

```
┌─────────────────────────────┐
│    Your Machine             │
│  (Kali Linux/Ubuntu)        │
│                             │
│  ┌───────────────────────┐  │
│  │  Minikube Cluster     │  │
│  │  Control Plane +      │  │
│  │  Worker (All-in-One)  │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

**Best For:** Quick setup, learning basics, testing, development

### Option 2: Kubeadm Multi-Node - Production-Like Setup

```
┌─────────────────┐
│  Master Node    │
│  (Kali Linux)   │
│  Control Plane  │
└────────┬────────┘
         │
    ┌────┴────┬─────────┬──────────┐
    │         │         │          │
┌───▼───┐ ┌──▼───┐ ┌───▼────┐ ┌───▼────┐
│Parrot │ │Parrot│ │ Ubuntu │ │ Parrot │
│Worker │ │Worker│ │ Worker │ │ Worker │
│ Node  │ │ Node │ │  Node  │ │  Node  │
└───────┘ └──────┘ └────────┘ └────────┘
```

**Best For:** Real-world scenarios, distributed systems, production practice

---

## 📋 Table of Contents


Lab 1: Exploring Container Orchestration
Objectives

By the end of this lab, students will be able to:

• Understand the challenges of manually managing containerized applications • Deploy multiple containerized applications without orchestration tools • Identify and experience common issues such as port conflicts and resource management problems • Simulate scaling scenarios and observe manual intervention requirements • Analyze failure scenarios and recovery challenges in non-orchestrated environments • Explain how container orchestration platforms address these operational challenges • Compare manual container management with orchestrated solutions
Prerequisites

Before starting this lab, students should have:

• Basic understanding of Linux command line operations • Fundamental knowledge of Docker containers and basic Docker commands • Understanding of networking concepts (ports, IP addresses) • Familiarity with text editors (nano, vim, or similar) • Basic knowledge of web applications and HTTP protocols
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with Docker already installed. Simply click Start Lab to access your environment - no need to build your own VM or install Docker manually.

Your lab environment includes: • Ubuntu 20.04 LTS with Docker Engine installed • Pre-configured user with sudo privileges • Network access for downloading container images • Multiple terminal sessions available
Task 1: Deploy Two Containerized Applications Manually
Subtask 1.1: Verify Docker Installation and Prepare Environment

First, let's verify that Docker is properly installed and running on your system.

# Check Docker version
docker --version

# Check Docker service status
sudo systemctl status docker

# Verify Docker is running by listing containers
docker ps

Create a working directory for this lab:

# Create lab directory
mkdir ~/container-orchestration-lab
cd ~/container-orchestration-lab

# Create subdi

---

## 🔧 Environment Setup Instructions

### Minikube Setup (Single-Node)

**Prerequisites:**
- 2 CPUs or more
- 2GB+ free memory
- 20GB+ free disk space
- Docker or VirtualBox installed

**Installation:**
```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube
minikube start --driver=docker --memory=2048 --cpus=2

# Verify
kubectl cluster-info
kubectl get nodes
```

### Kubeadm Multi-Node Setup

**On Master Node (Kali Linux):**
```bash
# Install container runtime (containerd)
sudo apt-get update
sudo apt-get install -y containerd

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd

# Install kubeadm, kubelet, kubectl
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Initialize cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Configure kubectl for your user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install network plugin (Flannel)
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

**On Worker Nodes (Parrot/Ubuntu):**
```bash
# Install container runtime and kubernetes tools (same as master)
# Then join the cluster using the command from kubeadm init output:
sudo kubeadm join <master-ip>:6443 --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash>
```

**Verify Multi-Node Cluster:**
```bash
# On master node
kubectl get nodes
kubectl get pods -A
```

---


Lab 1: Exploring Container Orchestration
Objectives

By the end of this lab, students will be able to:

• Understand the challenges of manually managing containerized applications • Deploy multiple containerized applications without orchestration tools • Identify and experience common issues such as port conflicts and resource management problems • Simulate scaling scenarios and observe manual intervention requirements • Analyze failure scenarios and recovery challenges in non-orchestrated environments • Explain how container orchestration platforms address these operational challenges • Compare manual container management with orchestrated solutions
Prerequisites

Before starting this lab, students should have:

• Basic understanding of Linux command line operations • Fundamental knowledge of Docker containers and basic Docker commands • Understanding of networking concepts (ports, IP addresses) • Familiarity with text editors (nano, vim, or similar) • Basic knowledge of web applications and HTTP protocols
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with Docker already installed. Simply click Start Lab to access your environment - no need to build your own VM or install Docker manually.

Your lab environment includes: • Ubuntu 20.04 LTS with Docker Engine installed • Pre-configured user with sudo privileges • Network access for downloading container images • Multiple terminal sessions available
Task 1: Deploy Two Containerized Applications Manually
Subtask 1.1: Verify Docker Installation and Prepare Environment

First, let's verify that Docker is properly installed and running on your system.

# Check Docker version
docker --version

# Check Docker service status
sudo systemctl status docker

# Verify Docker is running by listing containers
docker ps

Create a working directory for this lab:

# Create lab directory
mkdir ~/container-orchestration-lab
cd ~/container-orchestration-lab

# Create subdirectories for our applications
mkdir app1 app2

Subtask 1.2: Deploy First Application - Web Server

We'll deploy a simple nginx web server as our first application.

# Pull nginx image
docker pull nginx:latest

# Run first nginx container on port 8080
docker run -d \
  --name web-app-1 \
  -p 8080:80 \
  nginx:latest

# Verify the container is running
docker ps

# Test the application
curl http://localhost:8080

Create a custom HTML page for our first application:

# Create custom HTML content
cat > ~/container-orchestration-lab/app1/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Web Application 1</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #e3f2fd; text-align: center; padding: 50px; }
        h1 { color: #1976d2; }
    </style>
</head>
<body>
    <h1>Welcome to Web Application 1</h1>
    <p>This is running on port 8080</p>
    <p>Container ID: <span id="hostname"></span></p>
    <script>
        document.getElementById('hostname').textContent = window.location.hostname;
    </script>
</body>
</html>
EOF

# Copy custom content to running container
docker cp ~/container-orchestration-lab/app1/index.html web-app-1:/usr/share/nginx/html/index.html

# Verify custom content
curl http://localhost:8080

Subtask 1.3: Deploy Second Application - Another Web Server

Now let's deploy a second web application and observe port conflict issues.

# Attempt to run second nginx container on the same port (this will fail)
docker run -d \
  --name web-app-2 \
  -p 8080:80 \
  nginx:latest

Expected Result: This command will fail with a port binding error. This demonstrates our first challenge - port conflicts.

# Check the error message
docker logs web-app-2

# Run second container on a different port
docker run -d \
  --name web-app-2-fixed \
  -p 8081:80 \
  nginx:latest

# Verify both containers are running
docker ps

Create custom content for the second application:

# Create custom HTML for second app
cat > ~/container-orchestration-lab/app2/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Web Application 2</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f3e5f5; text-align: center; padding: 50px; }
        h1 { color: #7b1fa2; }
    </style>
</head>
<body>
    <h1>Welcome to Web Application 2</h1>
    <p>This is running on port 8081</p>
    <p>Container ID: <span id="hostname"></span></p>
    <script>
        document.getElementById('hostname').textContent = window.location.hostname;
    </script>
</body>
</html>
EOF

# Copy custom content to second container
docker cp ~/container-orchestration-lab/app2/index.html web-app-2-fixed:/usr/share/nginx/html/index.html

# Test both applications
echo "Testing Application 1:"
curl http://localhost:8080
echo -e "\nTesting Application 2:"
curl http://localhost:8081

Subtask 1.4: Analyze Resource Management Challenges

Let's examine resource usage and management challenges.

# Check resource usage of containers
docker stats --no-stream

# Check detailed container information
docker inspect web-app-1 | grep -A 10 "Memory"
docker inspect web-app-2-fixed | grep -A 10 "Memory"

# Run containers with resource limits
docker run -d \
  --name web-app-3-limited \
  --memory="128m" \
  --cpus="0.5" \
  -p 8082:80 \
  nginx:latest

# Compare resource usage
docker stats --no-stream web-app-1 web-app-2-fixed web-app-3-limited

Create a script to monitor resource usage:

# Create monitoring script
cat > ~/container-orchestration-lab/monitor.sh << 'EOF'
#!/bin/bash
echo "Container Resource Monitoring"
echo "============================="
while true; do
    clear
    echo "$(date)"
    echo "Container Status:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    echo "Resource Usage:"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
    echo ""
    echo "Press Ctrl+C to stop monitoring"
    sleep 5
done
EOF

# Make script executable
chmod +x ~/container-orchestration-lab/monitor.sh

# Run monitoring script (let it run for 30 seconds, then stop with Ctrl+C)
./monitor.sh

Task 2: Simulate Scaling and Failure Scenarios
Subtask 2.1: Manual Scaling Challenges

Let's simulate the need to scale our applications and observe the manual effort required.

# Create a script to deploy multiple instances manually
cat > ~/container-orchestration-lab/scale-app.sh << 'EOF'
#!/bin/bash

APP_NAME="web-app"
BASE_PORT=9000
INSTANCES=5

echo "Manually scaling $APP_NAME to $INSTANCES instances..."

for i in $(seq 1 $INSTANCES); do
    PORT=$((BASE_PORT + i))
    CONTAINER_NAME="${APP_NAME}-instance-${i}"
    
    echo "Deploying $CONTAINER_NAME on port $PORT"
    
    docker run -d \
      --name $CONTAINER_NAME \
      -p $PORT:80 \
      nginx:latest
    
    if [ $? -eq 0 ]; then
        echo "✓ Successfully deployed $CONTAINER_NAME"
    else
        echo "✗ Failed to deploy $CONTAINER_NAME"
    fi
    
    sleep 2
done

echo "Scaling complete. Checking status..."
docker ps | grep web-app-instance
EOF

# Make script executable and run it
chmod +x ~/container-orchestration-lab/scale-app.sh
./scale-app.sh

Now let's test all our scaled instances:

# Create a script to test all instances
cat > ~/container-orchestration-lab/test-instances.sh << 'EOF'
#!/bin/bash

echo "Testing all application instances..."
echo "=================================="

for port in {9001..9005}; do
    echo "Testing instance on port $port:"
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port)
    if [ $response -eq 200 ]; then
        echo "✓ Port $port: OK"
    else
        echo "✗ Port $port: Failed (HTTP $response)"
    fi
done
EOF

chmod +x ~/container-orchestration-lab/test-instances.sh
./test-instances.sh

Subtask 2.2: Simulate Container Failures

Let's simulate container failures and observe the manual recovery process.

# Stop a few containers to simulate failures
echo "Simulating container failures..."
docker stop web-app-instance-2 web-app-instance-4

# Check which containers are still running
docker ps | grep web-app-instance

# Test instances again to see failures
./test-instances.sh

# Manual recovery process
echo "Manual recovery process:"
echo "1. Identify failed containers"
docker ps -a | grep web-app-instance | grep Exited

echo "2. Restart failed containers manually"
docker start web-app-instance-2
docker start web-app-instance-4

echo "3. Verify recovery"
./test-instances.sh

Subtask 2.3: Load Balancing Challenges

Without orchestration, load balancing requires manual configuration. Let's explore this challenge.

# Install nginx for load balancing (if not already available)
sudo apt-get update
sudo apt-get install -y nginx

# Create nginx load balancer configuration
sudo tee /etc/nginx/sites-available/load-balancer << 'EOF'
upstream backend {
    server localhost:9001;
    server localhost:9002;
    server localhost:9003;
    server localhost:9004;
    server localhost:9005;
}

server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Enable the configuration
sudo ln -sf /etc/nginx/sites-available/load-balancer /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx

# Test load balancing
echo "Testing load balancer:"
for i in {1..10}; do
    echo "Request $i:"
    curl -s http://localhost | grep -o "Welcome to.*" || echo "Failed"
    sleep 1
done

Task 3: Document and Analyze Challenges
Subtask 3.1: Create Challenge Documentation

Let's document all the challenges we've encountered:

# Create comprehensive challenge report
cat > ~/container-orchestration-lab/challenges-report.md << 'EOF'
# Container Management Challenges Report

## 1. Port Conflicts
- **Issue**: Multiple containers cannot bind to the same port
- **Manual Solution**: Track and assign unique ports for each container
- **Complexity**: Increases with number of applications and instances

## 2. Resource Management
- **Issue**: No automatic resource allocation or limits
- **Manual Solution**: Manually set memory and CPU limits for each container
- **Risk**: Resource contention and system instability

## 3. Scaling Challenges
- **Issue**: Manual deployment of multiple instances
- **Time Consuming**: Each instance requires individual commands
- **Error Prone**: High chance of configuration mistakes

## 4. Failure Recovery
- **Issue**: No automatic restart of failed containers
- **Manual Process**: Constant monitoring and manual intervention required
- **Downtime**: Extended service interruption during manual recovery

## 5. Load Balancing
- **Issue**: No built-in load distribution
- **Manual Setup**: Requires separate load balancer configuration
- **Maintenance**: Manual updates when instances change

## 6. Service Discovery
- **Issue**: Hard-coded IP addresses and ports
- **Brittle**: Configuration breaks when containers restart with new IPs
- **Scalability**: Difficult to manage as system grows

## 7. Configuration Management
- **Issue**: No centralized configuration management
- **Inconsistency**: Different configurations across instances
- **Updates**: Manual updates to each container individually
EOF

# Display the report
cat ~/container-orchestration-lab/challenges-report.md

Subtask 3.2: Performance Impact Analysis

Let's measure the performance impact of our manual setup:

# Create performance testing script
cat > ~/container-orchestration-lab/performance-test.sh << 'EOF'
#!/bin/bash

echo "Performance Impact Analysis"
echo "=========================="

# Test response times
echo "1. Response Time Analysis:"
for port in {9001..9005}; do
    echo "Testing port $port:"
    time curl -s http://localhost:$port > /dev/null
done

# Test concurrent requests
echo -e "\n2. Concurrent Request Handling:"
echo "Sending 50 concurrent requests to load balancer..."
time for i in {1..50}; do
    curl -s http://localhost > /dev/null &
done
wait

# Resource utilization during load
echo -e "\n3. Resource Utilization:"
docker stats --no-stream | grep web-app-instance
EOF

chmod +x ~/container-orchestration-lab/performance-test.sh
./performance-test.sh

Task 4: Demonstrate Orchestration Benefits
Subtask 4.1: Compare with Orchestration Concepts

Let's create a comparison document showing how orchestration would solve our challenges:

# Create orchestration benefits comparison
cat > ~/container-orchestration-lab/orchestration-benefits.md << 'EOF'
# Container Orchestration Benefits

## How Orchestration Solves Our Challenges

### 1. Automatic Port Management
- **Orchestration Solution**: Service mesh and automatic port allocation
- **Benefit**: No manual port conflict resolution needed
- **Example**: Kubernetes Services abstract port management

### 2. Resource Management
- **Orchestration Solution**: Resource quotas and automatic scaling
- **Benefit**: Automatic resource allocation based on demand
- **Example**: Kubernetes ResourceQuotas and HorizontalPodAutoscaler

### 3. Scaling
- **Orchestration Solution**: Declarative scaling with single commands
- **Benefit**: Scale from 1 to 100 instances with one command
- **Example**: `kubectl scale deployment myapp --replicas=10`

### 4. Self-Healing
- **Orchestration Solution**: Automatic failure detection and recovery
- **Benefit**: Zero-downtime automatic restart of failed containers
- **Example**: Kubernetes ReplicaSets ensure desired state

### 5. Load Balancing
- **Orchestration Solution**: Built-in service discovery and load balancing
- **Benefit**: Automatic traffic distribution without manual configuration
- **Example**: Kubernetes Services provide automatic load balancing

### 6. Service Discovery
- **Orchestration Solution**: DNS-based service discovery
- **Benefit**: Services find each other automatically by name
- **Example**: Kubernetes DNS allows services to communicate by name

### 7. Configuration Management
- **Orchestration Solution**: ConfigMaps and Secrets
- **Benefit**: Centralized configuration management
- **Example**: Update configuration once, applies to all instances

## Orchestration Platforms Comparison

| Feature | Manual Management | Docker Swarm | Kubernetes |
|---------|------------------|--------------|------------|
| Scaling | Manual scripts | `docker service scale` | `kubectl scale` |
| Load Balancing | External setup | Built-in | Built-in |
| Self-Healing | Manual restart | Automatic | Automatic |
| Rolling Updates | Manual process | `docker service update` | `kubectl rollout` |
| Service Discovery | Hard-coded IPs | Built-in | DNS-based |
| Configuration | Individual setup | Docker configs | ConfigMaps/Secrets |
EOF

cat ~/container-orchestration-lab/orchestration-benefits.md

Subtask 4.2: Cleanup and Resource Management

Let's clean up our manual deployment and observe the effort required:

# Create cleanup script
cat > ~/container-orchestration-lab/cleanup.sh << 'EOF'
#!/bin/bash

echo "Manual Cleanup Process"
echo "====================="

# Stop all web-app containers
echo "1. Stopping all application containers..."
docker ps | grep web-app | awk '{print $1}' | xargs -r docker stop

# Remove all web-app containers
echo "2. Removing all application containers..."
docker ps -a | grep web-app | awk '{print $1}' | xargs -r docker rm

# Remove unused images (optional)
echo "3. Cleaning up unused images..."
docker image prune -f

# Stop nginx load balancer
echo "4. Stopping load balancer..."
sudo systemctl stop nginx

# Show remaining containers
echo "5. Remaining containers:"
docker ps

echo "Cleanup complete!"
echo "Note: In orchestration, this would be: 'kubectl delete deployment myapp'"
EOF

chmod +x ~/container-orchestration-lab/cleanup.sh
./cleanup.sh

Troubleshooting Common Issues
Issue 1: Port Already in Use

# Check what's using a port
sudo netstat -tulpn | grep :8080

# Kill process using port (if needed)
sudo fuser -k 8080/tcp

Issue 2: Docker Service Not Running

# Start Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

Issue 3: Permission Denied

# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login again, or use:
newgrp docker

Issue 4: Container Won't Start

# Check container logs
docker logs <container-name>

# Check container configuration
docker inspect <container-name>

Conclusion

In this lab, you have successfully:

• Experienced Manual Container Management: You deployed multiple containerized applications manually and encountered real-world challenges including port conflicts, resource management issues, and scaling difficulties.

• Identified Operational Challenges: Through hands-on experience, you discovered the complexity of managing containers without orchestration, including the need for manual intervention in failure scenarios and the time-consuming nature of scaling operations.

• Analyzed Performance Impact: You measured the performance implications of manual container management and documented the operational overhead required to maintain multiple container instances.

• Understood Orchestration Value: By comparing manual processes with orchestration capabilities, you now understand why container orchestration platforms like Kubernetes, Docker Swarm, and others are essential for production environments.
Key Takeaways

Manual Management Challenges:

    Port conflicts require careful planning and tracking
    Resource management needs constant monitoring
    Scaling is time-consuming and error-prone
    Failure recovery requires 24/7 monitoring
    Load balancing needs separate infrastructure
    Configuration management becomes complex at scale

Orchestration Benefits:

    Automatic port and resource management
    Declarative scaling with single commands
    Self-healing capabilities with zero-downtime recovery
    Built-in load balancing and service discovery
    Centralized configuration management
    Simplified deployment and update processes

Why This Matters

Container orchestration is not just a convenience—it's a necessity for production environments. As you've experienced firsthand, managing even a few containers manually becomes complex quickly. In real-world scenarios with hundreds or thousands of containers, manual management is simply impossible.

This lab has prepared you for understanding container orchestration platforms by giving you practical experience with the problems they solve. You're now ready to appreciate the value that platforms like Kubernetes bring to modern application deployment and management.

The challenges you've encountered and documented in this lab directly relate to the Kubernetes and Cloud Native Associate (KCNA) certification objectives, particularly in understanding the problems that cloud-native technologies solve and the benefits of container orchestration in production environments.
Lab Terminal
Instructions



Lab 2: Introduction to Kubernetes
Objectives

By the end of this lab, students will be able to:

• Install and configure Minikube for local Kubernetes development • Deploy a simple web application to a Kubernetes cluster • Understand core Kubernetes concepts including pods, deployments, and services • Demonstrate Kubernetes scaling capabilities by manually scaling applications • Explore Kubernetes self-healing features through pod failure simulation • Compare Kubernetes orchestration capabilities with Docker Swarm • Navigate the Kubernetes command-line interface (kubectl) effectively
Prerequisites

Before starting this lab, students should have:

• Basic understanding of containerization concepts and Docker • Familiarity with Linux command-line operations • Knowledge of YAML file structure and syntax • Understanding of basic networking concepts (ports, IP addresses) • Experience with text editors (nano, vim, or similar)
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines for this lab. Simply click Start Lab to access your dedicated environment. No need to build your own virtual machine or install additional software on your local computer.

Your cloud machine comes with: • Ubuntu 20.04 LTS operating system • Docker pre-installed and configured • Internet connectivity for downloading required packages • Administrative privileges for system configuration
Task 1: Install Kubernetes Using Minikube
Subtask 1.1: Update System and Install Dependencies

First, ensure your system is up-to-date and install necessary dependencies.

# Update package repository
sudo apt update && sudo apt upgrade -y

# Install curl and wget for downloading packages
sudo apt install -y curl wget apt-transport-https

# Install VirtualBox (required for Minikube)
sudo apt install -y virtualbox virtualbox-ext-pack

Subtask 1.2: Install kubectl

kubectl is the command-line tool for interacting with Kubernetes clusters.

# Download the latest kubectl binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make kubectl executable
chmod +x kubectl

# Move kubectl to system PATH
sudo mv kubectl /usr/local/bin/

# Verify kubectl installation
kubectl version --client

Subtask 1.3: Install Minikube

Minikube creates a local Kubernetes cluster for development and testing purposes.

# Download Minikube binary
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Install Minikube
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verify Minikube installation
minikube version

Subtask 1.4: Start Minikube Cluster

# Start Minikube with VirtualBox driver
minikube start --driver=virtualbox --memory=2048 --cpus=2

# Verify cluster status
minikube status

# Check cluster information
kubectl cluster-info

# View cluster nodes
kubectl get nodes

Expected Output: You should see one node in Ready status, indicating your Kubernetes cluster is operational.
Task 2: Deploy a Simple Application in Kubernetes
Subtask 2.1: Create Application Deployment

We'll deploy an nginx web server as our sample application.

# Create a deployment using nginx image
kubectl create deployment nginx-app --image=nginx:latest

# Verify deployment creation
kubectl get deployments

# Check pods created by the deployment
kubectl get pods

# Get detailed information about the deployment
kubectl describe deployment nginx-app

Subtask 2.2: Create Application Manifest Files

Create YAML files for better configuration management.

# Create a directory for Kubernetes manifests
mkdir ~/k8s-lab
cd ~/k8s-lab

# Create deployment manifest file
cat > nginx-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
EOF

Subtask 2.3: Apply Deployment Configuration

# Apply the deployment configuration
kubectl apply -f nginx-deployment.yaml

# Verify the deployment
kubectl get deployments
kubectl get pods -l app=nginx

# Check pod details
kubectl describe pods -l app=nginx

Subtask 2.4: Expose Application with Service

Create a service to make the application accessible.

# Create service manifest file
cat > nginx-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: NodePort
EOF

# Apply the service configuration
kubectl apply -f nginx-service.yaml

# Verify service creation
kubectl get services

# Get service details
kubectl describe service nginx-service

Subtask 2.5: Access the Application

# Get Minikube IP address
minikube ip

# Get service URL
minikube service nginx-service --url

# Test application accessibility
curl $(minikube service nginx-service --url)

Expected Output: You should see the default nginx welcome page HTML content.
Task 3: Explore Kubernetes Key Features
Subtask 3.1: Demonstrate Scaling Capabilities

Horizontal scaling allows you to increase or decrease the number of application instances.

# Check current number of replicas
kubectl get deployments nginx-deployment

# Scale up to 5 replicas
kubectl scale deployment nginx-deployment --replicas=5

# Verify scaling operation
kubectl get pods -l app=nginx

# Watch pods being created in real-time
kubectl get pods -l app=nginx -w

Press Ctrl+C to stop watching.

# Scale down to 2 replicas
kubectl scale deployment nginx-deployment --replicas=2

# Verify scale-down operation
kubectl get pods -l app=nginx

# Check deployment status
kubectl get deployments nginx-deployment

Subtask 3.2: Explore Self-Healing Capabilities

Kubernetes automatically restarts failed containers and replaces unhealthy pods.

# List current pods with their names
kubectl get pods -l app=nginx -o wide

# Delete one pod to simulate failure
POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
kubectl delete pod $POD_NAME

# Immediately check pod status
kubectl get pods -l app=nginx

# Watch Kubernetes create a replacement pod
kubectl get pods -l app=nginx -w

Press Ctrl+C to stop watching.

Key Observation: Notice how Kubernetes immediately creates a new pod to maintain the desired replica count.
Subtask 3.3: Explore Pod Logs and Debugging

# View logs from nginx pods
kubectl logs -l app=nginx

# Get logs from a specific pod
POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
kubectl logs $POD_NAME

# Execute commands inside a pod
kubectl exec -it $POD_NAME -- /bin/bash

# Inside the pod, check nginx status
nginx -t
exit

Subtask 3.4: Resource Monitoring

# Check resource usage of nodes
kubectl top nodes

# Check resource usage of pods
kubectl top pods

# Get detailed resource information
kubectl describe nodes minikube

Task 4: Compare Kubernetes with Docker Swarm
Subtask 4.1: Create Comparison Analysis

Create a comparison document to understand the differences between orchestration tools.

# Create comparison file
cat > orchestration-comparison.md << 'EOF'
# Kubernetes vs Docker Swarm Comparison

## Architecture
**Kubernetes:**
- Master-worker architecture with multiple components
- etcd for distributed storage
- Complex but highly scalable

**Docker Swarm:**
- Simpler architecture integrated with Docker Engine
- Built-in distributed storage
- Easier to set up but less feature-rich

## Learning Curve
**Kubernetes:**
- Steeper learning curve
- More concepts to understand (pods, deployments, services, etc.)
- Extensive documentation and community support

**Docker Swarm:**
- Gentler learning curve
- Familiar Docker commands
- Limited advanced features

## Scaling Capabilities
**Kubernetes:**
- Horizontal Pod Autoscaler (HPA)
- Vertical Pod Autoscaler (VPA)
- Custom metrics scaling
- Advanced scheduling

**Docker Swarm:**
- Basic service scaling
- Simple replica management
- Limited autoscaling options

## Service Discovery
**Kubernetes:**
- DNS-based service discovery
- Service mesh integration
- Advanced networking policies

**Docker Swarm:**
- Built-in service discovery
- Overlay networks
- Basic load balancing

## Ecosystem
**Kubernetes:**
- Vast ecosystem (Helm, Istio, Prometheus)
- Cloud provider integrations
- CNCF graduated project

**Docker Swarm:**
- Limited third-party integrations
- Docker-centric ecosystem
- Simpler toolchain
EOF

# Display the comparison
cat orchestration-comparison.md

Subtask 4.2: Practical Feature Comparison

# Kubernetes deployment command
echo "Kubernetes Deployment:"
echo "kubectl create deployment app --image=nginx --replicas=3"
echo "kubectl expose deployment app --port=80 --type=NodePort"
echo ""

# Docker Swarm equivalent
echo "Docker Swarm Equivalent:"
echo "docker service create --name app --replicas 3 --publish 80:80 nginx"
echo ""

# Show current Kubernetes resources
echo "Current Kubernetes Resources:"
kubectl get all

Subtask 4.3: Decision Matrix Creation

# Create decision matrix
cat > decision-matrix.md << 'EOF'
# Orchestration Tool Decision Matrix

| Feature | Kubernetes | Docker Swarm | Winner |
|---------|------------|--------------|---------|
| Ease of Setup | Complex | Simple | Docker Swarm |
| Learning Curve | Steep | Gentle | Docker Swarm |
| Scalability | Excellent | Good | Kubernetes |
| Community Support | Extensive | Moderate | Kubernetes |
| Enterprise Features | Rich | Basic | Kubernetes |
| Cloud Integration | Excellent | Limited | Kubernetes |
| Monitoring | Advanced | Basic | Kubernetes |
| Security | Comprehensive | Basic | Kubernetes |

## Recommendation
- **Choose Kubernetes** for: Production environments, complex applications, enterprise needs
- **Choose Docker Swarm** for: Simple applications, quick prototypes, Docker-centric workflows
EOF

cat decision-matrix.md

Task 5: Advanced Kubernetes Operations
Subtask 5.1: ConfigMaps and Secrets

# Create a ConfigMap for application configuration
kubectl create configmap nginx-config --from-literal=server_name=myapp.local

# Create a Secret for sensitive data
kubectl create secret generic nginx-secret --from-literal=username=admin --from-literal=password=secretpass

# View created resources
kubectl get configmaps
kubectl get secrets

# Describe the ConfigMap
kubectl describe configmap nginx-config

Subtask 5.2: Health Checks and Probes

Create an enhanced deployment with health checks.

# Create deployment with health probes
cat > nginx-with-probes.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-with-probes
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-probes
  template:
    metadata:
      labels:
        app: nginx-probes
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
EOF

# Apply the configuration
kubectl apply -f nginx-with-probes.yaml

# Monitor pod startup
kubectl get pods -l app=nginx-probes -w

Press Ctrl+C to stop watching.
Subtask 5.3: Rolling Updates

# Update the nginx image version
kubectl set image deployment/nginx-with-probes nginx=nginx:1.22

# Watch the rolling update process
kubectl rollout status deployment/nginx-with-probes

# Check rollout history
kubectl rollout history deployment/nginx-with-probes

# Rollback if needed (optional)
# kubectl rollout undo deployment/nginx-with-probes

Task 6: Cleanup and Resource Management
Subtask 6.1: Clean Up Resources

# Delete deployments
kubectl delete deployment nginx-app
kubectl delete deployment nginx-deployment
kubectl delete deployment nginx-with-probes

# Delete services
kubectl delete service nginx-service

# Delete ConfigMaps and Secrets
kubectl delete configmap nginx-config
kubectl delete secret nginx-secret

# Verify cleanup
kubectl get all

Subtask 6.2: Stop Minikube

# Stop the Minikube cluster
minikube stop

# Check Minikube status
minikube status

# Optional: Delete the cluster completely
# minikube delete

Troubleshooting Common Issues
Issue 1: Minikube Won't Start

Problem: Minikube fails to start with VirtualBox driver.

Solution:

# Check VirtualBox installation
vboxmanage --version

# Try starting with different driver
minikube start --driver=docker

# Check system resources
free -h

Issue 2: Pods Stuck in Pending State

Problem: Pods remain in Pending status.

Solution:

# Check node resources
kubectl describe nodes

# Check pod events
kubectl describe pod <pod-name>

# Check if images can be pulled
kubectl get events --sort-by=.metadata.creationTimestamp

Issue 3: Service Not Accessible

Problem: Cannot access application through service.

Solution:

# Check service endpoints
kubectl get endpoints

# Verify pod labels match service selector
kubectl get pods --show-labels

# Test service connectivity from within cluster
kubectl run test-pod --image=busybox --rm -it -- wget -qO- nginx-service

Conclusion

In this comprehensive lab, you have successfully:

• Installed and configured Minikube to create a local Kubernetes development environment • Deployed applications using both imperative commands and declarative YAML manifests • Explored core Kubernetes concepts including pods, deployments, services, and resource management • Demonstrated scaling capabilities by manually adjusting replica counts and observing automatic pod management • Experienced self-healing features through pod failure simulation and automatic recovery • Compared Kubernetes with Docker Swarm to understand different orchestration approaches and use cases • Implemented advanced features such as health probes, rolling updates, and configuration management

Why This Matters: Kubernetes has become the de facto standard for container orchestration in enterprise environments. The skills you've developed in this lab are directly applicable to:

    Cloud-native application development and deployment
    DevOps practices including CI/CD pipeline integration
    Microservices architecture implementation and management
    Preparation for KCNA certification and advanced Kubernetes certifications
    Real-world production environments where scalability and reliability are critical

The hands-on experience with Minikube provides a solid foundation for working with managed Kubernetes services like Amazon EKS, Google GKE, or Azure AKS. You now understand the fundamental concepts that make Kubernetes a powerful platform for modern application deployment and management.

Continue practicing these concepts and explore additional Kubernetes features such as Ingress controllers, persistent volumes, and cluster monitoring to further enhance your container orchestration expertise.




Lab 3: Understanding Kubernetes Architecture
Objectives

By the end of this lab, you will be able to:

• Identify and understand the core components of a Kubernetes cluster • Use kubectl commands to inspect cluster architecture and component status • Examine control plane component logs including API Server and etcd • Create and deploy a Pod while understanding its interaction with control plane and worker nodes • Analyze the communication flow between Kubernetes components • Troubleshoot basic cluster component issues using command-line tools
Prerequisites

Before starting this lab, you should have:

• Basic understanding of containerization concepts (Docker) • Familiarity with Linux command line operations • Basic knowledge of YAML file structure • Understanding of client-server architecture concepts • Completion of previous Kubernetes fundamentals labs or equivalent knowledge
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with Kubernetes already installed. Simply click Start Lab to access your environment - no need to build your own VM or install Kubernetes manually.

Your lab environment includes: • Ubuntu 22.04 LTS with kubectl pre-installed • A single-node Kubernetes cluster (minikube) ready for use • All necessary tools and permissions configured • Internet access for downloading container images
Task 1: Identifying Kubernetes Cluster Components
Subtask 1.1: Verify Cluster Status and Basic Information

First, let's confirm our cluster is running and gather basic information about its architecture.

    Check cluster status:

kubectl cluster-info

    Display detailed cluster information:

kubectl cluster-info dump | head -20

    List all nodes in the cluster:

kubectl get nodes -o wide

    Get detailed information about the node:

kubectl describe nodes

Subtask 1.2: Explore Control Plane Components

The control plane manages the cluster and makes decisions about scheduling and cluster state.

    List all pods in the kube-system namespace (where control plane components run):

kubectl get pods -n kube-system

    Get detailed information about control plane pods:

kubectl get pods -n kube-system -o wide

    Identify specific control plane components:

kubectl get pods -n kube-system | grep -E "(apiserver|etcd|scheduler|controller)"

Subtask 1.3: Examine API Server Component

The API Server is the central component that exposes the Kubernetes API.

    Find the API Server pod:

kubectl get pods -n kube-system | grep apiserver

    Get detailed information about the API Server:

kubectl describe pod -n kube-system $(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}')

    Check API Server service endpoints:

kubectl get endpoints -n kube-system

Subtask 1.4: Examine etcd Component

etcd is the distributed key-value store that holds all cluster data.

    Find the etcd pod:

kubectl get pods -n kube-system | grep etcd

    Get detailed information about etcd:

kubectl describe pod -n kube-system $(kubectl get pods -n kube-system | grep etcd | awk '{print $1}')

    Check etcd health (if accessible):

kubectl exec -n kube-system $(kubectl get pods -n kube-system | grep etcd | awk '{print $1}') -- etcdctl endpoint health

Task 2: Inspecting Control Plane Component Logs
Subtask 2.1: Examining API Server Logs

Understanding API Server logs helps troubleshoot cluster communication issues.

    View recent API Server logs:

kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}') --tail=50

    Follow API Server logs in real-time (open a new terminal for this):

kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}') -f

    Search for specific events in API Server logs:

kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}') | grep -i "error\|warning" | tail -10

Subtask 2.2: Examining etcd Logs

etcd logs provide insights into cluster state storage and replication.

    View recent etcd logs:

kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep etcd | awk '{print $1}') --tail=30

    Check for etcd health-related messages:

kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep etcd | awk '{print $1}') | grep -i "health\|ready" | tail -5

    Monitor etcd performance metrics in logs:

kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep etcd | awk '{print $1}') | grep -i "slow\|latency" | tail -5

Subtask 2.3: Examining Scheduler and Controller Manager Logs

    View Scheduler logs:

kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep scheduler | awk '{print $1}') --tail=20

    View Controller Manager logs:

kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep controller-manager | awk '{print $1}') --tail=20

Task 3: Creating a Pod and Understanding Component Interactions
Subtask 3.1: Create a Simple Pod

Let's create a Pod and observe how it interacts with various cluster components.

    Create a Pod manifest file:

cat > nginx-pod.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: nginx-demo
  labels:
    app: nginx-demo
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
EOF

    Apply the Pod manifest:

kubectl apply -f nginx-pod.yaml

    Verify Pod creation:

kubectl get pods

    Get detailed Pod information:

kubectl describe pod nginx-demo

Subtask 3.2: Monitor Component Interactions During Pod Creation

    Check scheduler logs for Pod scheduling decisions:

kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep scheduler | awk '{print $1}') | grep nginx-demo

    Check API Server logs for Pod-related API calls:

kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}') | grep nginx-demo | tail -10

    Examine kubelet logs on the node (if accessible):

# Note: In minikube, you might need to access the node directly
minikube ssh "sudo journalctl -u kubelet | grep nginx-demo | tail -5"

Subtask 3.3: Analyze Pod Lifecycle and Component Communication

    Check Pod events to understand the creation process:

kubectl get events --sort-by=.metadata.creationTimestamp | grep nginx-demo

    Monitor Pod status changes:

kubectl get pod nginx-demo -o yaml | grep -A 10 "status:"

    Verify container runtime interaction:

kubectl get pod nginx-demo -o jsonpath='{.status.containerStatuses[0].containerID}'

Subtask 3.4: Test Pod Functionality and Network Communication

    Execute commands inside the Pod:

kubectl exec nginx-demo -- nginx -v

    Check Pod IP and network configuration:

kubectl get pod nginx-demo -o wide

    Test network connectivity to the Pod:

POD_IP=$(kubectl get pod nginx-demo -o jsonpath='{.status.podIP}')
curl -I http://$POD_IP

    Port-forward to test application accessibility:

kubectl port-forward nginx-demo 8080:80 &
curl http://localhost:8080
# Stop port-forward
pkill -f "kubectl port-forward"

Task 4: Advanced Component Analysis
Subtask 4.1: Examine Resource Usage and Metrics

    Check node resource usage:

kubectl top nodes

    Check Pod resource usage:

kubectl top pods

    Get detailed resource information:

kubectl describe node | grep -A 5 "Allocated resources"

Subtask 4.2: Understand Component Dependencies

    Check service accounts and RBAC:

kubectl get serviceaccounts -n kube-system

    Examine cluster roles and bindings:

kubectl get clusterroles | head -10
kubectl get clusterrolebindings | head -10

    Check component health endpoints:

kubectl get componentstatuses

Troubleshooting Common Issues
Issue 1: Pod Stuck in Pending State

If your Pod remains in Pending state:

    Check Pod events:

kubectl describe pod nginx-demo | grep -A 10 Events

    Verify node resources:

kubectl describe nodes | grep -A 5 "Allocated resources"

    Check scheduler logs:

kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep scheduler | awk '{print $1}') | tail -20

Issue 2: Cannot Access Control Plane Components

If you cannot access control plane logs:

    Verify cluster status:

kubectl cluster-info

    Check if components are running:

kubectl get pods -n kube-system

    Restart minikube if necessary:

minikube stop
minikube start

Issue 3: Network Connectivity Issues

If Pod networking doesn't work:

    Check Pod network configuration:

kubectl get pod nginx-demo -o yaml | grep -A 5 "podIP"

    Verify DNS resolution:

kubectl exec nginx-demo -- nslookup kubernetes.default

Cleanup

Remove the resources created during this lab:

kubectl delete pod nginx-demo
rm nginx-pod.yaml

Conclusion

In this lab, you have successfully:

• Identified Kubernetes cluster components using kubectl commands and learned how to inspect their status and configuration • Examined control plane component logs including API Server and etcd, understanding how to troubleshoot cluster issues through log analysis • Created a Pod and analyzed its interaction with control plane and worker nodes, observing the complete lifecycle from creation to running state • Understood component communication flow and how different parts of Kubernetes work together to manage containerized applications

Why This Matters: Understanding Kubernetes architecture is crucial for:

    Troubleshooting cluster issues effectively by knowing which component logs to check
    Optimizing cluster performance by understanding resource allocation and component interactions
    Securing your cluster by knowing the role of each component and their communication patterns
    Preparing for KCNA certification by demonstrating practical knowledge of Kubernetes internals

This knowledge forms the foundation for advanced Kubernetes operations, including cluster administration, performance tuning, and security hardening. The hands-on experience with kubectl commands and log analysis will be invaluable as you progress to more complex Kubernetes scenarios.




Lab 4: Installing Kubernetes
Objectives

By the end of this lab, you will be able to:

• Set up a complete Kubernetes cluster using kubeadm on Linux systems • Configure the cluster networking with a Container Network Interface (CNI) plugin • Verify cluster installation by checking node statuses and system pods • Use kubectl commands to explore and interact with your Kubernetes cluster • Understand the basic architecture and components of a Kubernetes cluster • Troubleshoot common installation issues and verify cluster functionality
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Linux command line operations • Familiarity with containerization concepts (Docker basics) • Knowledge of networking fundamentals (IP addresses, ports) • Understanding of YAML file structure • Basic knowledge of system administration tasks

Technical Requirements: • Linux-based system with at least 2 GB RAM and 2 CPU cores • Root or sudo access • Internet connectivity for downloading packages • Basic text editor skills (nano, vim, or similar)
Lab Environment Setup

Good News! Al Nafi provides ready-to-use Linux-based cloud machines for this lab. Simply click Start Lab and you'll have access to a pre-configured environment. No need to build your own virtual machine or worry about hardware requirements.

Your lab environment includes: • Ubuntu 20.04 LTS or newer • Pre-installed Docker runtime • Network connectivity configured • Sufficient resources for Kubernetes installation
Task 1: Preparing the System for Kubernetes Installation
Subtask 1.1: Update System Packages

First, let's ensure our system is up to date with the latest packages.

# Update package index
sudo apt update

# Upgrade existing packages
sudo apt upgrade -y

# Install essential packages
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

Subtask 1.2: Disable Swap

Kubernetes requires swap to be disabled for optimal performance.

# Disable swap temporarily
sudo swapoff -a

# Disable swap permanently by commenting out swap entries
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Verify swap is disabled
free -h

Expected Output: The swap line should show 0B for total, used, and free.
Subtask 1.3: Configure Kernel Modules

Load necessary kernel modules for Kubernetes networking.

# Load required modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Make modules persistent across reboots
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

Subtask 1.4: Configure System Parameters

Set up required sysctl parameters for Kubernetes.

# Configure sysctl parameters
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl parameters without reboot
sudo sysctl --system

Task 2: Installing Container Runtime (containerd)
Subtask 2.1: Install containerd

Kubernetes needs a container runtime. We'll use containerd as it's the recommended choice.

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index
sudo apt update

# Install containerd
sudo apt install -y containerd.io

Subtask 2.2: Configure containerd

# Create containerd configuration directory
sudo mkdir -p /etc/containerd

# Generate default configuration
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Configure containerd to use systemd cgroup driver
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

# Restart and enable containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

# Verify containerd is running
sudo systemctl status containerd

Expected Output: You should see active (running) status in green.
Task 3: Installing Kubernetes Components
Subtask 3.1: Add Kubernetes Repository

# Add Kubernetes signing key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package index
sudo apt update

Subtask 3.2: Install Kubernetes Tools

# Install kubelet, kubeadm, and kubectl
sudo apt install -y kubelet kubeadm kubectl

# Prevent automatic updates of Kubernetes packages
sudo apt-mark hold kubelet kubeadm kubectl

# Verify installation
kubeadm version
kubectl version --client

Expected Output: You should see version information for both tools.
Task 4: Initializing the Kubernetes Cluster
Subtask 4.1: Initialize the Master Node

# Initialize the cluster with kubeadm
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$(hostname -I | awk '{print $1}')

Important: Save the kubeadm join command that appears at the end of the output. You'll need it to add worker nodes later.

Expected Output: You should see a message saying "Your Kubernetes control-plane has initialized successfully!"
Subtask 4.2: Configure kubectl for Regular User

# Create .kube directory
mkdir -p $HOME/.kube

# Copy admin configuration
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# Change ownership of the config file
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Verify kubectl configuration
kubectl cluster-info

Expected Output: You should see cluster information including the Kubernetes master URL.
Task 5: Installing Pod Network Add-on
Subtask 5.1: Install Flannel CNI Plugin

Kubernetes needs a network plugin to enable pod-to-pod communication.

# Apply Flannel network plugin
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Wait for flannel pods to be ready
kubectl wait --for=condition=ready pod -l app=flannel -n kube-flannel --timeout=300s

Subtask 5.2: Remove Taint from Master Node (Single Node Cluster)

For a single-node cluster, we need to allow pods to be scheduled on the master node.

# Remove the master node taint
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

# Verify the taint removal
kubectl describe nodes | grep -i taint

Expected Output: You should see NoSchedule taint removed or no taints listed.
Task 6: Verifying Cluster Installation
Subtask 6.1: Check Node Status

# Check node status
kubectl get nodes

# Get detailed node information
kubectl get nodes -o wide

Expected Output: Your node should show Ready status.
Subtask 6.2: Verify System Pods

# Check all system pods
kubectl get pods --all-namespaces

# Check pods in kube-system namespace specifically
kubectl get pods -n kube-system

# Wait for all pods to be running
kubectl wait --for=condition=ready pod --all -n kube-system --timeout=300s

Expected Output: All pods should show Running or Completed status.
Subtask 6.3: Check Cluster Components

# Check cluster component status
kubectl get componentstatuses

# View cluster information
kubectl cluster-info

# Check API server health
kubectl get --raw='/readyz?verbose'

Task 7: Exploring the Cluster with kubectl
Subtask 7.1: Basic Cluster Exploration

# List all namespaces
kubectl get namespaces

# Get cluster version information
kubectl version

# View cluster configuration
kubectl config view

# Check current context
kubectl config current-context

Subtask 7.2: Deploy a Test Application

Let's deploy a simple application to verify everything works.

# Create a test deployment
kubectl create deployment nginx-test --image=nginx:latest

# Expose the deployment as a service
kubectl expose deployment nginx-test --port=80 --type=NodePort

# Check deployment status
kubectl get deployments

# Check pods
kubectl get pods

# Check services
kubectl get services

Subtask 7.3: Verify Application Functionality

# Get detailed information about the nginx pod
kubectl describe pod $(kubectl get pods -l app=nginx-test -o jsonpath='{.items[0].metadata.name}')

# Check service details
kubectl get service nginx-test

# Test the application (get the NodePort)
NODE_PORT=$(kubectl get service nginx-test -o jsonpath='{.spec.ports[0].nodePort}')
curl http://localhost:$NODE_PORT

Expected Output: You should see the default nginx welcome page HTML.
Subtask 7.4: Clean Up Test Resources

# Delete the test deployment and service
kubectl delete deployment nginx-test
kubectl delete service nginx-test

# Verify cleanup
kubectl get deployments
kubectl get services

Task 8: Additional Cluster Verification
Subtask 8.1: Check Resource Usage

# Check node resource usage
kubectl top nodes

# If metrics-server is not installed, install it
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Wait for metrics-server to be ready
kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n kube-system --timeout=300s

Subtask 8.2: Explore Kubernetes API

# List available API resources
kubectl api-resources

# Get API versions
kubectl api-versions

# Check cluster events
kubectl get events --sort-by=.metadata.creationTimestamp

Subtask 8.3: Verify Networking

# Check network policies (if any)
kubectl get networkpolicies --all-namespaces

# Verify DNS resolution
kubectl run test-dns --image=busybox:1.28 --rm -it --restart=Never -- nslookup kubernetes.default

Troubleshooting Common Issues
Issue 1: Pods Stuck in Pending State

# Check pod events
kubectl describe pod <pod-name>

# Check node resources
kubectl describe nodes

# Verify network plugin installation
kubectl get pods -n kube-flannel

Issue 2: kubelet Not Starting

# Check kubelet status
sudo systemctl status kubelet

# View kubelet logs
sudo journalctl -xeu kubelet

# Restart kubelet if needed
sudo systemctl restart kubelet

Issue 3: Network Issues

# Check containerd status
sudo systemctl status containerd

# Verify network configuration
ip route show

# Check firewall rules
sudo iptables -L

Verification Checklist

Before concluding this lab, verify the following:

    All system pods are running
    Node status shows Ready
    kubectl commands work without errors
    Test application deployed and accessible
    Network plugin (Flannel) is operational
    Cluster components are healthy

Conclusion

Congratulations! You have successfully completed Lab 4: Installing Kubernetes. In this comprehensive lab, you have accomplished the following:

Key Achievements:

• Cluster Setup: You've built a complete Kubernetes cluster from scratch using kubeadm, learning the fundamental installation process that forms the backbone of container orchestration.

• System Configuration: You've properly configured your Linux system with all necessary prerequisites, including container runtime setup, kernel modules, and system parameters required for Kubernetes operation.

• Network Implementation: You've installed and configured Flannel as your Container Network Interface (CNI) plugin, enabling seamless pod-to-pod communication across your cluster.

• Verification Skills: You've learned essential kubectl commands to monitor, verify, and troubleshoot your Kubernetes installation, skills that are crucial for day-to-day cluster management.

• Practical Application: You've deployed and tested a real application on your cluster, demonstrating that your installation is fully functional and ready for production workloads.

Why This Matters:

Understanding how to install and configure Kubernetes manually is essential for several reasons:

• Foundation Knowledge: This hands-on experience provides deep understanding of Kubernetes architecture and components • Troubleshooting Skills: Manual installation knowledge helps you diagnose and fix issues in any Kubernetes environment • Certification Preparation: These skills directly support your KCNA (Kubernetes and Cloud Native Associate) certification goals • Career Advancement: Kubernetes expertise is highly valued in the current job market, with manual installation skills demonstrating advanced technical competency

Next Steps:

With your Kubernetes cluster now operational, you're ready to explore advanced topics such as: • Deploying multi-tier applications • Implementing persistent storage • Configuring ingress controllers • Setting up monitoring and logging • Implementing security policies

Your newly installed Kubernetes cluster serves as the foundation for all future container orchestration learning and experimentation. Well done on completing this critical milestone in your Kubernetes journey!




Lab 5: Setting Up a Single-Node Kubernetes Cluster with Minikube
Objectives

By the end of this lab, you will be able to:

• Install and configure Minikube on a Linux system • Start and manage a single-node Kubernetes cluster • Use kubectl to interact with and verify cluster health • Understand basic Kubernetes cluster components and their status • Stop and restart a Minikube cluster while maintaining persistence • Troubleshoot common Minikube installation and startup issues
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Linux command line operations • Familiarity with containerization concepts (Docker basics) • Understanding of what Kubernetes is and its basic architecture • Knowledge of YAML file structure (helpful but not required) • Access to a terminal or command prompt

Note: Al Nafi provides ready-to-use Linux-based cloud machines for this lab. Simply click Start Lab to access your pre-configured environment - no need to build your own VM or install an operating system.
Lab Environment Setup

Your Al Nafi cloud machine comes pre-configured with: • Ubuntu 20.04 LTS or newer • Docker runtime installed and configured • Internet connectivity for downloading required packages • Sufficient resources (2 CPU cores, 4GB RAM minimum)
Task 1: Installing Minikube
Subtask 1.1: Update System Packages

First, ensure your system is up to date with the latest packages.

sudo apt update && sudo apt upgrade -y

Subtask 1.2: Install Required Dependencies

Install curl and other essential tools needed for Minikube installation.

sudo apt install -y curl wget apt-transport-https

Subtask 1.3: Download and Install Minikube

Download the latest stable version of Minikube for Linux.

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

Make the downloaded file executable and move it to your system PATH.

sudo install minikube-linux-amd64 /usr/local/bin/minikube

Verify the installation by checking the Minikube version.

minikube version

Expected Output:

minikube version: v1.32.0
commit: 8220a6eb95f0a4d75f7f2d7b14cef975f050512d

Subtask 1.4: Install kubectl

kubectl is the command-line tool for interacting with Kubernetes clusters. Download and install it.

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

Make kubectl executable and move it to your PATH.

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

Verify kubectl installation.

kubectl version --client

Expected Output:

Client Version: v1.29.0
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3

Task 2: Starting Your First Minikube Cluster
Subtask 2.1: Start Minikube with Docker Driver

Start your single-node Kubernetes cluster using Docker as the container runtime.

minikube start --driver=docker

Note: The first startup may take 3-5 minutes as it downloads the Kubernetes components and container images.

Expected Output:

😄  minikube v1.32.0 on Ubuntu 20.04
✨  Using the docker driver based on user configuration
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
🔥  Creating docker container (CPUs=2, Memory=4000MB) ...
🐳  Preparing Kubernetes v1.28.3 on Docker 24.0.7 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass, storage-provisioner
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

Subtask 2.2: Verify Cluster Status

Check that your Minikube cluster is running properly.

minikube status

Expected Output:

minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured

Subtask 2.3: Configure kubectl Context

Ensure kubectl is configured to communicate with your Minikube cluster.

kubectl config current-context

Expected Output:

minikube

Task 3: Verifying Cluster Health and Resources
Subtask 3.1: Check Cluster Information

Get basic information about your Kubernetes cluster.

kubectl cluster-info

Expected Output:

Kubernetes control plane is running at https://192.168.49.2:8443
CoreDNS is running at https://192.168.49.2:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

Subtask 3.2: List All Nodes

View all nodes in your cluster (should show one node since this is a single-node setup).

kubectl get nodes

Expected Output:

NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   2m    v1.28.3

Get detailed information about your node.

kubectl describe node minikube

Subtask 3.3: Check System Pods

View all system pods running in the kube-system namespace.

kubectl get pods -n kube-system

Expected Output:

NAME                               READY   STATUS    RESTARTS   AGE
coredns-5dd5756b68-xxxxx          1/1     Running   0          3m
etcd-minikube                     1/1     Running   0          3m
kube-apiserver-minikube           1/1     Running   0          3m
kube-controller-manager-minikube  1/1     Running   0          3m
kube-proxy-xxxxx                  1/1     Running   0          3m
kube-scheduler-minikube           1/1     Running   0          3m
storage-provisioner               1/1     Running   0          3m

Subtask 3.4: Check Available Resources

View the resource usage of your cluster.

kubectl top node

If the metrics server is not available, you can install it:

minikube addons enable metrics-server

Wait a few minutes, then try again:

kubectl top node

Subtask 3.5: List Available Namespaces

See all namespaces in your cluster.

kubectl get namespaces

Expected Output:

NAME              STATUS   AGE
default           Active   5m
kube-node-lease   Active   5m
kube-public       Active   5m
kube-system       Active   5m

Task 4: Testing Cluster Functionality
Subtask 4.1: Deploy a Test Application

Create a simple nginx deployment to test your cluster.

kubectl create deployment hello-minikube --image=nginx:latest

Check the deployment status.

kubectl get deployments

Expected Output:

NAME             READY   UP-TO-DATE   AVAILABLE   AGE
hello-minikube   1/1     1            1           30s

Subtask 4.2: Expose the Deployment

Create a service to expose your deployment.

kubectl expose deployment hello-minikube --type=NodePort --port=80

Check the service.

kubectl get services

Expected Output:

NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
hello-minikube   NodePort    10.96.xxx.xxx   <none>        80:xxxxx/TCP   15s
kubernetes       ClusterIP   10.96.0.1       <none>        443/TCP        8m

Subtask 4.3: Access the Application

Get the URL to access your application.

minikube service hello-minikube --url

Test the application using curl.

curl $(minikube service hello-minikube --url)

Clean up the test deployment.

kubectl delete deployment hello-minikube
kubectl delete service hello-minikube

Task 5: Stopping and Restarting the Cluster
Subtask 5.1: Stop the Minikube Cluster

Stop your cluster while preserving its state.

minikube stop

Expected Output:

✋  Stopping node "minikube"  ...
🛑  Powering off "minikube" via SSH ...
🛑  1 node stopped.

Verify the cluster is stopped.

minikube status

Expected Output:

minikube
type: Control Plane
host: Stopped
kubelet: Stopped
apiserver: Stopped
kubeconfig: Configured

Subtask 5.2: Restart the Cluster

Start the cluster again to verify persistence.

minikube start

Expected Output:

😄  minikube v1.32.0 on Ubuntu 20.04
✨  Using the docker driver based on existing profile
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
🔄  Restarting existing docker container for "minikube" ...
🐳  Preparing Kubernetes v1.28.3 on Docker 24.0.7 ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass, storage-provisioner
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

Subtask 5.3: Verify Cluster Persistence

Check that your cluster components are still running after restart.

kubectl get nodes
kubectl get pods -n kube-system

Verify that any persistent volumes or configurations remain intact.

kubectl get pv
kubectl get storageclass

Task 6: Exploring Minikube Features
Subtask 6.1: Access Kubernetes Dashboard

Enable the Kubernetes dashboard addon.

minikube addons enable dashboard

Start the dashboard in a separate terminal or background process.

minikube dashboard --url

Note: This will provide a URL to access the Kubernetes dashboard in a web browser.
Subtask 6.2: View Available Addons

List all available Minikube addons.

minikube addons list

Enable a useful addon like ingress.

minikube addons enable ingress

Verify the addon is running.

kubectl get pods -n ingress-nginx

Subtask 6.3: Check Minikube Configuration

View your current Minikube configuration.

minikube config view

Check the IP address of your Minikube cluster.

minikube ip

Troubleshooting Common Issues
Issue 1: Minikube Won't Start

If Minikube fails to start, try these solutions:

# Check if Docker is running
sudo systemctl status docker

# Start Docker if it's not running
sudo systemctl start docker

# Delete and recreate the cluster
minikube delete
minikube start --driver=docker

Issue 2: kubectl Commands Not Working

If kubectl commands fail:

# Check if kubectl is configured correctly
kubectl config current-context

# If not pointing to minikube, set it manually
kubectl config use-context minikube

Issue 3: Insufficient Resources

If you encounter resource issues:

# Start with more resources
minikube delete
minikube start --driver=docker --memory=4096 --cpus=2

Issue 4: Network Issues

If you have network connectivity problems:

# Check Minikube status
minikube status

# Restart with different network settings
minikube delete
minikube start --driver=docker --network-plugin=cni

Lab Cleanup

When you're finished with the lab, you can clean up resources:

# Stop the cluster
minikube stop

# Delete the cluster completely (optional)
minikube delete

# Remove downloaded binaries (optional)
sudo rm /usr/local/bin/minikube
sudo rm /usr/local/bin/kubectl

Conclusion

Congratulations! You have successfully completed Lab 5: Setting Up a Single-Node Kubernetes Cluster with Minikube.
What You Accomplished

In this lab, you:

• Installed Minikube and kubectl - Set up the essential tools for running a local Kubernetes cluster • Created a single-node Kubernetes cluster - Launched a fully functional Kubernetes environment on a single machine • Verified cluster health - Used kubectl commands to check cluster status, nodes, and system components • Tested cluster functionality - Deployed and exposed a sample application to ensure everything works correctly • Managed cluster lifecycle - Learned how to stop and restart your cluster while maintaining persistence • Explored Minikube features - Discovered addons and additional capabilities available in Minikube
Why This Matters

Understanding how to set up and manage a Kubernetes cluster is fundamental for:

• Development and Testing - Minikube provides a safe environment to develop and test Kubernetes applications locally • Learning Kubernetes - Having a local cluster allows you to experiment with Kubernetes concepts without cloud costs • KCNA Certification - This knowledge directly supports the Kubernetes and Cloud Native Associate certification objectives • Career Development - Kubernetes skills are highly sought after in the cloud computing industry • Production Readiness - The concepts learned here scale up to managing production Kubernetes clusters
Next Steps

Now that you have a working Minikube cluster, you can:

• Deploy more complex applications with multiple pods and services • Explore Kubernetes networking and storage concepts • Practice with ConfigMaps, Secrets, and other Kubernetes resources • Learn about Helm charts for application packaging • Experiment with different Kubernetes deployment strategies

This foundational knowledge prepares you for more advanced Kubernetes topics and real-world container orchestration scenarios.




Lab 6: Accessing and Interacting with Minikube
Objectives

By the end of this lab, you will be able to:

• Understand the basic architecture and components of a Kubernetes cluster using Minikube • Use kubectl command-line tool to interact with Kubernetes resources • List and examine nodes, namespaces, and pods in a Kubernetes cluster • Deploy a simple Pod and manage its lifecycle • Retrieve and analyze Pod logs for troubleshooting • Diagnose and resolve common connectivity issues within a Kubernetes cluster • Apply fundamental Kubernetes concepts in a hands-on environment
Prerequisites

Before starting this lab, you should have:

• Basic understanding of containerization concepts (Docker) • Familiarity with Linux command-line interface • Basic knowledge of YAML file structure • Understanding of networking fundamentals • No prior Kubernetes experience required - this lab will guide you through the basics
Lab Environment Setup

Good News! Al Nafi provides ready-to-use Linux-based cloud machines with all necessary tools pre-installed. Simply click Start Lab to access your environment. No need to build your own VM or install software.

Your cloud machine comes with: • Minikube pre-installed and configured • kubectl command-line tool ready to use • Docker runtime environment • All necessary dependencies configured
Task 1: Understanding Your Kubernetes Environment
Subtask 1.1: Start Minikube and Verify Cluster Status

First, let's start your Minikube cluster and verify it's running properly.

    Start Minikube cluster:

minikube start --driver=docker

    Check Minikube status:

minikube status

Expected output should show:

minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured

    Verify kubectl is configured to communicate with your cluster:

kubectl cluster-info

Subtask 1.2: List and Examine Nodes

Now let's explore the nodes in your cluster.

    List all nodes in the cluster:

kubectl get nodes

    Get detailed information about nodes:

kubectl get nodes -o wide

    Describe a specific node (replace 'minikube' with your node name if different):

kubectl describe node minikube

Key Concept: In Minikube, you typically have one node that acts as both master and worker node, making it perfect for learning and development.
Subtask 1.3: Explore Namespaces

Namespaces provide a way to organize resources in a cluster.

    List all namespaces:

kubectl get namespaces

    Get detailed information about namespaces:

kubectl get namespaces -o wide

    Describe the default namespace:

kubectl describe namespace default

    List namespaces with additional details:

kubectl get ns --show-labels

Key Concept: Namespaces are like folders that help organize your Kubernetes resources. Common namespaces include default, kube-system, and kube-public.
Subtask 1.4: List and Examine Pods

Let's explore the pods running in your cluster.

    List pods in the default namespace:

kubectl get pods

    List pods in all namespaces:

kubectl get pods --all-namespaces

    List pods with additional information:

kubectl get pods -o wide --all-namespaces

    Focus on system pods:

kubectl get pods -n kube-system

Task 2: Deploy a Simple Pod and Manage Its Lifecycle
Subtask 2.1: Create a Simple Pod

Let's deploy a simple nginx pod to practice pod management.

    Create a simple pod using kubectl run command:

kubectl run my-nginx-pod --image=nginx:latest --port=80

    Verify the pod was created:

kubectl get pods

    Get detailed information about your pod:

kubectl get pod my-nginx-pod -o wide

    Describe the pod to see detailed information:

kubectl describe pod my-nginx-pod

Subtask 2.2: Create a Pod Using YAML Manifest

Now let's create a more complex pod using a YAML file.

    Create a YAML file for a pod:

cat > test-pod.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-app-pod
  labels:
    app: test-app
    environment: lab
spec:
  containers:
  - name: test-container
    image: busybox:latest
    command: ['sh', '-c', 'echo "Hello from Kubernetes Pod!" && sleep 3600']
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
EOF

    Apply the YAML file to create the pod:

kubectl apply -f test-pod.yaml

    Verify both pods are running:

kubectl get pods

Subtask 2.3: Retrieve and Analyze Pod Logs

Understanding how to access logs is crucial for troubleshooting.

    Get logs from the nginx pod:

kubectl logs my-nginx-pod

    Get logs from the test-app-pod:

kubectl logs test-app-pod

    Follow logs in real-time (use Ctrl+C to stop):

kubectl logs -f test-app-pod

    Get logs with timestamps:

kubectl logs test-app-pod --timestamps

    Get the last 10 lines of logs:

kubectl logs test-app-pod --tail=10

Subtask 2.4: Execute Commands Inside Pods

Sometimes you need to troubleshoot by executing commands inside running pods.

    Execute a command in the busybox pod:

kubectl exec test-app-pod -- ls -la

    Get an interactive shell in the pod:

kubectl exec -it test-app-pod -- sh

Inside the pod shell, try these commands:

# Check the hostname
hostname

# Check network configuration
ip addr

# Check running processes
ps aux

# Exit the pod shell
exit

Task 3: Diagnose and Resolve Connectivity Issues
Subtask 3.1: Create a Service for Pod Access

Let's create a service to expose our nginx pod and then diagnose connectivity.

    Expose the nginx pod as a service:

kubectl expose pod my-nginx-pod --port=80 --target-port=80 --name=nginx-service

    List services:

kubectl get services

    Describe the service:

kubectl describe service nginx-service

Subtask 3.2: Test Connectivity Between Pods

Let's test network connectivity between pods.

    Create a debug pod for network testing:

kubectl run debug-pod --image=busybox:latest --rm -it --restart=Never -- sh

Inside the debug pod, test connectivity:

# Test DNS resolution
nslookup nginx-service

# Test HTTP connectivity to the service
wget -qO- nginx-service

# Test connectivity to the pod directly (replace IP with actual pod IP)
# First, get the pod IP from another terminal: kubectl get pod my-nginx-pod -o wide
wget -qO- <POD_IP>

# Exit the debug pod
exit

Subtask 3.3: Simulate and Resolve a Connectivity Issue

Let's create a problematic pod and learn to diagnose issues.

    Create a pod with a wrong image name:

kubectl run broken-pod --image=nginx:nonexistent-tag

    Check the pod status:

kubectl get pods

    Describe the broken pod to see the issue:

kubectl describe pod broken-pod

    Check events to understand what went wrong:

kubectl get events --sort-by=.metadata.creationTimestamp

    Fix the broken pod by deleting and recreating it:

kubectl delete pod broken-pod
kubectl run fixed-pod --image=nginx:latest

    Verify the fix:

kubectl get pods
kubectl describe pod fixed-pod

Subtask 3.4: Advanced Troubleshooting Techniques

Let's explore more troubleshooting commands.

    Check resource usage:

kubectl top nodes
kubectl top pods

    Get detailed cluster information:

kubectl get all

    Check pod resource specifications:

kubectl get pods -o yaml my-nginx-pod

    Monitor pod status in real-time:

kubectl get pods -w

Press Ctrl+C to stop watching.
Subtask 3.5: Network Policy Testing (Optional Advanced Section)

For advanced users, let's test network policies.

    Create a network policy that blocks traffic:

cat > deny-all-policy.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

    Apply the network policy:

kubectl apply -f deny-all-policy.yaml

    Test connectivity (should fail):

kubectl run test-connectivity --image=busybox:latest --rm -it --restart=Never -- wget -qO- nginx-service

    Remove the network policy to restore connectivity:

kubectl delete networkpolicy deny-all

    Test connectivity again (should work):

kubectl run test-connectivity --image=busybox:latest --rm -it --restart=Never -- wget -qO- nginx-service

Task 4: Clean Up Resources
Subtask 4.1: Remove Created Resources

Let's clean up the resources we created during this lab.

    Delete pods:

kubectl delete pod my-nginx-pod
kubectl delete pod test-app-pod
kubectl delete pod fixed-pod

    Delete services:

kubectl delete service nginx-service

    Delete YAML files:

rm test-pod.yaml deny-all-policy.yaml

    Verify cleanup:

kubectl get pods
kubectl get services

Subtask 4.2: Stop Minikube (Optional)

If you want to stop your Minikube cluster:

minikube stop

To start it again later:

minikube start

Troubleshooting Common Issues
Issue 1: Pod Stuck in Pending State

Symptoms: Pod shows status as "Pending"

Diagnosis:

kubectl describe pod <pod-name>
kubectl get events

Common Causes: • Insufficient resources • Image pull issues • Scheduling constraints
Issue 2: Cannot Connect to Service

Symptoms: Connection timeouts or refused connections

Diagnosis:

kubectl get endpoints <service-name>
kubectl describe service <service-name>

Common Causes: • Service selector doesn't match pod labels • Wrong port configuration • Pod not ready
Issue 3: Image Pull Errors

Symptoms: Pod shows "ImagePullBackOff" or "ErrImagePull"

Diagnosis:

kubectl describe pod <pod-name>

Common Causes: • Incorrect image name or tag • Network connectivity issues • Authentication problems with private registries
Key Commands Reference
Essential kubectl Commands

# Cluster information
kubectl cluster-info
kubectl get nodes
kubectl get namespaces

# Pod management
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- <command>

# Service management
kubectl get services
kubectl describe service <service-name>
kubectl expose pod <pod-name> --port=<port>

# Troubleshooting
kubectl get events
kubectl top nodes
kubectl top pods

Conclusion

Congratulations! You have successfully completed Lab 6: Accessing and Interacting with Minikube. In this lab, you have accomplished the following:

What You Learned: • How to start and manage a Minikube cluster • Essential kubectl commands for cluster interaction • How to list and examine nodes, namespaces, and pods • Pod deployment using both command-line and YAML manifests • Log retrieval and analysis techniques • Network connectivity testing and troubleshooting • Common issue diagnosis and resolution strategies

Why This Matters: These skills form the foundation of Kubernetes administration and are essential for the Kubernetes and Cloud Native Associate (KCNA) certification. Understanding how to interact with Kubernetes clusters, deploy applications, and troubleshoot issues is crucial for anyone working with containerized applications in production environments.

Next Steps: • Practice these commands regularly to build muscle memory • Experiment with different pod configurations • Explore more complex Kubernetes resources like Deployments and Services • Study networking concepts in Kubernetes • Practice troubleshooting scenarios to prepare for real-world situations

The hands-on experience you gained in this lab provides a solid foundation for more advanced Kubernetes topics and prepares you for cloud-native application development and deployment.




Lab 7: Exploring Kubernetes Building Blocks
Objectives

By the end of this lab, you will be able to:

• Deploy a Pod using a YAML manifest file • Create and manage Deployments to scale applications • Understand the difference between Pods and Deployments • Create ConfigMaps to manage application configuration • Mount ConfigMaps into Pods as environment variables • Verify and troubleshoot Kubernetes resources using kubectl commands • Apply best practices for container orchestration with Kubernetes
Prerequisites

Before starting this lab, you should have:

• Basic understanding of containerization concepts (Docker) • Familiarity with YAML file structure and syntax • Basic knowledge of Linux command line operations • Understanding of environment variables and configuration management • Completion of previous Kubernetes fundamentals labs or equivalent knowledge
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with Kubernetes already installed and configured. Simply click Start Lab to access your environment - no need to build your own VM or install Kubernetes manually.

Your lab environment includes: • Ubuntu 20.04 LTS with kubectl pre-installed • Minikube cluster ready for use • Text editor (nano/vim) for creating YAML files • All necessary permissions configured
Task 1: Deploy a Pod Using a YAML Manifest
Subtask 1.1: Verify Kubernetes Cluster Status

First, let's ensure your Kubernetes cluster is running properly.

    Open your terminal in the lab environment

    Check the cluster status:

kubectl cluster-info

    Verify that nodes are ready:

kubectl get nodes

You should see output similar to:

NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   1d    v1.28.0

Subtask 1.2: Create a Pod YAML Manifest

Now we'll create a simple Pod using a YAML manifest file.

    Create a new directory for your lab files:

mkdir ~/k8s-lab7
cd ~/k8s-lab7

    Create a Pod manifest file:

nano simple-pod.yaml

    Add the following content to the file:

apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
    environment: lab
spec:
  containers:
  - name: nginx-container
    image: nginx:1.21
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"

    Save and exit the file (Ctrl+X, then Y, then Enter in nano)

Subtask 1.3: Deploy the Pod

    Apply the Pod manifest:

kubectl apply -f simple-pod.yaml

    Verify the Pod was created:

kubectl get pods

    Get detailed information about the Pod:

kubectl describe pod nginx-pod

    Check the Pod logs:

kubectl logs nginx-pod

Subtask 1.4: Test Pod Connectivity

    Get the Pod's IP address:

kubectl get pod nginx-pod -o wide

    Test connectivity to the Pod (from within the cluster):

kubectl exec -it nginx-pod -- curl localhost:80

You should see the default nginx welcome page HTML.
Task 2: Scale the Application Using a Deployment
Subtask 2.1: Create a Deployment YAML Manifest

Deployments provide better management capabilities than standalone Pods, including scaling and rolling updates.

    Create a Deployment manifest file:

nano nginx-deployment.yaml

    Add the following content:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"

    Save and exit the file

Subtask 2.2: Deploy the Application

    Apply the Deployment manifest:

kubectl apply -f nginx-deployment.yaml

    Verify the Deployment was created:

kubectl get deployments

    Check the Pods created by the Deployment:

kubectl get pods -l app=nginx

You should see 2 nginx Pods running.

    Get detailed information about the Deployment:

kubectl describe deployment nginx-deployment

Subtask 2.3: Scale the Deployment

Now let's demonstrate scaling capabilities.

    Scale the Deployment to 4 replicas using kubectl:

kubectl scale deployment nginx-deployment --replicas=4

    Verify the scaling operation:

kubectl get pods -l app=nginx

You should now see 4 nginx Pods.

    Check the Deployment status:

kubectl get deployment nginx-deployment

Subtask 2.4: Scale Using YAML Manifest

You can also scale by modifying the YAML file.

    Edit the Deployment file:

nano nginx-deployment.yaml

    Change the replicas value from 2 to 3:

spec:
  replicas: 3

    Apply the updated manifest:

kubectl apply -f nginx-deployment.yaml

    Verify the change:

kubectl get pods -l app=nginx

The number of Pods should now be 3.
Task 3: Create a ConfigMap and Mount it into a Pod
Subtask 3.1: Create a ConfigMap YAML Manifest

ConfigMaps allow you to separate configuration from your application code.

    Create a ConfigMap manifest file:

nano app-config.yaml

    Add the following content:

apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_host: "mysql.example.com"
  database_port: "3306"
  database_name: "myapp"
  log_level: "INFO"
  max_connections: "100"
  app_version: "1.2.3"

    Save and exit the file

Subtask 3.2: Create the ConfigMap

    Apply the ConfigMap manifest:

kubectl apply -f app-config.yaml

    Verify the ConfigMap was created:

kubectl get configmaps

    View the ConfigMap details:

kubectl describe configmap app-config

Subtask 3.3: Create a Pod that Uses the ConfigMap

Now we'll create a Pod that uses the ConfigMap as environment variables.

    Create a new Pod manifest that uses the ConfigMap:

nano pod-with-config.yaml

    Add the following content:

apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  labels:
    app: myapp
spec:
  containers:
  - name: app-container
    image: busybox:1.35
    command: ['sh', '-c', 'echo "Starting application..." && env | grep -E "(DATABASE|LOG|MAX|APP)" && sleep 3600']
    envFrom:
    - configMapRef:
        name: app-config
    env:
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    - name: POD_IP
      valueFrom:
        fieldRef:
          fieldPath: status.podIP

    Save and exit the file

Subtask 3.4: Deploy and Test the Pod with ConfigMap

    Apply the Pod manifest:

kubectl apply -f pod-with-config.yaml

    Verify the Pod is running:

kubectl get pod app-pod

    Check the Pod logs to see the environment variables:

kubectl logs app-pod

You should see the configuration values from the ConfigMap displayed as environment variables.

    Execute into the Pod to explore the environment:

kubectl exec -it app-pod -- sh

    Inside the Pod, check all environment variables:

env | sort

    Check specific configuration variables:

echo "Database Host: $database_host"
echo "Database Port: $database_port"
echo "Log Level: $log_level"

    Exit the Pod:

exit

Subtask 3.5: Update ConfigMap and Observe Changes

    Update the ConfigMap:

kubectl patch configmap app-config --patch '{"data":{"log_level":"DEBUG","app_version":"1.2.4"}}'

    Verify the ConfigMap was updated:

kubectl get configmap app-config -o yaml

    Delete and recreate the Pod to see the updated configuration:

kubectl delete pod app-pod
kubectl apply -f pod-with-config.yaml

    Check the logs of the new Pod:

kubectl logs app-pod

You should see the updated log_level as "DEBUG" and app_version as "1.2.4".
Verification and Cleanup
Verification Steps

    List all resources created in this lab:

kubectl get pods,deployments,configmaps

    Verify the Deployment is managing the correct number of replicas:

kubectl get deployment nginx-deployment -o wide

    Confirm the ConfigMap is properly mounted:

kubectl exec app-pod -- env | grep database_host

Cleanup Resources

When you're finished with the lab, clean up the resources:

    Delete the standalone Pod:

kubectl delete pod nginx-pod

    Delete the Deployment:

kubectl delete deployment nginx-deployment

    Delete the Pod with ConfigMap:

kubectl delete pod app-pod

    Delete the ConfigMap:

kubectl delete configmap app-config

    Verify all resources are deleted:

kubectl get pods,deployments,configmaps

Troubleshooting Tips
Common Issues and Solutions

Pod Stuck in Pending State:

    Check node resources: kubectl describe nodes
    Verify image availability: kubectl describe pod <pod-name>

ConfigMap Not Loading:

    Ensure ConfigMap exists: kubectl get configmap
    Check Pod specification for correct ConfigMap name
    Verify YAML indentation and syntax

Deployment Not Scaling:

    Check Deployment status: kubectl get deployment <deployment-name> -o wide
    Review events: kubectl get events --sort-by=.metadata.creationTimestamp

Environment Variables Not Appearing:

    Restart the Pod after ConfigMap changes
    Use kubectl exec to check environment inside the container
    Verify ConfigMap reference in Pod specification

Conclusion

In this lab, you have successfully explored the fundamental building blocks of Kubernetes:

Key Accomplishments: • Pod Management: You deployed a Pod using a YAML manifest, learning how to define container specifications, resource limits, and labels • Application Scaling: You created and managed a Deployment, demonstrating how Kubernetes can automatically maintain desired replica counts and enable easy scaling • Configuration Management: You implemented ConfigMaps to externalize application configuration and mounted them as environment variables in Pods

Why This Matters: These building blocks form the foundation of container orchestration in Kubernetes. Pods represent the smallest deployable units, Deployments provide reliability and scaling capabilities, and ConfigMaps enable configuration management best practices. Understanding these concepts is essential for:

• Building resilient, scalable applications in Kubernetes • Implementing proper separation of concerns between code and configuration • Preparing for production deployments and cloud-native application development • Advancing toward Kubernetes certification goals (KCNA)

Next Steps: With this foundation, you're ready to explore more advanced Kubernetes concepts such as Services for networking, Persistent Volumes for storage, and Ingress controllers for external access. These building blocks will serve as the basis for more complex orchestration scenarios in your Kubernetes journey.




Lab 8: Implementing Security with Authentication, Authorization, and Admission Control
Objectives

By the end of this lab, you will be able to:

• Understand the fundamentals of Kubernetes security model including authentication, authorization, and admission control • Create and configure service accounts for applications and services • Implement Role-Based Access Control (RBAC) to manage permissions • Test access control mechanisms by attempting authorized and unauthorized actions • Configure admission controllers to enforce security policies and resource limits • Validate that security policies are working correctly in a Kubernetes cluster
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (pods, services, deployments) • Familiarity with command-line interface operations • Knowledge of YAML file structure and syntax • Understanding of Linux file permissions and user management concepts • Basic knowledge of kubectl commands

Note: Al Nafi provides ready-to-use Linux-based cloud machines with Kubernetes pre-installed. Simply click "Start Lab" to begin - no need to build your own VM or install Kubernetes manually.
Lab Environment Setup

Your Al Nafi cloud machine comes pre-configured with: • Kubernetes cluster (single-node for learning purposes) • kubectl command-line tool • Text editors (nano, vim) • All necessary permissions to complete this lab
Task 1: Understanding Kubernetes Security Architecture
Subtask 1.1: Explore Current Security Context

First, let's examine the current security context and understand what's already configured.

    Check your current user context:

kubectl config current-context

    View cluster information:

kubectl cluster-info

    List existing service accounts:

kubectl get serviceaccounts --all-namespaces

    Examine the default service account:

kubectl describe serviceaccount default

Subtask 1.2: Understand RBAC Components

    List existing roles and cluster roles:

kubectl get roles --all-namespaces
kubectl get clusterroles

    Examine a built-in cluster role:

kubectl describe clusterrole view

    List role bindings:

kubectl get rolebindings --all-namespaces
kubectl get clusterrolebindings

Task 2: Create Service Accounts and Implement RBAC
Subtask 2.1: Create a Dedicated Namespace

    Create a new namespace for our security lab:

kubectl create namespace security-lab

    Set the namespace as default for this session:

kubectl config set-context --current --namespace=security-lab

    Verify the namespace creation:

kubectl get namespaces

Subtask 2.2: Create Service Accounts

    Create a service account for a developer role:

kubectl create serviceaccount developer-sa -n security-lab

    Create a service account for a viewer role:

kubectl create serviceaccount viewer-sa -n security-lab

    Create a service account for an admin role:

kubectl create serviceaccount admin-sa -n security-lab

    Verify service account creation:

kubectl get serviceaccounts -n security-lab

    Examine the developer service account details:

kubectl describe serviceaccount developer-sa -n security-lab

Subtask 2.3: Create Custom Roles

    Create a developer role with specific permissions:

Create a file named developer-role.yaml:

cat > developer-role.yaml << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: security-lab
  name: developer-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
EOF

    Apply the developer role:

kubectl apply -f developer-role.yaml

    Create a viewer role with read-only permissions:

Create a file named viewer-role.yaml:

cat > viewer-role.yaml << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: security-lab
  name: viewer-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps"]
  verbs: ["get", "list"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list"]
EOF

    Apply the viewer role:

kubectl apply -f viewer-role.yaml

    Verify role creation:

kubectl get roles -n security-lab

Subtask 2.4: Create Role Bindings

    Bind the developer role to the developer service account:

Create a file named developer-rolebinding.yaml:

cat > developer-rolebinding.yaml << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: security-lab
subjects:
- kind: ServiceAccount
  name: developer-sa
  namespace: security-lab
roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
EOF

    Apply the developer role binding:

kubectl apply -f developer-rolebinding.yaml

    Bind the viewer role to the viewer service account:

Create a file named viewer-rolebinding.yaml:

cat > viewer-rolebinding.yaml << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: viewer-binding
  namespace: security-lab
subjects:
- kind: ServiceAccount
  name: viewer-sa
  namespace: security-lab
roleRef:
  kind: Role
  name: viewer-role
  apiGroup: rbac.authorization.k8s.io
EOF

    Apply the viewer role binding:

kubectl apply -f viewer-rolebinding.yaml

    Bind the admin service account to cluster-admin role:

Create a file named admin-clusterrolebinding.yaml:

cat > admin-clusterrolebinding.yaml << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-binding
subjects:
- kind: ServiceAccount
  name: admin-sa
  namespace: security-lab
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF

    Apply the admin cluster role binding:

kubectl apply -f admin-clusterrolebinding.yaml

    Verify all role bindings:

kubectl get rolebindings -n security-lab
kubectl get clusterrolebindings | grep admin-binding

Task 3: Test Access Control Mechanisms
Subtask 3.1: Create Test Resources

    Create a test deployment for our access control tests:

Create a file named test-deployment.yaml:

cat > test-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app
  namespace: security-lab
spec:
  replicas: 2
  selector:
    matchLabels:
      app: test-app
  template:
    metadata:
      labels:
        app: test-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
EOF

    Deploy the test application:

kubectl apply -f test-deployment.yaml

    Verify the deployment:

kubectl get deployments -n security-lab
kubectl get pods -n security-lab

Subtask 3.2: Test Service Account Permissions

    Get service account tokens for testing:

# Get the developer service account token
DEVELOPER_TOKEN=$(kubectl create token developer-sa -n security-lab)
echo "Developer token: $DEVELOPER_TOKEN"

# Get the viewer service account token
VIEWER_TOKEN=$(kubectl create token viewer-sa -n security-lab)
echo "Viewer token: $VIEWER_TOKEN"

# Get the admin service account token
ADMIN_TOKEN=$(kubectl create token admin-sa -n security-lab)
echo "Admin token: $ADMIN_TOKEN"

    Test developer permissions (should succeed):

# Test listing pods as developer
kubectl --token=$DEVELOPER_TOKEN get pods -n security-lab

# Test creating a configmap as developer
kubectl --token=$DEVELOPER_TOKEN create configmap test-config --from-literal=key1=value1 -n security-lab

# Test scaling deployment as developer
kubectl --token=$DEVELOPER_TOKEN scale deployment test-app --replicas=3 -n security-lab

    Test viewer permissions (read operations should succeed):

# Test listing pods as viewer (should work)
kubectl --token=$VIEWER_TOKEN get pods -n security-lab

# Test listing deployments as viewer (should work)
kubectl --token=$VIEWER_TOKEN get deployments -n security-lab

    Test viewer unauthorized actions (should fail):

# Test creating a configmap as viewer (should fail)
kubectl --token=$VIEWER_TOKEN create configmap viewer-test --from-literal=key1=value1 -n security-lab

# Test deleting a pod as viewer (should fail)
kubectl --token=$VIEWER_TOKEN delete pod $(kubectl get pods -n security-lab -o jsonpath='{.items[0].metadata.name}') -n security-lab

    Test admin permissions (should succeed for everything):

# Test cluster-wide operations as admin
kubectl --token=$ADMIN_TOKEN get nodes

# Test creating resources in any namespace
kubectl --token=$ADMIN_TOKEN create configmap admin-test --from-literal=admin=true -n default

Subtask 3.3: Verify Access Control Results

    Check what resources were created by different service accounts:

kubectl get configmaps -n security-lab
kubectl get configmaps -n default

    Examine the current state of our test deployment:

kubectl get deployment test-app -n security-lab
kubectl describe deployment test-app -n security-lab

Task 4: Configure Admission Controllers
Subtask 4.1: Understand Current Admission Controllers

    Check which admission controllers are enabled:

kubectl describe pod kube-apiserver-$(hostname) -n kube-system | grep admission

    Create a resource quota to demonstrate admission control:

Create a file named resource-quota.yaml:

cat > resource-quota.yaml << EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: security-lab-quota
  namespace: security-lab
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
    pods: "10"
    services: "5"
    configmaps: "10"
EOF

    Apply the resource quota:

kubectl apply -f resource-quota.yaml

    Verify the resource quota:

kubectl describe resourcequota security-lab-quota -n security-lab

Subtask 4.2: Test Resource Quota Enforcement

    Create a deployment that exceeds resource limits:

Create a file named resource-heavy-deployment.yaml:

cat > resource-heavy-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-heavy-app
  namespace: security-lab
spec:
  replicas: 5
  selector:
    matchLabels:
      app: resource-heavy-app
  template:
    metadata:
      labels:
        app: resource-heavy-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "1Gi"
            cpu: "1"
          limits:
            memory: "2Gi"
            cpu: "2"
EOF

    Try to apply the resource-heavy deployment:

kubectl apply -f resource-heavy-deployment.yaml

    Check the deployment status:

kubectl get deployment resource-heavy-app -n security-lab
kubectl describe deployment resource-heavy-app -n security-lab

    Check resource quota usage:

kubectl describe resourcequota security-lab-quota -n security-lab

Subtask 4.3: Configure Network Policies (Additional Admission Control)

    Create a network policy to restrict pod communication:

Create a file named network-policy.yaml: ```bash cat > network-policy.yaml << EOF apiVersion: networking.k8s.io/v1 kind: NetworkPolicy metadata: name: deny-all-ingress namespace: security-lab spec: podSelector: {} policyTypes: - Ingress

apiVersion: networking.k8s.io/v1 kind: NetworkPolicy metadata: name: allow-test-app-ingress namespace: security-lab spec: podSelector: matchLabels: app: test-app policyTypes:

    Ingress ingress:
    from:
        podSelector: matchLabels: access: allowed

    ports:
        protocol: TCP port: 80 EOF


2. **Apply the network policies**:
```bash
kubectl apply -f network-policy.yaml

    Verify network policies:

kubectl get networkpolicies -n security-lab
kubectl describe networkpolicy deny-all-ingress -n security-lab

Task 5: Validate Security Implementation
Subtask 5.1: Comprehensive Security Testing

    Create a test pod to verify network policies:

Create a file named test-client.yaml:

cat > test-client.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-client
  namespace: security-lab
  labels:
    access: allowed
spec:
  containers:
  - name: client
    image: busybox
    command: ['sleep', '3600']
EOF

    Apply the test client:

kubectl apply -f test-client.yaml

    Test network connectivity:

# Wait for pod to be ready
kubectl wait --for=condition=Ready pod/test-client -n security-lab --timeout=60s

# Get the IP of one of the test-app pods
TEST_APP_IP=$(kubectl get pod -l app=test-app -n security-lab -o jsonpath='{.items[0].status.podIP}')

# Test connection from allowed client (should work)
kubectl exec test-client -n security-lab -- wget -qO- --timeout=5 http://$TEST_APP_IP

    Create an unauthorized client and test:

Create a file named unauthorized-client.yaml:

cat > unauthorized-client.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: unauthorized-client
  namespace: security-lab
spec:
  containers:
  - name: client
    image: busybox
    command: ['sleep', '3600']
EOF

    Apply and test unauthorized client:

kubectl apply -f unauthorized-client.yaml

# Wait for pod to be ready
kubectl wait --for=condition=Ready pod/unauthorized-client -n security-lab --timeout=60s

# Test connection from unauthorized client (should fail/timeout)
kubectl exec unauthorized-client -n security-lab -- timeout 10 wget -qO- http://$TEST_APP_IP || echo "Connection blocked by network policy"

Subtask 5.2: Security Audit and Verification

    Review all security components created:

echo "=== Service Accounts ==="
kubectl get serviceaccounts -n security-lab

echo "=== Roles ==="
kubectl get roles -n security-lab

echo "=== Role Bindings ==="
kubectl get rolebindings -n security-lab

echo "=== Resource Quotas ==="
kubectl get resourcequotas -n security-lab

echo "=== Network Policies ==="
kubectl get networkpolicies -n security-lab

    Test final access control scenarios:

# Test developer can still create resources within quota
kubectl --token=$DEVELOPER_TOKEN create configmap final-test --from-literal=test=passed -n security-lab

# Test viewer still cannot create resources
kubectl --token=$VIEWER_TOKEN create configmap viewer-final-test --from-literal=test=failed -n security-lab || echo "Access denied as expected"

# Check quota usage
kubectl describe resourcequota security-lab-quota -n security-lab

    Generate a security summary report:

echo "=== SECURITY LAB SUMMARY REPORT ==="
echo "Namespace: security-lab"
echo "Service Accounts Created: $(kubectl get sa -n security-lab --no-headers | wc -l)"
echo "Roles Created: $(kubectl get roles -n security-lab --no-headers | wc -l)"
echo "Role Bindings Created: $(kubectl get rolebindings -n security-lab --no-headers | wc -l)"
echo "Network Policies Active: $(kubectl get networkpolicies -n security-lab --no-headers | wc -l)"
echo "Resource Quotas Enforced: $(kubectl get resourcequotas -n security-lab --no-headers | wc -l)"
echo "Pods Running: $(kubectl get pods -n security-lab --no-headers | grep Running | wc -l)"

Troubleshooting Common Issues
Issue 1: Service Account Token Not Working

Problem: Authentication fails with service account token Solution:

# Recreate the token
kubectl delete token <token-name> -n security-lab
kubectl create token <service-account-name> -n security-lab

Issue 2: RBAC Permissions Not Applied

Problem: Role bindings don't seem to work Solution:

# Check role binding details
kubectl describe rolebinding <binding-name> -n security-lab
# Verify the role exists
kubectl get role <role-name> -n security-lab

Issue 3: Resource Quota Not Enforcing

Problem: Pods are created despite quota limits Solution:

# Check quota status
kubectl describe resourcequota -n security-lab
# Ensure pods have resource requests/limits specified

Issue 4: Network Policy Not Working

Problem: Network policies don't block traffic Solution:

# Verify your cluster supports network policies
kubectl get pods -n kube-system | grep -i network
# Check if CNI plugin supports network policies

Cleanup Instructions

To clean up the lab environment:

# Delete the namespace (this removes all resources)
kubectl delete namespace security-lab

# Remove cluster role binding
kubectl delete clusterrolebinding admin-binding

# Reset kubectl context
kubectl config set-context --current --namespace=default

Conclusion

In this comprehensive lab, you have successfully implemented and tested Kubernetes security mechanisms including:

Authentication & Authorization: • Created multiple service accounts with different permission levels • Implemented Role-Based Access Control (RBAC) with custom roles • Tested access control by attempting both authorized and unauthorized actions • Verified that different service accounts have appropriate permissions

Admission Control: • Configured resource quotas to enforce resource limits • Implemented network policies to control pod-to-pod communication • Tested admission controllers by attempting to exceed defined limits • Validated that security policies are properly enforced

Key Security Concepts Learned: • Service Accounts provide identity for applications running in pods • RBAC enables fine-grained access control using roles and role bindings • Admission Controllers enforce policies and validate requests before resources are created • Resource Quotas prevent resource exhaustion and ensure fair resource allocation • Network Policies provide network-level security by controlling traffic flow

Why This Matters: Security is fundamental to any production Kubernetes environment. The skills you've learned in this lab are essential for: • Protecting sensitive applications and data • Implementing the principle of least privilege • Ensuring compliance with security standards • Preventing unauthorized access and resource abuse • Building secure, multi-tenant Kubernetes clusters

These security practices are critical for the Kubernetes and Cloud Native Associate (KCNA) certification and are fundamental skills for anyone working with Kubernetes in production environments. The hands-on experience gained from this lab provides practical knowledge that directly applies to real-world Kubernetes security implementations.




Lab 9: Configuring and Using Kubernetes Services
Objectives

By the end of this lab, you will be able to:

• Understand the different types of Kubernetes services and their use cases • Deploy applications and expose them using ClusterIP services • Configure and test NodePort services for external access • Set up LoadBalancer services in cloud environments • Verify service connectivity and troubleshoot common issues • Understand service discovery and DNS resolution in Kubernetes
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (pods, deployments, namespaces) • Familiarity with command-line interface operations • Basic knowledge of networking concepts (IP addresses, ports) • Understanding of YAML file structure • Previous experience with kubectl commands

Note: Al Nafi provides ready-to-use Linux-based cloud machines with Kubernetes pre-installed. Simply click Start Lab to begin - no need to build your own VM or install Kubernetes manually.
Lab Environment Setup

Your Al Nafi cloud machine comes pre-configured with: • Kubernetes cluster (single-node or multi-node) • kubectl command-line tool • Docker runtime • All necessary networking components
Task 1: Deploy an Application and Expose it Using ClusterIP Service
Subtask 1.1: Create a Sample Application Deployment

First, let's create a simple web application deployment that we'll use throughout this lab.

    Create a new directory for your lab files:

mkdir ~/k8s-services-lab
cd ~/k8s-services-lab

    Create a deployment YAML file for a sample nginx application:

cat > nginx-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
EOF

    Deploy the application to your Kubernetes cluster:

kubectl apply -f nginx-deployment.yaml

    Verify that the deployment is running:

kubectl get deployments
kubectl get pods -l app=nginx

You should see 3 nginx pods in the Running state.
Subtask 1.2: Create a ClusterIP Service

A ClusterIP service is the default service type that exposes the service on an internal IP within the cluster. It's only accessible from within the cluster.

    Create a ClusterIP service YAML file:

cat > nginx-clusterip-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-clusterip-service
  labels:
    app: nginx
spec:
  type: ClusterIP
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
EOF

    Apply the ClusterIP service:

kubectl apply -f nginx-clusterip-service.yaml

    Verify the service creation:

kubectl get services
kubectl describe service nginx-clusterip-service

Subtask 1.3: Test ClusterIP Service Connectivity

    Get the ClusterIP address of your service:

kubectl get service nginx-clusterip-service -o wide

    Create a temporary pod to test internal connectivity:

kubectl run test-pod --image=busybox --rm -it --restart=Never -- sh

    From within the test pod, test the service connectivity:

# Test using the service IP (replace with your actual ClusterIP)
wget -qO- http://10.96.xxx.xxx

# Test using service name (DNS resolution)
wget -qO- http://nginx-clusterip-service

# Test using FQDN
wget -qO- http://nginx-clusterip-service.default.svc.cluster.local

# Exit the test pod
exit

You should see the nginx welcome page HTML content, confirming that the ClusterIP service is working correctly.
Task 2: Change Service Type to NodePort and Verify External Access
Subtask 2.1: Convert ClusterIP to NodePort Service

A NodePort service exposes the service on each node's IP at a static port, making it accessible from outside the cluster.

    Create a NodePort service YAML file:

cat > nginx-nodeport-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport-service
  labels:
    app: nginx
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
    protocol: TCP
EOF

    Apply the NodePort service:

kubectl apply -f nginx-nodeport-service.yaml

    Verify the NodePort service:

kubectl get services
kubectl describe service nginx-nodeport-service

Subtask 2.2: Test External Access via NodePort

    Get your node's external IP address:

kubectl get nodes -o wide

    Test external access using curl (replace with your node's IP):

# Test from within the cluster
curl http://localhost:30080

# If you have external access to the node
curl http://NODE_EXTERNAL_IP:30080

    Verify that the service is accessible on all nodes:

# List all nodes
kubectl get nodes

# Check if the service is accessible on each node
for node in $(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'); do
  echo "Testing node: $node"
  curl -s http://$node:30080 | grep -o "<title>.*</title>" || echo "Failed to connect"
done

Subtask 2.3: Understanding NodePort Range and Limitations

    Check the default NodePort range:

kubectl cluster-info dump | grep service-node-port-range

    Create another NodePort service without specifying a port:

cat > nginx-nodeport-auto.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport-auto
  labels:
    app: nginx
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
EOF

    Apply and observe the automatically assigned port:

kubectl apply -f nginx-nodeport-auto.yaml
kubectl get service nginx-nodeport-auto

Task 3: Configure LoadBalancer Service in Cloud Environment
Subtask 3.1: Understanding LoadBalancer Services

A LoadBalancer service exposes the service externally using a cloud provider's load balancer. This is the most production-ready way to expose services externally.

Note: LoadBalancer services require a cloud provider that supports external load balancers. If you're running on a local cluster or a cloud provider without load balancer support, the service will remain in Pending state.

    Create a LoadBalancer service YAML file:

cat > nginx-loadbalancer-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-loadbalancer-service
  labels:
    app: nginx
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
EOF

    Apply the LoadBalancer service:

kubectl apply -f nginx-loadbalancer-service.yaml

    Monitor the LoadBalancer service creation:

kubectl get service nginx-loadbalancer-service --watch

Subtask 3.2: Test LoadBalancer Service (Cloud Environment)

If you're in a supported cloud environment:

    Wait for the external IP to be assigned:

kubectl get service nginx-loadbalancer-service

    Once the external IP is available, test the service:

# Replace EXTERNAL-IP with the actual external IP
curl http://EXTERNAL-IP

    Test load balancing by making multiple requests:

for i in {1..10}; do
  curl -s http://EXTERNAL-IP | grep -o "Server: .*" || echo "Request $i failed"
  sleep 1
done

Subtask 3.3: Simulate LoadBalancer with MetalLB (Local Environment)

If you're in a local environment, you can simulate LoadBalancer functionality using MetalLB:

    Install MetalLB:

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

    Wait for MetalLB to be ready:

kubectl wait --namespace metallb-system \
  --for=condition=ready pod \
  --selector=app=metallb \
  --timeout=90s

    Configure MetalLB with an IP address pool:

cat > metallb-config.yaml << EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: example
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.240-192.168.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: empty
  namespace: metallb-system
EOF

    Apply the MetalLB configuration:

kubectl apply -f metallb-config.yaml

    Check if your LoadBalancer service now has an external IP:

kubectl get service nginx-loadbalancer-service

Task 4: Service Discovery and DNS Testing
Subtask 4.1: Test Service DNS Resolution

    Create a test pod for DNS testing:

kubectl run dns-test --image=busybox --rm -it --restart=Never -- sh

    From within the test pod, test different DNS resolution methods:

# Test short name resolution
nslookup nginx-clusterip-service

# Test FQDN resolution
nslookup nginx-clusterip-service.default.svc.cluster.local

# Test service discovery
nslookup nginx-nodeport-service

# Exit the test pod
exit

Subtask 4.2: Explore Service Endpoints

    Check the endpoints created by your services:

kubectl get endpoints
kubectl describe endpoints nginx-clusterip-service

    Verify that endpoints match your pod IPs:

kubectl get pods -l app=nginx -o wide

    Test what happens when you scale your deployment:

# Scale up the deployment
kubectl scale deployment nginx-app --replicas=5

# Check updated endpoints
kubectl get endpoints nginx-clusterip-service

# Scale back down
kubectl scale deployment nginx-app --replicas=3

Task 5: Service Troubleshooting and Best Practices
Subtask 5.1: Common Service Issues and Solutions

    Create a service with incorrect selector to demonstrate troubleshooting:

cat > nginx-broken-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-broken-service
spec:
  type: ClusterIP
  selector:
    app: wrong-label
  ports:
  - port: 80
    targetPort: 80
EOF

    Apply the broken service:

kubectl apply -f nginx-broken-service.yaml

    Troubleshoot the service:

# Check service details
kubectl describe service nginx-broken-service

# Check endpoints (should be empty)
kubectl get endpoints nginx-broken-service

# Compare with working service
kubectl get endpoints nginx-clusterip-service

    Fix the service by updating the selector:

kubectl patch service nginx-broken-service -p '{"spec":{"selector":{"app":"nginx"}}}'

    Verify the fix:

kubectl get endpoints nginx-broken-service

Subtask 5.2: Service Performance and Monitoring

    Check service resource usage:

kubectl top pods -l app=nginx

    Monitor service connections:

# Create a load testing pod
kubectl run load-test --image=busybox --rm -it --restart=Never -- sh

# From within the load test pod, generate some traffic
for i in $(seq 1 100); do
  wget -qO- http://nginx-clusterip-service > /dev/null
  echo "Request $i completed"
done

exit

    Check service logs:

kubectl logs -l app=nginx --tail=20

Task 6: Cleanup and Service Management
Subtask 6.1: Clean Up Resources

    List all services created in this lab:

kubectl get services

    Delete the services:

kubectl delete service nginx-clusterip-service
kubectl delete service nginx-nodeport-service
kubectl delete service nginx-loadbalancer-service
kubectl delete service nginx-nodeport-auto
kubectl delete service nginx-broken-service

    Delete the deployment:

kubectl delete deployment nginx-app

    Verify cleanup:

kubectl get all

Subtask 6.2: Service Configuration Best Practices

    Create a production-ready service configuration:

cat > nginx-production-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-production
  labels:
    app: nginx
    environment: production
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-path: /health
spec:
  type: LoadBalancer
  selector:
    app: nginx
    environment: production
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  - name: https
    port: 443
    targetPort: 443
    protocol: TCP
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
EOF

This configuration includes:

    Proper labeling for organization
    Annotations for cloud provider specific settings
    Named ports for clarity
    Multiple ports for HTTP and HTTPS
    Session affinity for sticky sessions

Troubleshooting Common Issues
Service Not Accessible

Problem: Service is not responding to requests Solutions:

    Check if pods are running: kubectl get pods -l app=nginx
    Verify service selector matches pod labels: kubectl describe service SERVICE_NAME
    Check endpoints: kubectl get endpoints SERVICE_NAME
    Test from within cluster first before external access

LoadBalancer Stuck in Pending

Problem: LoadBalancer service shows <pending> for external IP Solutions:

    Verify cloud provider supports LoadBalancer services
    Check cloud provider quotas and limits
    Review service annotations for cloud-specific requirements
    Consider using NodePort or Ingress as alternatives

DNS Resolution Issues

Problem: Services not accessible by name Solutions:

    Check CoreDNS pods: kubectl get pods -n kube-system -l k8s-app=kube-dns
    Verify service exists: kubectl get services
    Test with FQDN: service-name.namespace.svc.cluster.local
    Check network policies that might block DNS

Conclusion

In this lab, you have successfully:

• Deployed applications and exposed them using different Kubernetes service types • Configured ClusterIP services for internal cluster communication • Set up NodePort services to enable external access through node IPs • Implemented LoadBalancer services for production-grade external access • Tested service discovery and DNS resolution within the cluster • Troubleshot common service issues and applied best practices

Why This Matters: Kubernetes services are fundamental to application networking and service discovery. Understanding how to properly configure and use different service types is crucial for:

    Microservices Architecture: Services enable communication between different application components
    High Availability: Load balancing across multiple pod replicas ensures application resilience
    Security: ClusterIP services provide internal-only access while LoadBalancers offer controlled external access
    Scalability: Services abstract away individual pod IPs, allowing seamless scaling
    Production Readiness: Proper service configuration is essential for deploying applications in production environments

The skills you've learned in this lab form the foundation for more advanced Kubernetes networking concepts like Ingress controllers, service meshes, and network policies. These service types and configurations are commonly tested in the Kubernetes and Cloud Native Associate (KCNA) certification and are essential for any Kubernetes practitioner.




Lab 10: Deploying a Stand-Alone Application in Kubernetes
Objectives

By the end of this lab, you will be able to:

• Create and deploy a Kubernetes manifest for a stand-alone application • Configure and deploy a NodePort service to expose applications externally • Monitor application logs using kubectl commands • View and analyze resource metrics for deployed applications • Understand the relationship between Deployments, Pods, and Services in Kubernetes • Troubleshoot common deployment issues in Kubernetes environments
Prerequisites

Before starting this lab, you should have:

• Basic understanding of containerization concepts (Docker) • Familiarity with YAML file structure and syntax • Basic knowledge of Linux command line operations • Understanding of networking concepts (ports, IP addresses) • Previous experience with kubectl commands (recommended but not required)
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with Kubernetes already installed and configured. Simply click Start Lab to access your environment - no need to build your own VM or install Kubernetes from scratch.

Your lab environment includes: • Ubuntu 20.04 LTS with kubectl pre-installed • Minikube cluster ready for use • All necessary tools and dependencies configured • Internet access for pulling container images
Task 1: Write and Deploy a Kubernetes Manifest for a Stand-Alone Application
Subtask 1.1: Verify Kubernetes Cluster Status

First, let's ensure your Kubernetes cluster is running properly.

    Open a terminal in your lab environment
    Check the cluster status:

kubectl cluster-info

    Verify that nodes are ready:

kubectl get nodes

You should see output similar to:

NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   1d    v1.28.3

Subtask 1.2: Create the Application Deployment Manifest

We'll deploy a simple web application using NGINX as our stand-alone application.

    Create a new directory for your lab files:

mkdir ~/k8s-lab10
cd ~/k8s-lab10

    Create the deployment manifest file:

nano nginx-deployment.yaml

    Copy and paste the following YAML content:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-standalone-app
  labels:
    app: nginx-standalone
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-standalone
  template:
    metadata:
      labels:
        app: nginx-standalone
    spec:
      containers:
      - name: nginx
        image: nginx:1.25.3
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        env:
        - name: NGINX_PORT
          value: "80"

    Save and exit the file (Ctrl+X, then Y, then Enter)

Subtask 1.3: Deploy the Application

    Apply the deployment manifest:

kubectl apply -f nginx-deployment.yaml

    Verify the deployment was created successfully:

kubectl get deployments

    Check the status of the pods:

kubectl get pods -l app=nginx-standalone

    Wait for all pods to be in the "Running" status. You can watch the status in real-time:

kubectl get pods -l app=nginx-standalone -w

Press Ctrl+C to stop watching once all pods are running.
Subtask 1.4: Verify Application Details

    Get detailed information about the deployment:

kubectl describe deployment nginx-standalone-app

    Check the replica set created by the deployment:

kubectl get replicasets -l app=nginx-standalone

Task 2: Expose the Application Externally Using a NodePort Service
Subtask 2.1: Create the NodePort Service Manifest

    Create a service manifest file:

nano nginx-service.yaml

    Add the following YAML content:

apiVersion: v1
kind: Service
metadata:
  name: nginx-standalone-service
  labels:
    app: nginx-standalone
spec:
  type: NodePort
  selector:
    app: nginx-standalone
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
    protocol: TCP
    name: http

    Save and exit the file

Subtask 2.2: Deploy the Service

    Apply the service manifest:

kubectl apply -f nginx-service.yaml

    Verify the service was created:

kubectl get services

    Get detailed information about the service:

kubectl describe service nginx-standalone-service

Subtask 2.3: Test External Access

    Get the cluster IP address:

minikube ip

    Test the application accessibility using curl:

curl http://$(minikube ip):30080

You should see the default NGINX welcome page HTML content.

    Alternatively, you can access the application through your browser. Get the full URL:

echo "Access your application at: http://$(minikube ip):30080"

Subtask 2.4: Verify Service Endpoints

    Check the service endpoints to ensure they're pointing to your pods:

kubectl get endpoints nginx-standalone-service

    Compare the endpoint IPs with your pod IPs:

kubectl get pods -l app=nginx-standalone -o wide

Task 3: Monitor Application Logs and Resource Metrics
Subtask 3.1: Monitor Application Logs

    View logs from all pods in the deployment:

kubectl logs -l app=nginx-standalone

    Follow logs in real-time from a specific pod:

# First, get a pod name
kubectl get pods -l app=nginx-standalone

# Then follow logs (replace POD_NAME with actual pod name)
kubectl logs -f POD_NAME

    Generate some traffic to create log entries:

# In a new terminal, run this command multiple times
curl http://$(minikube ip):30080

    View logs from the last 10 minutes:

kubectl logs -l app=nginx-standalone --since=10m

Subtask 3.2: Monitor Resource Usage

    Check resource usage for your pods:

kubectl top pods -l app=nginx-standalone

    Monitor resource usage for the entire cluster:

kubectl top nodes

    Get detailed resource information for a specific pod:

# Replace POD_NAME with an actual pod name
kubectl describe pod POD_NAME

Subtask 3.3: Monitor Application Health

    Check the readiness and liveness of your pods:

kubectl get pods -l app=nginx-standalone -o wide

    View events related to your deployment:

kubectl get events --field-selector involvedObject.name=nginx-standalone-app

    Monitor the deployment status:

kubectl rollout status deployment/nginx-standalone-app

Subtask 3.4: Create a Custom HTML Page

Let's customize our application to make monitoring more interesting.

    Create a custom HTML file:

cat > custom-index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Kubernetes Lab 10 - Stand-Alone App</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f0f8ff; }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; background: white; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; text-align: center; }
        .info { background: #e8f4fd; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .success { color: #27ae60; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Kubernetes Stand-Alone Application</h1>
        <div class="info">
            <h3>Lab 10 Deployment Successful!</h3>
            <p><span class="success">✓</span> Application deployed using Kubernetes Deployment</p>
            <p><span class="success">✓</span> Service exposed via NodePort (30080)</p>
            <p><span class="success">✓</span> Multiple replicas running for high availability</p>
            <p><span class="success">✓</span> Resource limits and requests configured</p>
        </div>
        <p><strong>Hostname:</strong> <span id="hostname">Loading...</span></p>
        <p><strong>Timestamp:</strong> <span id="timestamp"></span></p>
    </div>
    <script>
        document.getElementById('hostname') = window.location.hostname;
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF

    Create a ConfigMap with the custom HTML:

kubectl create configmap nginx-custom-html --from-file=index.html=custom-index.html

    Update the deployment to use the custom HTML:

cat > nginx-deployment-updated.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-standalone-app
  labels:
    app: nginx-standalone
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-standalone
  template:
    metadata:
      labels:
        app: nginx-standalone
    spec:
      containers:
      - name: nginx
        image: nginx:1.25.3
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        volumeMounts:
        - name: html-volume
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-volume
        configMap:
          name: nginx-custom-html
EOF

    Apply the updated deployment:

kubectl apply -f nginx-deployment-updated.yaml

    Wait for the rollout to complete:

kubectl rollout status deployment/nginx-standalone-app

    Test the updated application:

curl http://$(minikube ip):30080

Troubleshooting Common Issues
Issue 1: Pods Not Starting

If your pods are not starting, check the following:

# Check pod status and events
kubectl describe pods -l app=nginx-standalone

# Check if the image can be pulled
kubectl get events --sort-by=.metadata.creationTimestamp

Issue 2: Service Not Accessible

If you can't access the service externally:

# Verify service configuration
kubectl get svc nginx-standalone-service -o yaml

# Check if minikube tunnel is needed (for some environments)
minikube service nginx-standalone-service --url

Issue 3: Resource Issues

If pods are pending due to resource constraints:

# Check node resources
kubectl describe nodes

# Check resource requests vs available
kubectl top nodes

Lab Cleanup

When you're finished with the lab, clean up the resources:

# Delete the service
kubectl delete service nginx-standalone-service

# Delete the deployment
kubectl delete deployment nginx-standalone-app

# Delete the ConfigMap
kubectl delete configmap nginx-custom-html

# Verify cleanup
kubectl get all -l app=nginx-standalone

Conclusion

Congratulations! You have successfully completed Lab 10: Deploying a Stand-Alone Application in Kubernetes.
What You Accomplished

In this lab, you have:

• Created and deployed a Kubernetes Deployment - You learned how to write YAML manifests to define application deployments with multiple replicas, resource limits, and container specifications

• Exposed applications externally - You successfully configured a NodePort service to make your application accessible from outside the Kubernetes cluster

• Monitored application health and performance - You gained hands-on experience with kubectl commands for viewing logs, checking resource usage, and monitoring application status

• Implemented best practices - You applied resource requests and limits, used labels for organization, and configured proper service selectors
Why This Matters

Understanding how to deploy stand-alone applications in Kubernetes is fundamental for:

• Production deployments - These skills form the foundation for deploying real-world applications in Kubernetes environments

• Cloud-native development - Modern applications increasingly rely on container orchestration platforms like Kubernetes

• Career advancement - These skills are essential for roles in DevOps, Site Reliability Engineering, and Cloud Architecture

• KCNA certification preparation - This lab directly supports your preparation for the Kubernetes and Cloud Native Associate certification

The concepts you've learned here - Deployments, Services, resource management, and monitoring - are building blocks for more advanced Kubernetes topics like StatefulSets, Ingress controllers, and service meshes. You now have practical experience with the core workflow of deploying and managing applications in Kubernetes, which will serve as a solid foundation for your continued learning in cloud-native technologies.




Lab 11: Managing Kubernetes Volumes and Persistent Storage
Objectives

By the end of this lab, you will be able to:

• Understand the difference between Volumes, PersistentVolumes (PV), and PersistentVolumeClaims (PVC) • Create and configure PersistentVolumes with different storage classes • Create PersistentVolumeClaims to request storage resources • Deploy applications that utilize persistent storage • Verify data persistence across pod restarts and deletions • Troubleshoot common storage-related issues in Kubernetes • Implement best practices for managing persistent data in containerized applications
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (Pods, Deployments, Services) • Familiarity with YAML syntax and Kubernetes manifest files • Basic Linux command-line knowledge • Understanding of file systems and storage concepts • Completed previous Kubernetes labs or equivalent experience
Ready-to-Use Cloud Machines

Al Nafi provides pre-configured Linux-based cloud machines for this lab. Simply click Start Lab to access your environment. Your machine comes with:

• Kubernetes cluster (minikube) pre-installed and configured • kubectl command-line tool ready to use • All necessary permissions and tools configured • No need to build your own VM or install software
Lab Environment Setup
Task 1: Verify Kubernetes Cluster Status
Subtask 1.1: Check Cluster Information

First, let's verify that your Kubernetes cluster is running properly.

# Check cluster status
kubectl cluster-info

# Verify nodes are ready
kubectl get nodes

# Check available storage classes
kubectl get storageclass

Expected Output:

NAME                 PROVISIONER                RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
standard (default)   k8s.io/minikube-hostpath   Delete          Immediate           false                  5m

Subtask 1.2: Create Lab Namespace

Create a dedicated namespace for this lab to keep resources organized.

# Create namespace for the lab
kubectl create namespace storage-lab

# Set the namespace as default for this session
kubectl config set-context --current --namespace=storage-lab

# Verify namespace creation
kubectl get namespaces

Task 2: Create PersistentVolume and PersistentVolumeClaim
Subtask 2.1: Create a PersistentVolume

A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes.

Create a file named persistent-volume.yaml:

cat > persistent-volume.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolume
metadata:
  name: lab-pv
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp/lab-data"
  persistentVolumeReclaimPolicy: Retain
EOF

Key Configuration Explained: • storageClassName: manual - Custom storage class for this lab • capacity: 1Gi - Allocates 1 gigabyte of storage • accessModes: ReadWriteOnce - Can be mounted by one node at a time • hostPath - Uses local node storage (suitable for single-node clusters) • persistentVolumeReclaimPolicy: Retain - Data persists after PVC deletion

Apply the PersistentVolume:

# Create the PersistentVolume
kubectl apply -f persistent-volume.yaml

# Verify PV creation
kubectl get pv

# Get detailed information about the PV
kubectl describe pv lab-pv

Subtask 2.2: Create a PersistentVolumeClaim

A PersistentVolumeClaim (PVC) is a request for storage by a user. It's similar to a Pod requesting compute resources.

Create a file named persistent-volume-claim.yaml:

cat > persistent-volume-claim.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: lab-pvc
  namespace: storage-lab
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
EOF

Key Configuration Explained: • storageClassName: manual - Must match the PV's storage class • accessModes: ReadWriteOnce - Must be compatible with PV access modes • requests.storage: 500Mi - Requests 500 megabytes (less than PV capacity)

Apply the PersistentVolumeClaim:

# Create the PVC
kubectl apply -f persistent-volume-claim.yaml

# Check PVC status
kubectl get pvc

# Verify PV is now bound to PVC
kubectl get pv

# Get detailed PVC information
kubectl describe pvc lab-pvc

Expected Status: The PVC should show Bound status, and the PV should show Bound to storage-lab/lab-pvc.
Task 3: Deploy Application with Persistent Storage
Subtask 3.1: Create Application Deployment

Now we'll deploy an application that writes data to the persistent volume to demonstrate data persistence.

Create a file named storage-app-deployment.yaml:

cat > storage-app-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: storage-app
  namespace: storage-lab
  labels:
    app: storage-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: storage-app
  template:
    metadata:
      labels:
        app: storage-app
    spec:
      containers:
      - name: storage-container
        image: busybox:1.35
        command: ["/bin/sh"]
        args: ["-c", "while true; do echo $(date) >> /data/timestamps.log; sleep 30; done"]
        volumeMounts:
        - name: storage-volume
          mountPath: /data
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
      volumes:
      - name: storage-volume
        persistentVolumeClaim:
          claimName: lab-pvc
EOF

Application Behavior Explained: • busybox:1.35 - Lightweight Linux container • Command - Writes timestamp to /data/timestamps.log every 30 seconds • volumeMounts - Mounts PVC at /data path inside container • Resource limits - Prevents resource overconsumption

Deploy the application:

# Deploy the application
kubectl apply -f storage-app-deployment.yaml

# Check deployment status
kubectl get deployments

# Check pod status
kubectl get pods

# Wait for pod to be running
kubectl wait --for=condition=Ready pod -l app=storage-app --timeout=60s

Subtask 3.2: Verify Data Writing

Let's verify that the application is successfully writing data to the persistent volume.

# Get the pod name
POD_NAME=$(kubectl get pods -l app=storage-app -o jsonpath='{.items[0].metadata.name}')

# Check if data is being written
kubectl exec $POD_NAME -- ls -la /data

# View the content of the log file
kubectl exec $POD_NAME -- cat /data/timestamps.log

# Monitor real-time data writing (press Ctrl+C to stop)
kubectl exec $POD_NAME -- tail -f /data/timestamps.log

Expected Output: You should see timestamps being written to the file every 30 seconds.
Subtask 3.3: Create Service for Application Access

Create a service to access the application:

cat > storage-app-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: storage-app-service
  namespace: storage-lab
spec:
  selector:
    app: storage-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: ClusterIP
EOF

# Apply the service
kubectl apply -f storage-app-service.yaml

# Verify service creation
kubectl get services

Task 4: Verify Data Persistence
Subtask 4.1: Delete and Recreate Application

Now we'll test the core functionality of persistent storage by deleting the application and verifying that data persists.

# First, let's see how much data we have
kubectl exec $POD_NAME -- wc -l /data/timestamps.log

# Note the current timestamp count
INITIAL_COUNT=$(kubectl exec $POD_NAME -- wc -l /data/timestamps.log | awk '{print $1}')
echo "Initial line count: $INITIAL_COUNT"

# Delete the deployment (this will delete the pod)
kubectl delete deployment storage-app

# Verify pod is deleted
kubectl get pods

# Wait a moment to ensure complete deletion
sleep 10

Subtask 4.2: Recreate Application and Verify Data

# Recreate the deployment
kubectl apply -f storage-app-deployment.yaml

# Wait for new pod to be ready
kubectl wait --for=condition=Ready pod -l app=storage-app --timeout=60s

# Get new pod name
NEW_POD_NAME=$(kubectl get pods -l app=storage-app -o jsonpath='{.items[0].metadata.name}')

# Check if our data still exists
kubectl exec $NEW_POD_NAME -- ls -la /data

# Verify the log file still contains our previous data
kubectl exec $NEW_POD_NAME -- head -5 /data/timestamps.log

# Check current line count
CURRENT_COUNT=$(kubectl exec $NEW_POD_NAME -- wc -l /data/timestamps.log | awk '{print $1}')
echo "Current line count: $CURRENT_COUNT"

# The count should be equal or greater than initial count
if [ $CURRENT_COUNT -ge $INITIAL_COUNT ]; then
    echo "SUCCESS: Data persisted across pod deletion and recreation!"
else
    echo "WARNING: Some data may have been lost"
fi

Subtask 4.3: Advanced Persistence Testing

Let's perform additional tests to thoroughly verify persistence:

# Create a test file with specific content
kubectl exec $NEW_POD_NAME -- sh -c 'echo "Persistence Test - $(date)" > /data/test-file.txt'

# Add some structured data
kubectl exec $NEW_POD_NAME -- sh -c 'echo "Lab: Kubernetes Persistent Storage" >> /data/test-file.txt'
kubectl exec $NEW_POD_NAME -- sh -c 'echo "Student: $(whoami)" >> /data/test-file.txt'
kubectl exec $NEW_POD_NAME -- sh -c 'echo "Node: $(hostname)" >> /data/test-file.txt'

# Verify file creation
kubectl exec $NEW_POD_NAME -- cat /data/test-file.txt

# Scale deployment to 0 replicas (another way to delete pods)
kubectl scale deployment storage-app --replicas=0

# Verify no pods are running
kubectl get pods

# Scale back to 1 replica
kubectl scale deployment storage-app --replicas=1

# Wait for pod to be ready
kubectl wait --for=condition=Ready pod -l app=storage-app --timeout=60s

# Get newest pod name
FINAL_POD_NAME=$(kubectl get pods -l app=storage-app -o jsonpath='{.items[0].metadata.name}')

# Verify our test file still exists
kubectl exec $FINAL_POD_NAME -- cat /data/test-file.txt

echo "Final persistence test completed successfully!"

Task 5: Storage Management and Monitoring
Subtask 5.1: Monitor Storage Usage

# Check storage usage inside the pod
kubectl exec $FINAL_POD_NAME -- df -h /data

# Check PV and PVC status
kubectl get pv,pvc

# Get detailed storage information
kubectl describe pv lab-pv
kubectl describe pvc lab-pvc

# Check events related to storage
kubectl get events --field-selector involvedObject.kind=PersistentVolume
kubectl get events --field-selector involvedObject.kind=PersistentVolumeClaim

Subtask 5.2: Create Storage Monitoring Script

Create a script to monitor storage usage:

cat > monitor-storage.sh << 'EOF'
#!/bin/bash

echo "=== Kubernetes Storage Monitoring ==="
echo "Date: $(date)"
echo

echo "=== PersistentVolumes ==="
kubectl get pv -o wide

echo
echo "=== PersistentVolumeClaims ==="
kubectl get pvc -o wide

echo
echo "=== Storage Usage in Pod ==="
POD_NAME=$(kubectl get pods -l app=storage-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$POD_NAME" ]; then
    echo "Pod: $POD_NAME"
    kubectl exec $POD_NAME -- df -h /data 2>/dev/null || echo "Pod not ready or not found"
    echo "Files in /data:"
    kubectl exec $POD_NAME -- ls -la /data 2>/dev/null || echo "Cannot access /data"
else
    echo "No storage-app pods found"
fi

echo
echo "=== Recent Storage Events ==="
kubectl get events --field-selector involvedObject.kind=PersistentVolume,involvedObject.kind=PersistentVolumeClaim --sort-by='.lastTimestamp' | tail -5
EOF

# Make script executable
chmod +x monitor-storage.sh

# Run the monitoring script
./monitor-storage.sh

Task 6: Advanced Storage Scenarios
Subtask 6.1: Create Multiple PVCs

Let's create additional PVCs to understand storage allocation:

# Create additional PV
cat > additional-pv.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolume
metadata:
  name: lab-pv-2
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp/lab-data-2"
  persistentVolumeReclaimPolicy: Retain
EOF

# Apply additional PV
kubectl apply -f additional-pv.yaml

# Create second PVC
cat > additional-pvc.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: lab-pvc-2
  namespace: storage-lab
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

# Apply additional PVC
kubectl apply -f additional-pvc.yaml

# Check all PVs and PVCs
kubectl get pv,pvc

Subtask 6.2: Deploy Multi-Volume Application

Create an application that uses multiple volumes:

cat > multi-volume-app.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multi-volume-app
  namespace: storage-lab
spec:
  replicas: 1
  selector:
    matchLabels:
      app: multi-volume-app
  template:
    metadata:
      labels:
        app: multi-volume-app
    spec:
      containers:
      - name: multi-volume-container
        image: busybox:1.35
        command: ["/bin/sh"]
        args: ["-c", "while true; do echo 'Volume 1: '$(date) >> /data1/log1.txt; echo 'Volume 2: '$(date) >> /data2/log2.txt; sleep 45; done"]
        volumeMounts:
        - name: volume-1
          mountPath: /data1
        - name: volume-2
          mountPath: /data2
      volumes:
      - name: volume-1
        persistentVolumeClaim:
          claimName: lab-pvc
      - name: volume-2
        persistentVolumeClaim:
          claimName: lab-pvc-2
EOF

# Deploy multi-volume application
kubectl apply -f multi-volume-app.yaml

# Wait for pod to be ready
kubectl wait --for=condition=Ready pod -l app=multi-volume-app --timeout=60s

# Get pod name
MULTI_POD=$(kubectl get pods -l app=multi-volume-app -o jsonpath='{.items[0].metadata.name}')

# Verify both volumes are mounted
kubectl exec $MULTI_POD -- df -h | grep data
kubectl exec $MULTI_POD -- ls -la /data1
kubectl exec $MULTI_POD -- ls -la /data2

# Check logs in both volumes
sleep 60
kubectl exec $MULTI_POD -- cat /data1/log1.txt
kubectl exec $MULTI_POD -- cat /data2/log2.txt

Task 7: Troubleshooting and Best Practices
Subtask 7.1: Common Issues and Solutions

Let's explore common storage issues and their solutions:

# Create a problematic PVC (requesting more storage than available)
cat > problematic-pvc.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: large-pvc
  namespace: storage-lab
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi  # This exceeds our available PV capacity
EOF

# Apply the problematic PVC
kubectl apply -f problematic-pvc.yaml

# Check PVC status (should be Pending)
kubectl get pvc large-pvc

# Describe to see the issue
kubectl describe pvc large-pvc

# Check events to understand the problem
kubectl get events --field-selector involvedObject.name=large-pvc

echo "This PVC will remain in Pending state because no PV can satisfy the 10Gi request"

Subtask 7.2: Storage Cleanup and Best Practices

# Create cleanup script
cat > cleanup-storage.sh << 'EOF'
#!/bin/bash

echo "=== Storage Cleanup Script ==="

# Delete deployments first
echo "Deleting deployments..."
kubectl delete deployment storage-app multi-volume-app --ignore-not-found=true

# Wait for pods to terminate
echo "Waiting for pods to terminate..."
kubectl wait --for=delete pod -l app=storage-app --timeout=60s 2>/dev/null || true
kubectl wait --for=delete pod -l app=multi-volume-app --timeout=60s 2>/dev/null || true

# Delete PVCs
echo "Deleting PVCs..."
kubectl delete pvc lab-pvc lab-pvc-2 large-pvc --ignore-not-found=true

# Delete PVs
echo "Deleting PVs..."
kubectl delete pv lab-pv lab-pv-2 --ignore-not-found=true

# Delete service
echo "Deleting service..."
kubectl delete service storage-app-service --ignore-not-found=true

echo "Cleanup completed!"

# Show remaining resources
echo "Remaining storage resources:"
kubectl get pv,pvc
EOF

# Make cleanup script executable
chmod +x cleanup-storage.sh

Subtask 7.3: Storage Best Practices Summary

Create a best practices documentation:

cat > storage-best-practices.md << 'EOF'
# Kubernetes Storage Best Practices

## 1. Storage Class Selection
- Use appropriate storage classes for different workloads
- Consider performance requirements (SSD vs HDD)
- Plan for backup and disaster recovery

## 2. Resource Management
- Set appropriate storage requests and limits
- Monitor storage usage regularly
- Implement storage quotas in namespaces

## 3. Data Persistence Strategy
- Use StatefulSets for stateful applications
- Implement proper backup strategies
- Consider data replication for critical applications

## 4. Security Considerations
- Use proper RBAC for storage resources
- Encrypt sensitive data at rest
- Implement network policies for storage access

## 5. Monitoring and Alerting
- Monitor PV/PVC status regularly
- Set up alerts for storage capacity
- Track storage performance metrics

## 6. Cleanup and Maintenance
- Regularly clean up unused PVCs
- Monitor orphaned PVs
- Implement retention policies
EOF

echo "Best practices documentation created: storage-best-practices.md"

Verification and Testing
Final Verification Steps

Let's perform a comprehensive verification of everything we've learned:

# Run comprehensive verification
cat > final-verification.sh << 'EOF'
#!/bin/bash

echo "=== Final Lab Verification ==="
echo "Date: $(date)"
echo

# Check if main components exist
echo "1. Checking PersistentVolumes..."
kubectl get pv | grep -E "(lab-pv|lab-pv-2)" && echo "✓ PVs found" || echo "✗ PVs missing"

echo
echo "2. Checking PersistentVolumeClaims..."
kubectl get pvc | grep -E "(lab-pvc|lab-pvc-2)" && echo "✓ PVCs found" || echo "✗ PVCs missing"

echo
echo "3. Checking Applications..."
kubectl get deployments | grep -E "(storage-app|multi-volume-app)" && echo "✓ Applications found" || echo "✗ Applications missing"

echo
echo "4. Checking Data Persistence..."
STORAGE_POD=$(kubectl get pods -l app=storage-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$STORAGE_POD" ]; then
    if kubectl exec $STORAGE_POD -- test -f /data/timestamps.log 2>/dev/null; then
        LINE_COUNT=$(kubectl exec $STORAGE_POD -- wc -l /data/timestamps.log | awk '{print $1}')
        echo "✓ Data persistence verified - $LINE_COUNT log entries found"
    else
        echo "✗ Data persistence failed - log file not found"
    fi
else
    echo "✗ Storage app pod not found"
fi

echo
echo "5. Checking Multi-Volume Setup..."
MULTI_POD=$(kubectl get pods -l app=multi-volume-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$MULTI_POD" ]; then
    if kubectl exec $MULTI_POD -- test -f /data1/log1.txt 2>/dev/null && kubectl exec $MULTI_POD -- test -f /data2/log2.txt 2>/dev/null; then
        echo "✓ Multi-volume setup verified"
    else
        echo "✗ Multi-volume setup failed"
    fi
else
    echo "✗ Multi-volume app pod not found"
fi

echo
echo "=== Verification Complete ==="
EOF

chmod +x final-verification.sh
./final-verification.sh

Troubleshooting Common Issues
Issue 1: PVC Stuck in Pending State

Symptoms: PVC shows "Pending" status indefinitely

Diagnosis:

kubectl describe pvc <pvc-name>
kubectl get events --field-selector involvedObject.name=<pvc-name>

Common Causes and Solutions:

    No matching PV available - Create PV with matching storage class and capacity
    Access mode mismatch - Ensure PV and PVC have compatible access modes
    Storage class not found - Verify storage class exists and is spelled correctly

Issue 2: Pod Cannot Mount Volume

Symptoms: Pod stuck in "ContainerCreating" state

Diagnosis:

kubectl describe pod <pod-name>
kubectl get events --field-selector involvedObject.name=<pod-name>

Common Solutions:

    Check if PVC is bound to a PV
    Verify volume mount paths in pod specification
    Ensure node has necessary permissions for hostPath volumes

Issue 3: Data Not Persisting

Symptoms: Data disappears after pod restart

Diagnosis:

kubectl get pv,pvc
kubectl describe pv <pv-name>

Common Causes:

    Using emptyDir instead of PVC
    PV reclaim policy set to "Delete"
    Volume not properly mounted in container

Conclusion

Congratulations! You have successfully completed Lab 11: Managing Kubernetes Volumes and Persistent Storage.
What You Accomplished

In this comprehensive lab, you have:

    Created and Configured Persistent Storage
        Set up PersistentVolumes with proper specifications
        Created PersistentVolumeClaims to request storage resources
        Understood the relationship between PVs, PVCs, and storage classes

    Deployed Applications with Persistent Data
        Deployed applications that write data to persistent volumes
        Configured volume mounts and storage paths
        Implemented resource limits and best practices

    Verified Data Persistence
        Tested data persistence across pod deletions and recreations
        Verified that data survives application restarts
        Demonstrated the core value of persistent storage in Kubernetes

    Explored Advanced Storage Scenarios
        Worked with multiple volumes in a single application
        Understood storage allocation and management
        Implemented monitoring and troubleshooting procedures

    Applied Best Practices
        Learned storage security considerations
        Implemented proper cleanup procedures
        Understood performance and scalability implications

Why This Matters

Persistent storage is crucial for real-world applications because:

    Data Durability: Ensures critical application data survives container restarts and failures
    Stateful Applications: Enables deployment of databases, file systems, and other stateful workloads
    Business Continuity: Provides foundation for backup, disaster recovery, and data migration strategies
    Scalability: Allows applications to scale while maintaining data consistency
    Compliance: Meets regulatory requirements for data retention and security

Next Steps

To continue your Kubernetes journey:

    Explore Dynamic Provisioning: Learn about StorageClasses and automatic PV provisioning
    Study StatefulSets: Understand how to deploy stateful applications with ordered deployment
    Implement Backup Strategies: Learn about volume snapshots and backup solutions
    Security Hardening: Explore encryption at rest and access control for storage
    Performance Optimization: Study different storage types and their performance characteristics

Real-World Applications

The skills you've learned apply directly to:

    Database Deployments: PostgreSQL, MySQL, MongoDB in Kubernetes
    Content Management: WordPress, Drupal, and other CMS platforms
    Data Analytics: Persistent storage for data processing pipelines
    File Sharing: Network-attached storage solutions
    Backup Systems: Implementing enterprise backup and recovery solutions

You now have the foundational knowledge to manage persistent storage in production Kubernetes environments, making you well-prepared for the Kubernetes and Cloud Native Associate (KCNA) certification and real-world cloud-native application development.

Remember to clean up your lab resources when finished:

# Run the cleanup script if you want to remove all lab resources
./cleanup-storage.sh

# Or keep them for further experimentation and learning

Great job completing this hands-on lab! The persistent storage concepts you've mastered are essential for any serious Kubernetes deployment.




Lab 12: Deploying a Multi-Tier Application in Kubernetes
Objectives

By the end of this lab, you will be able to:

• Deploy a complete multi-tier application architecture in Kubernetes consisting of frontend, backend, and database components • Create and configure separate Pods for each application tier • Implement Kubernetes Services to enable secure communication between application tiers • Utilize ConfigMaps to manage application configuration data externally • Understand the principles of microservices architecture in containerized environments • Apply best practices for service discovery and inter-pod communication in Kubernetes • Troubleshoot common connectivity issues in multi-tier Kubernetes deployments
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (Pods, Services, Deployments) • Familiarity with YAML syntax and file structure • Basic knowledge of containerization concepts • Understanding of web application architecture (frontend, backend, database) • Experience with command-line interface operations • Basic networking concepts (ports, IP addresses, DNS)

Note: Al Nafi provides pre-configured Linux-based cloud machines with Kubernetes already installed. Simply click "Start Lab" to access your environment - no need to build your own VM or install Kubernetes manually.
Lab Environment Setup
Task 1: Verify Kubernetes Cluster Status
Subtask 1.1: Check Cluster Information

First, let's verify that your Kubernetes cluster is running properly.

# Check cluster information
kubectl cluster-info

# Verify node status
kubectl get nodes

# Check if all system pods are running
kubectl get pods -n kube-system

Subtask 1.2: Create Lab Namespace

Create a dedicated namespace for this lab to keep resources organized.

# Create namespace for the lab
kubectl create namespace multi-tier-app

# Set the namespace as default for this session
kubectl config set-context --current --namespace=multi-tier-app

# Verify namespace creation
kubectl get namespaces

Task 2: Deploy the Database Tier
Subtask 2.1: Create Database ConfigMap

Create a ConfigMap to store database configuration parameters.

# Create database configuration file
cat > database-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: database-config
  namespace: multi-tier-app
data:
  MYSQL_DATABASE: "webapp_db"
  MYSQL_USER: "webapp_user"
  DB_HOST: "database-service"
  DB_PORT: "3306"
EOF

# Apply the ConfigMap
kubectl apply -f database-config.yaml

# Verify ConfigMap creation
kubectl get configmaps
kubectl describe configmap database-config

Subtask 2.2: Create Database Secret

Create a Secret to store sensitive database credentials.

# Create database secret
kubectl create secret generic database-secret \
  --from-literal=MYSQL_ROOT_PASSWORD=rootpassword123 \
  --from-literal=MYSQL_PASSWORD=userpassword123

# Verify secret creation
kubectl get secrets
kubectl describe secret database-secret

Subtask 2.3: Deploy Database Pod

Create a MySQL database deployment.

# Create database deployment file
cat > database-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database-deployment
  namespace: multi-tier-app
  labels:
    app: database
    tier: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: database
      tier: database
  template:
    metadata:
      labels:
        app: database
        tier: database
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
          name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: MYSQL_ROOT_PASSWORD
        - name: MYSQL_DATABASE
          valueFrom:
            configMapKeyRef:
              name: database-config
              key: MYSQL_DATABASE
        - name: MYSQL_USER
          valueFrom:
            configMapKeyRef:
              name: database-config
              key: MYSQL_USER
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: MYSQL_PASSWORD
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-storage
        emptyDir: {}
EOF

# Apply the database deployment
kubectl apply -f database-deployment.yaml

# Check deployment status
kubectl get deployments
kubectl get pods -l tier=database

Subtask 2.4: Create Database Service

Create a Service to expose the database within the cluster.

# Create database service file
cat > database-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: database-service
  namespace: multi-tier-app
  labels:
    app: database
    tier: database
spec:
  selector:
    app: database
    tier: database
  ports:
  - port: 3306
    targetPort: 3306
    protocol: TCP
  type: ClusterIP
EOF

# Apply the database service
kubectl apply -f database-service.yaml

# Verify service creation
kubectl get services
kubectl describe service database-service

Task 3: Deploy the Backend Tier
Subtask 3.1: Create Backend ConfigMap

Create configuration for the backend application.

# Create backend configuration file
cat > backend-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
  namespace: multi-tier-app
data:
  DB_HOST: "database-service"
  DB_PORT: "3306"
  DB_NAME: "webapp_db"
  DB_USER: "webapp_user"
  APP_PORT: "5000"
  APP_ENV: "production"
EOF

# Apply the backend ConfigMap
kubectl apply -f backend-config.yaml

# Verify ConfigMap creation
kubectl describe configmap backend-config

Subtask 3.2: Deploy Backend Application

Create a simple backend application deployment.

# Create backend deployment file
cat > backend-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deployment
  namespace: multi-tier-app
  labels:
    app: backend
    tier: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
      tier: backend
  template:
    metadata:
      labels:
        app: backend
        tier: backend
    spec:
      containers:
      - name: backend-app
        image: python:3.9-slim
        ports:
        - containerPort: 5000
          name: http
        env:
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: backend-config
              key: DB_HOST
        - name: DB_PORT
          valueFrom:
            configMapKeyRef:
              name: backend-config
              key: DB_PORT
        - name: DB_NAME
          valueFrom:
            configMapKeyRef:
              name: backend-config
              key: DB_NAME
        - name: DB_USER
          valueFrom:
            configMapKeyRef:
              name: backend-config
              key: DB_USER
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: MYSQL_PASSWORD
        - name: APP_PORT
          valueFrom:
            configMapKeyRef:
              name: backend-config
              key: APP_PORT
        command: ["/bin/sh"]
        args: ["-c", "pip install flask mysql-connector-python && python -c \"
from flask import Flask, jsonify
import mysql.connector
import os
import time

app = Flask(__name__)

def get_db_connection():
    max_retries = 5
    for i in range(max_retries):
        try:
            connection = mysql.connector.connect(
                host=os.environ['DB_HOST'],
                port=int(os.environ['DB_PORT']),
                database=os.environ['DB_NAME'],
                user=os.environ['DB_USER'],
                password=os.environ['DB_PASSWORD']
            )
            return connection
        except Exception as e:
            print(f'Database connection attempt {i+1} failed: {e}')
            time.sleep(5)
    return None

@app.route('/api/health')
def health():
    return jsonify({'status': 'healthy', 'service': 'backend'})

@app.route('/api/data')
def get_data():
    try:
        conn = get_db_connection()
        if conn:
            cursor = conn.cursor()
            cursor.execute('SELECT VERSION()')
            version = cursor.fetchone()
            conn.close()
            return jsonify({'message': 'Backend connected to database', 'db_version': version[0]})
        else:
            return jsonify({'error': 'Database connection failed'}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ['APP_PORT']))
\""]
        readinessProbe:
          httpGet:
            path: /api/health
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /api/health
            port: 5000
          initialDelaySeconds: 60
          periodSeconds: 30
EOF

# Apply the backend deployment
kubectl apply -f backend-deployment.yaml

# Check deployment status
kubectl get deployments
kubectl get pods -l tier=backend

Subtask 3.3: Create Backend Service

Create a Service to expose the backend application.

# Create backend service file
cat > backend-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: multi-tier-app
  labels:
    app: backend
    tier: backend
spec:
  selector:
    app: backend
    tier: backend
  ports:
  - port: 5000
    targetPort: 5000
    protocol: TCP
    name: http
  type: ClusterIP
EOF

# Apply the backend service
kubectl apply -f backend-service.yaml

# Verify service creation
kubectl get services
kubectl describe service backend-service

Task 4: Deploy the Frontend Tier
Subtask 4.1: Create Frontend ConfigMap

Create configuration for the frontend application.

# Create frontend configuration file
cat > frontend-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
  namespace: multi-tier-app
data:
  BACKEND_URL: "http://backend-service:5000"
  APP_TITLE: "Multi-Tier Kubernetes Application"
  APP_PORT: "80"
EOF

# Apply the frontend ConfigMap
kubectl apply -f frontend-config.yaml

# Verify ConfigMap creation
kubectl describe configmap frontend-config

Subtask 4.2: Deploy Frontend Application

Create a frontend application deployment.

# Create frontend deployment file
cat > frontend-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-deployment
  namespace: multi-tier-app
  labels:
    app: frontend
    tier: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
      tier: frontend
  template:
    metadata:
      labels:
        app: frontend
        tier: frontend
    spec:
      containers:
      - name: frontend-app
        image: nginx:alpine
        ports:
        - containerPort: 80
          name: http
        env:
        - name: BACKEND_URL
          valueFrom:
            configMapKeyRef:
              name: frontend-config
              key: BACKEND_URL
        - name: APP_TITLE
          valueFrom:
            configMapKeyRef:
              name: frontend-config
              key: APP_TITLE
        volumeMounts:
        - name: frontend-content
          mountPath: /usr/share/nginx/html
        - name: nginx-config
          mountPath: /etc/nginx/conf.d
      volumes:
      - name: frontend-content
        configMap:
          name: frontend-html
      - name: nginx-config
        configMap:
          name: nginx-config
EOF

# Create HTML content ConfigMap
cat > frontend-html-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-html
  namespace: multi-tier-app
data:
  index.html: |
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Multi-Tier Kubernetes App</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            .header { text-align: center; color: #333; margin-bottom: 30px; }
            .tier { margin: 20px 0; padding: 15px; border-left: 4px solid #007acc; background: #f9f9f9; }
            .button { background: #007acc; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; margin: 5px; }
            .button:hover { background: #005a99; }
            .result { margin: 10px 0; padding: 10px; background: #e8f4f8; border-radius: 4px; }
            .error { background: #ffe6e6; color: #cc0000; }
            .success { background: #e6ffe6; color: #006600; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Multi-Tier Kubernetes Application</h1>
                <p>Frontend → Backend → Database Communication Demo</p>
            </div>
            
            <div class="tier">
                <h3>🌐 Frontend Tier (Nginx)</h3>
                <p>This HTML page is served by an Nginx container running in the frontend pod.</p>
                <p><strong>Status:</strong> <span style="color: green;">Active</span></p>
            </div>
            
            <div class="tier">
                <h3>⚙️ Backend Tier (Python Flask)</h3>
                <p>Click the buttons below to test communication with the backend service.</p>
                <button class="button" onclick="testBackendHealth()">Test Backend Health</button>
                <button class="button" onclick="testBackendData()">Test Database Connection</button>
                <div id="backend-result" class="result" style="display: none;"></div>
            </div>
            
            <div class="tier">
                <h3>🗄️ Database Tier (MySQL)</h3>
                <p>MySQL database running in a separate pod, accessible via backend service.</p>
                <p><strong>Connection:</strong> Via backend service only (not directly accessible)</p>
            </div>
            
            <div class="tier">
                <h3>📋 Architecture Overview</h3>
                <ul>
                    <li><strong>Frontend:</strong> Nginx serving static content (this page)</li>
                    <li><strong>Backend:</strong> Python Flask API with health and data endpoints</li>
                    <li><strong>Database:</strong> MySQL database with persistent storage</li>
                    <li><strong>Communication:</strong> Services enable inter-pod communication</li>
                    <li><strong>Configuration:</strong> ConfigMaps store application settings</li>
                </ul>
            </div>
        </div>
        
        <script>
            async function testBackendHealth() {
                const resultDiv = document.getElementById('backend-result');
                resultDiv.style.display = 'block';
                resultDiv.innerHTML = 'Testing backend health...';
                resultDiv.className = 'result';
                
                try {
                    const response = await fetch('/api/health');
                    const data = await response.json();
                    resultDiv.innerHTML = `✅ Backend Health: ${JSON.stringify(data, null, 2)}`;
                    resultDiv.className = 'result success';
                } catch (error) {
                    resultDiv.innerHTML = `❌ Backend Health Check Failed: ${error.message}`;
                    resultDiv.className = 'result error';
                }
            }
            
            async function testBackendData() {
                const resultDiv = document.getElementById('backend-result');
                resultDiv.style.display = 'block';
                resultDiv.innerHTML = 'Testing database connection...';
                resultDiv.className = 'result';
                
                try {
                    const response = await fetch('/api/data');
                    const data = await response.json();
                    resultDiv.innerHTML = `✅ Database Connection: ${JSON.stringify(data, null, 2)}`;
                    resultDiv.className = 'result success';
                } catch (error) {
                    resultDiv.innerHTML = `❌ Database Connection Failed: ${error.message}`;
                    resultDiv.className = 'result error';
                }
            }
        </script>
    </body>
    </html>
EOF

# Create Nginx configuration ConfigMap
cat > nginx-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: multi-tier-app
data:
  default.conf: |
    server {
        listen 80;
        server_name localhost;
        
        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
        
        location /api/ {
            proxy_pass http://backend-service:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
EOF

# Apply all frontend configurations
kubectl apply -f frontend-html-config.yaml
kubectl apply -f nginx-config.yaml
kubectl apply -f frontend-deployment.yaml

# Check deployment status
kubectl get deployments
kubectl get pods -l tier=frontend

Subtask 4.3: Create Frontend Service

Create a Service to expose the frontend application.

# Create frontend service file
cat > frontend-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: multi-tier-app
  labels:
    app: frontend
    tier: frontend
spec:
  selector:
    app: frontend
    tier: frontend
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  type: NodePort
EOF

# Apply the frontend service
kubectl apply -f frontend-service.yaml

# Get service details including NodePort
kubectl get services
kubectl describe service frontend-service

Task 5: Verify Multi-Tier Application Communication
Subtask 5.1: Check All Deployments and Services

Verify that all components are running correctly.

# Check all deployments
kubectl get deployments

# Check all pods
kubectl get pods

# Check all services
kubectl get services

# Check all configmaps
kubectl get configmaps

# Check all secrets
kubectl get secrets

Subtask 5.2: Test Inter-Service Communication

Test communication between the tiers.

# Get a frontend pod name
FRONTEND_POD=$(kubectl get pods -l tier=frontend -o jsonpath='{.items[0].metadata.name}')

# Test frontend to backend communication
kubectl exec -it $FRONTEND_POD -- curl -s http://backend-service:5000/api/health

# Test backend to database communication
BACKEND_POD=$(kubectl get pods -l tier=backend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $BACKEND_POD -- curl -s http://localhost:5000/api/data

# Check database connectivity from backend
kubectl exec -it $BACKEND_POD -- curl -s http://localhost:5000/api/health

Subtask 5.3: Access the Application

Get the external access information for your application.

# Get node IP and frontend service port
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
if [ -z "$NODE_IP" ]; then
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
fi

FRONTEND_PORT=$(kubectl get service frontend-service -o jsonpath='{.spec.ports[0].nodePort}')

echo "Application URL: http://$NODE_IP:$FRONTEND_PORT"
echo "Backend Health Check: http://$NODE_IP:$FRONTEND_PORT/api/health"
echo "Backend Data Endpoint: http://$NODE_IP:$FRONTEND_PORT/api/data"

Task 6: Monitor and Troubleshoot
Subtask 6.1: Monitor Application Logs

Check logs from each tier to ensure proper operation.

# Check frontend logs
kubectl logs -l tier=frontend --tail=20

# Check backend logs
kubectl logs -l tier=backend --tail=20

# Check database logs
kubectl logs -l tier=database --tail=20

Subtask 6.2: Verify ConfigMap Usage

Confirm that ConfigMaps are being used correctly by the applications.

# Check environment variables in backend pod
BACKEND_POD=$(kubectl get pods -l tier=backend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $BACKEND_POD -- env | grep -E "(DB_|APP_)"

# Check ConfigMap data
kubectl get configmap database-config -o yaml
kubectl get configmap backend-config -o yaml
kubectl get configmap frontend-config -o yaml

Subtask 6.3: Test Application Scaling

Test the scalability of your multi-tier application.

# Scale frontend deployment
kubectl scale deployment frontend-deployment --replicas=5

# Scale backend deployment
kubectl scale deployment backend-deployment --replicas=3

# Check scaling results
kubectl get deployments
kubectl get pods

# Scale back to original size
kubectl scale deployment frontend-deployment --replicas=3
kubectl scale deployment backend-deployment --replicas=2

Troubleshooting Common Issues
Database Connection Issues

If the backend cannot connect to the database:

# Check database pod status
kubectl describe pod -l tier=database

# Verify database service endpoints
kubectl get endpoints database-service

# Test database connectivity from backend pod
BACKEND_POD=$(kubectl get pods -l tier=backend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $BACKEND_POD -- nc -zv database-service 3306

Service Discovery Problems

If services cannot find each other:

# Check DNS resolution
kubectl exec -it $BACKEND_POD -- nslookup database-service
kubectl exec -it $FRONTEND_POD -- nslookup backend-service

# Verify service selectors match pod labels
kubectl describe service database-service
kubectl describe service backend-service

ConfigMap Issues

If configuration is not being applied:

# Verify ConfigMap mounting
kubectl describe pod $BACKEND_POD | grep -A 10 "Mounts:"

# Check environment variables
kubectl exec -it $BACKEND_POD -- printenv | grep DB_

Lab Cleanup

When you're finished with the lab, clean up the resources:

# Delete all resources in the namespace
kubectl delete namespace multi-tier-app

# Verify cleanup
kubectl get namespaces

Conclusion

Congratulations! You have successfully deployed a complete multi-tier application in Kubernetes. In this lab, you accomplished the following:

Key Achievements:

• Multi-Tier Architecture: Deployed a three-tier application with separate frontend (Nginx), backend (Python Flask), and database (MySQL) components, demonstrating proper separation of concerns in microservices architecture.

• Pod Management: Created and managed multiple Pods across different tiers, understanding how containerized applications run in Kubernetes environments.

• Service Communication: Implemented Kubernetes Services to enable secure and reliable communication between application tiers, showcasing service discovery and internal networking.

• Configuration Management: Utilized ConfigMaps to externalize application configuration, making your applications more flexible and environment-agnostic.

• Security Best Practices: Implemented Secrets for sensitive data like database passwords, separating configuration from sensitive information.

• Application Scaling: Demonstrated horizontal scaling capabilities by running multiple replicas of frontend and backend services.

Why This Matters:

This lab represents real-world application deployment patterns used by organizations worldwide. Multi-tier architectures are fundamental to modern cloud-native applications because they provide:

    Scalability: Each tier can be scaled independently based on demand
    Maintainability: Changes to one tier don't affect others
    Reliability: Failure in one component doesn't bring down the entire application
    Security: Database access is restricted and controlled through the backend tier

The skills you've developed here are directly applicable to the Kubernetes and Cloud Native Associate (KCNA) certification and are essential for anyone working with containerized applications in production environments. You now understand how to deploy, configure, and manage complex applications in Kubernetes, which is a critical skill for modern DevOps and cloud engineering roles.

Next Steps:

Consider exploring advanced topics like persistent volumes for database storage, ingress controllers for external access, and monitoring solutions to further enhance your Kubernetes expertise.




Lab 13: Using ConfigMaps and Secrets for Application Configuration
Objectives

By the end of this lab, you will be able to:

• Create and manage ConfigMaps to store non-sensitive configuration data • Create and manage Secrets to store sensitive information securely • Pass environment variables to Pods using ConfigMaps and Secrets • Mount ConfigMaps and Secrets as files in Pod containers • Understand the differences between ConfigMaps and Secrets • Apply best practices for application configuration management in Kubernetes
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (Pods, Deployments) • Familiarity with YAML syntax • Basic command-line interface experience • Understanding of environment variables and file systems
Ready-to-Use Cloud Machines

Al Nafi provides Linux-based cloud machines with Kubernetes pre-installed. Simply click Start Lab to access your environment. No need to build your own VM or install additional software.

Your lab environment includes: • Kubernetes cluster (minikube or similar) • kubectl command-line tool • Text editor (nano/vim) • All necessary permissions to create resources
Lab Tasks
Task 1: Create a ConfigMap to Pass Environment Variables to a Pod
Subtask 1.1: Create a ConfigMap Using kubectl

First, let's create a ConfigMap that contains application configuration data.

    Create a ConfigMap with literal values:

kubectl create configmap app-config \
  --from-literal=DATABASE_HOST=mysql-service \
  --from-literal=DATABASE_PORT=3306 \
  --from-literal=APP_ENV=production \
  --from-literal=LOG_LEVEL=info

    Verify the ConfigMap was created:

kubectl get configmaps

    View the ConfigMap details:

kubectl describe configmap app-config

Subtask 1.2: Create a ConfigMap from a File

    Create a configuration file:

cat > app.properties << EOF
database.host=mysql-service
database.port=3306
app.environment=production
log.level=info
cache.enabled=true
cache.ttl=300
EOF

    Create a ConfigMap from the file:

kubectl create configmap app-properties --from-file=app.properties

    Verify the file-based ConfigMap:

kubectl get configmap app-properties -o yaml

Subtask 1.3: Create a Pod Using ConfigMap as Environment Variables

    Create a Pod manifest that uses the ConfigMap:

cat > pod-with-configmap.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: app-pod-env
  labels:
    app: demo-app
spec:
  containers:
  - name: app-container
    image: nginx:1.21
    envFrom:
    - configMapRef:
        name: app-config
    env:
    - name: CUSTOM_MESSAGE
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: APP_ENV
  restartPolicy: Never
EOF

    Apply the Pod manifest:

kubectl apply -f pod-with-configmap.yaml

    Verify the Pod is running:

kubectl get pods

    Check the environment variables inside the Pod:

kubectl exec app-pod-env -- env | grep -E "(DATABASE|APP|LOG)"

Task 2: Create a Secret to Store Sensitive Information
Subtask 2.1: Create a Secret for Database Credentials

    Create a Secret using kubectl:

kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=supersecret123 \
  --from-literal=root-password=rootsecret456

    Verify the Secret was created:

kubectl get secrets

    View the Secret details (note that values are base64 encoded):

kubectl describe secret db-credentials

    View the Secret in YAML format:

kubectl get secret db-credentials -o yaml

Subtask 2.2: Create a Secret from Files

    Create credential files:

echo -n 'admin' > username.txt
echo -n 'supersecret123' > password.txt

    Create a Secret from files:

kubectl create secret generic file-credentials --from-file=username.txt --from-file=password.txt

    Clean up the credential files:

rm username.txt password.txt

Subtask 2.3: Create a Pod Using Secrets as Environment Variables

    Create a Pod manifest that uses the Secret:

cat > pod-with-secret.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: app-pod-secret
  labels:
    app: demo-app
spec:
  containers:
  - name: app-container
    image: nginx:1.21
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: password
    - name: DB_ROOT_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: root-password
  restartPolicy: Never
EOF

    Apply the Pod manifest:

kubectl apply -f pod-with-secret.yaml

    Verify the environment variables (be careful with sensitive data):

kubectl exec app-pod-secret -- env | grep DB_

Task 3: Mount Both ConfigMaps and Secrets into Pods as Files
Subtask 3.1: Create a Pod with ConfigMap and Secret as Volume Mounts

    Create a comprehensive Pod manifest:

cat > pod-with-volumes.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: app-pod-volumes
  labels:
    app: demo-app
spec:
  containers:
  - name: app-container
    image: nginx:1.21
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
      readOnly: true
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
    - name: properties-volume
      mountPath: /etc/properties
      readOnly: true
    env:
    - name: CONFIG_PATH
      value: "/etc/config"
    - name: SECRETS_PATH
      value: "/etc/secrets"
  volumes:
  - name: config-volume
    configMap:
      name: app-config
  - name: secret-volume
    secret:
      secretName: db-credentials
      defaultMode: 0400
  - name: properties-volume
    configMap:
      name: app-properties
  restartPolicy: Never
EOF

    Apply the Pod manifest:

kubectl apply -f pod-with-volumes.yaml

    Wait for the Pod to be ready:

kubectl wait --for=condition=Ready pod/app-pod-volumes --timeout=60s

Subtask 3.2: Verify Mounted Files

    Check the ConfigMap files:

kubectl exec app-pod-volumes -- ls -la /etc/config/

    View ConfigMap content:

kubectl exec app-pod-volumes -- cat /etc/config/DATABASE_HOST
kubectl exec app-pod-volumes -- cat /etc/config/APP_ENV

    Check the Secret files (note the restricted permissions):

kubectl exec app-pod-volumes -- ls -la /etc/secrets/

    View Secret content:

kubectl exec app-pod-volumes -- cat /etc/secrets/username

    Check the properties file:

kubectl exec app-pod-volumes -- ls -la /etc/properties/
kubectl exec app-pod-volumes -- cat /etc/properties/app.properties

Subtask 3.3: Create a Deployment Using ConfigMaps and Secrets

    Create a Deployment manifest:

cat > deployment-with-config.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-deployment
  labels:
    app: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-container
        image: nginx:1.21
        ports:
        - containerPort: 80
        envFrom:
        - configMapRef:
            name: app-config
        env:
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        volumeMounts:
        - name: config-volume
          mountPath: /usr/share/nginx/html/config
          readOnly: true
        - name: secret-volume
          mountPath: /usr/share/nginx/html/secrets
          readOnly: true
      volumes:
      - name: config-volume
        configMap:
          name: app-config
      - name: secret-volume
        secret:
          secretName: db-credentials
          defaultMode: 0400
EOF

    Apply the Deployment:

kubectl apply -f deployment-with-config.yaml

    Verify the Deployment:

kubectl get deployments
kubectl get pods -l app=web-app

    Test configuration in one of the Deployment pods:

POD_NAME=$(kubectl get pods -l app=web-app -o jsonpath='{.items[0].metadata.name}')
kubectl exec $POD_NAME -- env | grep -E "(DATABASE|APP|LOG|DB_)"

Task 4: Update ConfigMaps and Secrets
Subtask 4.1: Update a ConfigMap

    Update the ConfigMap:

kubectl patch configmap app-config --patch '{"data":{"LOG_LEVEL":"debug","NEW_FEATURE":"enabled"}}'

    Verify the update:

kubectl describe configmap app-config

    Check if mounted files are updated (may take a few moments):

kubectl exec app-pod-volumes -- cat /etc/config/LOG_LEVEL
kubectl exec app-pod-volumes -- cat /etc/config/NEW_FEATURE

Subtask 4.2: Update a Secret

    Update the Secret:

kubectl patch secret db-credentials --patch '{"data":{"api-key":"'$(echo -n 'new-api-key-123' | base64)'"}}'

    Verify the Secret update:

kubectl describe secret db-credentials

Task 5: Clean Up and Best Practices
Subtask 5.1: View All Created Resources

    List all ConfigMaps:

kubectl get configmaps

    List all Secrets:

kubectl get secrets

    List all Pods:

kubectl get pods

    List all Deployments:

kubectl get deployments

Subtask 5.2: Clean Up Resources

    Delete the Pods:

kubectl delete pod app-pod-env app-pod-secret app-pod-volumes

    Delete the Deployment:

kubectl delete deployment web-app-deployment

    Delete ConfigMaps:

kubectl delete configmap app-config app-properties

    Delete Secrets:

kubectl delete secret db-credentials file-credentials

    Clean up local files:

rm -f pod-with-configmap.yaml pod-with-secret.yaml pod-with-volumes.yaml deployment-with-config.yaml app.properties

Key Concepts and Best Practices
ConfigMaps vs Secrets

ConfigMaps are used for: • Non-sensitive configuration data • Application settings • Configuration files • Environment-specific values

Secrets are used for: • Sensitive information (passwords, tokens, keys) • TLS certificates • Docker registry credentials • API keys
Security Considerations

• Secrets are base64 encoded, not encrypted by default • Use RBAC to control access to Secrets • Consider using external secret management systems for production • Set appropriate file permissions when mounting Secrets • Avoid logging Secret values
Performance Tips

• ConfigMaps and Secrets have size limits (1MB) • Volume mounts are eventually consistent • Environment variables are set at container startup • Use subPath for mounting specific files
Troubleshooting Common Issues
Issue 1: Pod Not Starting

Problem: Pod stuck in Pending or Error state

Solution:

kubectl describe pod <pod-name>
kubectl logs <pod-name>

Issue 2: ConfigMap/Secret Not Found

Problem: Error mounting ConfigMap or Secret

Solution:

kubectl get configmaps
kubectl get secrets
# Ensure the referenced ConfigMap/Secret exists

Issue 3: File Not Updated After ConfigMap Change

Problem: Mounted files don't reflect ConfigMap updates

Solution: • Wait up to 60 seconds for kubelet sync • Restart the Pod if immediate update is needed • Environment variables require Pod restart
Conclusion

In this lab, you have successfully:

• Created ConfigMaps using both literal values and files to store non-sensitive configuration data • Created Secrets to securely store sensitive information like database credentials • Used ConfigMaps and Secrets as environment variables in Pods to configure applications • Mounted ConfigMaps and Secrets as files in containers for file-based configuration • Applied configuration to Deployments for scalable applications • Updated ConfigMaps and Secrets and observed how changes propagate to running containers

Why This Matters:

Configuration management is crucial for modern applications because it: • Separates configuration from code, making applications more portable • Enables environment-specific deployments without code changes • Improves security by keeping sensitive data separate from application code • Facilitates easier updates and configuration changes without rebuilding images • Supports the twelve-factor app methodology for cloud-native applications

Understanding ConfigMaps and Secrets is essential for the Kubernetes and Cloud Native Associate (KCNA) certification and real-world Kubernetes deployments. These skills enable you to build secure, configurable, and maintainable applications in Kubernetes environments.




Lab 14: Advanced HTTP/S Routing with Ingress
Objectives

By the end of this lab, you will be able to:

• Deploy multiple applications in a Kubernetes cluster • Configure Ingress controllers for HTTP/S traffic management • Implement path-based routing using Ingress resources • Secure applications with TLS certificates and SSL termination • Verify and troubleshoot Ingress routing rules • Understand the relationship between Services, Ingress, and external traffic
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (Pods, Services, Deployments) • Familiarity with YAML configuration files • Knowledge of HTTP/HTTPS protocols and routing concepts • Basic command-line interface experience • Understanding of DNS and domain name concepts
Ready-to-Use Cloud Machines

Al Nafi provides pre-configured Linux-based cloud machines with Kubernetes already installed and configured. Simply click Start Lab to access your environment. No need to build your own VM or install Kubernetes from scratch.

Your lab environment includes: • Ubuntu 20.04 LTS with kubectl pre-installed • Minikube cluster ready for use • NGINX Ingress Controller available for installation • All necessary tools and dependencies
Lab Tasks
Task 1: Environment Setup and Preparation
Subtask 1.1: Verify Kubernetes Cluster Status

First, let's ensure your Kubernetes cluster is running properly.

# Check cluster status
kubectl cluster-info

# Verify nodes are ready
kubectl get nodes

# Check if minikube is running
minikube status

If minikube is not running, start it:

# Start minikube cluster
minikube start --driver=docker

# Enable ingress addon
minikube addons enable ingress

Subtask 1.2: Verify Ingress Controller Installation

Check if the NGINX Ingress Controller is installed and running:

# Check ingress controller pods
kubectl get pods -n ingress-nginx

# Verify ingress controller service
kubectl get svc -n ingress-nginx

If the ingress controller is not installed, enable it:

# Enable ingress addon for minikube
minikube addons enable ingress

# Wait for ingress controller to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

Task 2: Deploy Two Sample Applications
Subtask 2.1: Create Application Namespaces

Create separate namespaces for better organization:

# Create namespace for applications
kubectl create namespace web-apps

Subtask 2.2: Deploy First Application (App1)

Create the first application deployment and service:

# Create app1-deployment.yaml
cat > app1-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1-deployment
  namespace: web-apps
  labels:
    app: app1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app1
  template:
    metadata:
      labels:
        app: app1
    spec:
      containers:
      - name: app1
        image: nginx:1.21
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html-volume
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-volume
        configMap:
          name: app1-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app1-html
  namespace: web-apps
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <title>Application 1</title>
        <style>
            body { font-family: Arial, sans-serif; background-color: #e3f2fd; text-align: center; padding: 50px; }
            h1 { color: #1976d2; }
        </style>
    </head>
    <body>
        <h1>Welcome to Application 1</h1>
        <p>This is the first application served via Ingress path-based routing.</p>
        <p>Path: /app1</p>
    </body>
    </html>
---
apiVersion: v1
kind: Service
metadata:
  name: app1-service
  namespace: web-apps
spec:
  selector:
    app: app1
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

# Apply the configuration
kubectl apply -f app1-deployment.yaml

Subtask 2.3: Deploy Second Application (App2)

Create the second application deployment and service:

# Create app2-deployment.yaml
cat > app2-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app2-deployment
  namespace: web-apps
  labels:
    app: app2
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app2
  template:
    metadata:
      labels:
        app: app2
    spec:
      containers:
      - name: app2
        image: nginx:1.21
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html-volume
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-volume
        configMap:
          name: app2-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app2-html
  namespace: web-apps
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <title>Application 2</title>
        <style>
            body { font-family: Arial, sans-serif; background-color: #f3e5f5; text-align: center; padding: 50px; }
            h1 { color: #7b1fa2; }
        </style>
    </head>
    <body>
        <h1>Welcome to Application 2</h1>
        <p>This is the second application served via Ingress path-based routing.</p>
        <p>Path: /app2</p>
    </body>
    </html>
---
apiVersion: v1
kind: Service
metadata:
  name: app2-service
  namespace: web-apps
spec:
  selector:
    app: app2
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

# Apply the configuration
kubectl apply -f app2-deployment.yaml

Subtask 2.4: Verify Application Deployments

Check that both applications are running correctly:

# Check deployments
kubectl get deployments -n web-apps

# Check pods
kubectl get pods -n web-apps

# Check services
kubectl get svc -n web-apps

# Verify pods are ready
kubectl wait --for=condition=ready pod -l app=app1 -n web-apps --timeout=60s
kubectl wait --for=condition=ready pod -l app=app2 -n web-apps --timeout=60s

Task 3: Configure Ingress for Path-Based Routing
Subtask 3.1: Create Basic Ingress Resource

Create an Ingress resource that routes traffic based on URL paths:

# Create ingress-basic.yaml
cat > ingress-basic.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-apps-ingress
  namespace: web-apps
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  ingressClassName: nginx
  rules:
  - host: myapps.local
    http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
EOF

# Apply the Ingress configuration
kubectl apply -f ingress-basic.yaml

Subtask 3.2: Verify Ingress Configuration

Check the Ingress resource and get the external IP:

# Check ingress resource
kubectl get ingress -n web-apps

# Get detailed ingress information
kubectl describe ingress web-apps-ingress -n web-apps

# Get minikube IP for testing
minikube ip

Subtask 3.3: Configure Local DNS Resolution

Add entries to your local hosts file for testing:

# Get minikube IP
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"

# Add entry to hosts file (requires sudo)
echo "$MINIKUBE_IP myapps.local" | sudo tee -a /etc/hosts

# Verify the entry was added
grep myapps.local /etc/hosts

Subtask 3.4: Test Path-Based Routing

Test the routing configuration using curl:

# Test default path (should route to app1)
curl -H "Host: myapps.local" http://$(minikube ip)/

# Test app1 path
curl -H "Host: myapps.local" http://$(minikube ip)/app1

# Test app2 path
curl -H "Host: myapps.local" http://$(minikube ip)/app2

# Alternative testing using the domain name
curl http://myapps.local/app1
curl http://myapps.local/app2

Task 4: Secure Ingress with TLS Certificate
Subtask 4.1: Generate Self-Signed TLS Certificate

Create a self-signed certificate for testing purposes:

# Create private key
openssl genrsa -out tls.key 2048

# Create certificate signing request
openssl req -new -key tls.key -out tls.csr -subj "/CN=myapps.local/O=myapps.local"

# Generate self-signed certificate
openssl x509 -req -days 365 -in tls.csr -signkey tls.key -out tls.crt

# Verify certificate
openssl x509 -in tls.crt -text -noout | head -20

Subtask 4.2: Create Kubernetes TLS Secret

Store the certificate and key in a Kubernetes secret:

# Create TLS secret
kubectl create secret tls myapps-tls-secret \
  --cert=tls.crt \
  --key=tls.key \
  -n web-apps

# Verify secret creation
kubectl get secrets -n web-apps
kubectl describe secret myapps-tls-secret -n web-apps

Subtask 4.3: Update Ingress with TLS Configuration

Modify the Ingress resource to include TLS configuration:

# Create ingress-tls.yaml
cat > ingress-tls.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-apps-ingress
  namespace: web-apps
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - myapps.local
    secretName: myapps-tls-secret
  rules:
  - host: myapps.local
    http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
EOF

# Apply the updated Ingress configuration
kubectl apply -f ingress-tls.yaml

Subtask 4.4: Verify TLS Configuration

Check that the TLS configuration is working:

# Check ingress with TLS
kubectl describe ingress web-apps-ingress -n web-apps

# Wait for ingress to be ready
sleep 30

# Test HTTPS connection (ignore certificate warnings for self-signed cert)
curl -k https://myapps.local/app1
curl -k https://myapps.local/app2

# Test HTTP redirect to HTTPS
curl -v http://myapps.local/app1

Task 5: Advanced Routing and Verification
Subtask 5.1: Add Header-Based Routing

Create an advanced Ingress configuration with additional routing rules:

# Create ingress-advanced.yaml
cat > ingress-advanced.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-apps-ingress-advanced
  namespace: web-apps
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "X-Served-By: Kubernetes-Ingress";
      more_set_headers "X-App-Version: 1.0";
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - myapps.local
    - api.myapps.local
    secretName: myapps-tls-secret
  rules:
  - host: myapps.local
    http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
  - host: api.myapps.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
EOF

# Apply the advanced configuration
kubectl apply -f ingress-advanced.yaml

Subtask 5.2: Update DNS Configuration

Add the new subdomain to your hosts file:

# Add API subdomain
MINIKUBE_IP=$(minikube ip)
echo "$MINIKUBE_IP api.myapps.local" | sudo tee -a /etc/hosts

# Verify both entries
grep myapps.local /etc/hosts

Subtask 5.3: Test Advanced Routing

Test the advanced routing configuration:

# Test main domain paths
curl -k -I https://myapps.local/app1
curl -k -I https://myapps.local/app2

# Test API subdomain
curl -k -I https://api.myapps.local/

# Check custom headers
curl -k -I https://myapps.local/app1 | grep "X-Served-By"
curl -k -I https://myapps.local/app1 | grep "X-App-Version"

Subtask 5.4: Monitor Ingress Logs

Check the Ingress controller logs to verify traffic routing:

# Get ingress controller pod name
INGRESS_POD=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller -o jsonpath='{.items[0].metadata.name}')

# View ingress controller logs
kubectl logs -n ingress-nginx $INGRESS_POD --tail=50

# Follow logs in real-time (run in separate terminal)
kubectl logs -n ingress-nginx $INGRESS_POD -f

Task 6: Verification and Testing
Subtask 6.1: Comprehensive Testing Script

Create a comprehensive testing script:

# Create test-ingress.sh
cat > test-ingress.sh << 'EOF'
#!/bin/bash

echo "=== Ingress Testing Script ==="
echo "Testing HTTP/HTTPS routing and SSL termination"
echo

# Test HTTP redirect to HTTPS
echo "1. Testing HTTP to HTTPS redirect:"
curl -s -o /dev/null -w "HTTP Status: %{http_code}, Redirect URL: %{redirect_url}\n" http://myapps.local/app1
echo

# Test HTTPS app1
echo "2. Testing HTTPS app1 path:"
curl -k -s https://myapps.local/app1 | grep -o "<title>.*</title>"
echo

# Test HTTPS app2
echo "3. Testing HTTPS app2 path:"
curl -k -s https://myapps.local/app2 | grep -o "<title>.*</title>"
echo

# Test API subdomain
echo "4. Testing API subdomain:"
curl -k -s https://api.myapps.local/ | grep -o "<title>.*</title>"
echo

# Test SSL certificate
echo "5. Testing SSL certificate:"
echo | openssl s_client -servername myapps.local -connect $(minikube ip):443 2>/dev/null | openssl x509 -noout -subject
echo

# Test custom headers
echo "6. Testing custom headers:"
curl -k -s -I https://myapps.local/app1 | grep "X-Served-By"
curl -k -s -I https://myapps.local/app1 | grep "X-App-Version"
echo

echo "=== Testing Complete ==="
EOF

# Make script executable
chmod +x test-ingress.sh

# Run the test script
./test-ingress.sh

Subtask 6.2: Verify Ingress Resources

Check all Ingress-related resources:

# List all ingress resources
kubectl get ingress --all-namespaces

# Check ingress class
kubectl get ingressclass

# Verify services are accessible
kubectl get endpoints -n web-apps

# Check pod status
kubectl get pods -n web-apps -o wide

Subtask 6.3: Performance and Load Testing

Perform basic load testing to verify routing performance:

# Install apache2-utils for ab command (if not available)
sudo apt-get update && sudo apt-get install -y apache2-utils

# Perform load test on app1
ab -n 100 -c 10 -k https://myapps.local/app1

# Perform load test on app2
ab -n 100 -c 10 -k https://myapps.local/app2

Troubleshooting Tips
Common Issues and Solutions

Issue 1: Ingress Controller Not Ready

# Check ingress controller status
kubectl get pods -n ingress-nginx
kubectl describe pod -n ingress-nginx -l app.kubernetes.io/component=controller

# Restart ingress controller if needed
kubectl delete pod -n ingress-nginx -l app.kubernetes.io/component=controller

Issue 2: DNS Resolution Problems

# Verify hosts file entries
cat /etc/hosts | grep myapps

# Test DNS resolution
nslookup myapps.local
ping myapps.local

Issue 3: Certificate Issues

# Check TLS secret
kubectl describe secret myapps-tls-secret -n web-apps

# Verify certificate validity
openssl x509 -in tls.crt -noout -dates

Issue 4: Service Not Accessible

# Check service endpoints
kubectl get endpoints -n web-apps

# Test service directly
kubectl port-forward -n web-apps svc/app1-service 8080:80
curl http://localhost:8080

Cleanup

When you're finished with the lab, clean up the resources:

# Delete ingress resources
kubectl delete ingress --all -n web-apps

# Delete applications
kubectl delete -f app1-deployment.yaml
kubectl delete -f app2-deployment.yaml

# Delete TLS secret
kubectl delete secret myapps-tls-secret -n web-apps

# Delete namespace
kubectl delete namespace web-apps

# Remove hosts file entries
sudo sed -i '/myapps.local/d' /etc/hosts

# Clean up certificate files
rm -f tls.key tls.csr tls.crt

# Clean up YAML files
rm -f *.yaml test-ingress.sh

Conclusion

Congratulations! You have successfully completed Lab 14: Advanced HTTP/S Routing with Ingress. In this lab, you accomplished several important tasks:

Key Achievements:

• Deployed Multiple Applications: You created two distinct web applications with different visual themes and deployed them in a Kubernetes cluster using Deployments and Services.

• Configured Path-Based Routing: You implemented sophisticated HTTP routing rules using Kubernetes Ingress resources, allowing different applications to be accessed via different URL paths (/app1, /app2).

• Implemented SSL/TLS Security: You generated self-signed certificates, created Kubernetes TLS secrets, and configured HTTPS termination at the Ingress level, ensuring secure communication.

• Advanced Routing Features: You explored advanced Ingress features including custom headers, multiple hostnames, and automatic HTTP-to-HTTPS redirects.

• Verification and Testing: You performed comprehensive testing using various tools and methods to verify that routing rules work correctly and SSL termination functions properly.

Why This Matters:

Ingress controllers are crucial components in modern Kubernetes deployments because they:

    Provide External Access: Enable external users to access applications running inside the cluster
    Centralize Traffic Management: Offer a single point of control for HTTP/HTTPS traffic routing
    Enable SSL Termination: Handle certificate management and encryption/decryption at the edge
    Support Advanced Features: Provide load balancing, path rewriting, and custom headers
    Reduce Complexity: Eliminate the need for multiple LoadBalancer services

Real-World Applications:

The skills you've learned are directly applicable to:

    Microservices Architecture: Routing traffic to different services based on URL paths
    Multi-Tenant Applications: Serving different customers via different hostnames
    API Gateway Patterns: Managing API traffic and implementing security policies
    Blue-Green Deployments: Routing traffic between different application versions
    Development Environments: Providing easy access to multiple applications in development clusters

This lab has provided you with practical experience in managing HTTP/HTTPS traffic in Kubernetes environments, a critical skill for the Kubernetes and Cloud Native Associate (KCNA) certification and real-world container orchestration scenarios.




Lab 15: Implementing Autoscaling in Kubernetes
Objectives

By the end of this lab, you will be able to:

• Understand the concepts of Horizontal Pod Autoscaler (HPA) and Vertical Pod Autoscaler (VPA) • Configure and deploy a Horizontal Pod Autoscaler for automatic scaling based on CPU utilization • Generate synthetic traffic to trigger autoscaling behavior • Monitor and observe scaling events in real-time • Implement Vertical Pod Autoscaler to automatically adjust resource requests and limits • Analyze the differences between horizontal and vertical scaling strategies • Troubleshoot common autoscaling issues and optimize performance
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (Pods, Deployments, Services) • Familiarity with kubectl command-line tool • Knowledge of YAML configuration files • Understanding of CPU and memory resource concepts • Basic Linux command-line skills
Ready-to-Use Cloud Machines

Al Nafi provides pre-configured Linux-based cloud machines with Kubernetes cluster already set up. Simply click Start Lab to access your environment. No need to build your own VM or install Kubernetes from scratch.

Your lab environment includes: • A running Kubernetes cluster with multiple nodes • kubectl configured and ready to use • Metrics server pre-installed for resource monitoring • All necessary tools for generating load and monitoring
Task 1: Configure Horizontal Pod Autoscaler (HPA)
Subtask 1.1: Create a Sample Application Deployment

First, we'll create a simple web application that we can scale automatically.

    Create a deployment manifest file:

cat > php-apache-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
  labels:
    app: php-apache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: php-apache
  template:
    metadata:
      labels:
        app: php-apache
    spec:
      containers:
      - name: php-apache
        image: k8s.gcr.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 500m
            memory: 128Mi
          requests:
            cpu: 200m
            memory: 64Mi
---
apiVersion: v1
kind: Service
metadata:
  name: php-apache
  labels:
    app: php-apache
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: php-apache
  type: ClusterIP
EOF

    Apply the deployment:

kubectl apply -f php-apache-deployment.yaml

    Verify the deployment is running:

kubectl get deployments
kubectl get pods -l app=php-apache

Subtask 1.2: Verify Metrics Server Installation

The HPA requires metrics server to function properly. Let's verify it's running:

    Check if metrics server is installed:

kubectl get deployment metrics-server -n kube-system

    If metrics server is not running, install it:

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

    Wait for metrics server to be ready:

kubectl wait --for=condition=available --timeout=300s deployment/metrics-server -n kube-system

    Verify metrics are available:

kubectl top nodes
kubectl top pods

Subtask 1.3: Create Horizontal Pod Autoscaler

Now we'll create an HPA that scales based on CPU utilization.

    Create the HPA using kubectl command:

kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10

    Alternatively, create an HPA using YAML manifest:

cat > hpa-config.yaml << 'EOF'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 4
        periodSeconds: 15
      selectPolicy: Max
EOF

    Apply the HPA configuration:

kubectl apply -f hpa-config.yaml

    Verify the HPA is created:

kubectl get hpa
kubectl describe hpa php-apache

Task 2: Generate Traffic to Observe Scaling Behavior
Subtask 2.1: Create Load Generator Pod

We'll create a pod that generates continuous traffic to trigger autoscaling.

    Create a load generator pod:

kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh

    Inside the load generator pod, run the following command to generate load:

while true; do wget -q -O- http://php-apache; done

Subtask 2.2: Monitor Scaling in Real-Time

Open a new terminal window and monitor the scaling behavior:

    Watch HPA status in real-time:

kubectl get hpa php-apache --watch

    In another terminal, monitor pod scaling:

kubectl get pods -l app=php-apache --watch

    Monitor resource usage:

watch kubectl top pods -l app=php-apache

Subtask 2.3: Observe Scaling Events

    Check HPA events to see scaling decisions:

kubectl describe hpa php-apache

    View deployment events:

kubectl describe deployment php-apache

    Check cluster events:

kubectl get events --sort-by=.metadata.creationTimestamp

Subtask 2.4: Test Scale-Down Behavior

    Stop the load generator by pressing Ctrl+C in the load generator terminal.

    Monitor the scale-down process:

kubectl get hpa php-apache --watch

    Observe how pods are terminated:

kubectl get pods -l app=php-apache --watch

Task 3: Experiment with Vertical Pod Autoscaler (VPA)
Subtask 3.1: Install Vertical Pod Autoscaler

VPA is not installed by default, so we need to install it first.

    Clone the VPA repository:

git clone https://github.com/kubernetes/autoscaler.git
cd autoscaler/vertical-pod-autoscaler/

    Install VPA components:

./hack/vpa-install.sh

    Verify VPA installation:

kubectl get pods -n kube-system | grep vpa

Subtask 3.2: Create a VPA Configuration

    First, remove the existing HPA to avoid conflicts:

kubectl delete hpa php-apache

    Create a VPA configuration:

cat > vpa-config.yaml << 'EOF'
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: php-apache-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: php-apache
      minAllowed:
        cpu: 100m
        memory: 50Mi
      maxAllowed:
        cpu: 1000m
        memory: 500Mi
      controlledResources: ["cpu", "memory"]
EOF

    Apply the VPA configuration:

kubectl apply -f vpa-config.yaml

    Verify VPA is created:

kubectl get vpa
kubectl describe vpa php-apache-vpa

Subtask 3.3: Generate Load for VPA Testing

    Create a more intensive load generator:

cat > load-generator-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: load-generator
spec:
  replicas: 3
  selector:
    matchLabels:
      app: load-generator
  template:
    metadata:
      labels:
        app: load-generator
    spec:
      containers:
      - name: load-generator
        image: busybox
        command: ["/bin/sh"]
        args: ["-c", "while true; do wget -q -O- http://php-apache; sleep 0.1; done"]
        resources:
          requests:
            cpu: 100m
            memory: 64Mi
EOF

    Deploy the load generator:

kubectl apply -f load-generator-deployment.yaml

Subtask 3.4: Monitor VPA Recommendations

    Monitor VPA recommendations:

kubectl describe vpa php-apache-vpa

    Check the current resource usage:

kubectl top pods -l app=php-apache

    Watch for pod restarts as VPA applies new resource limits:

kubectl get pods -l app=php-apache --watch

    Compare resource requests before and after VPA adjustment:

kubectl describe pod -l app=php-apache

Subtask 3.5: Test VPA in Recommendation Mode

    Create a VPA in recommendation-only mode:

cat > vpa-recommend-only.yaml << 'EOF'
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: php-apache-vpa-recommend
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  updatePolicy:
    updateMode: "Off"
  resourcePolicy:
    containerPolicies:
    - containerName: php-apache
      minAllowed:
        cpu: 100m
        memory: 50Mi
      maxAllowed:
        cpu: 1000m
        memory: 500Mi
EOF

    Apply the recommendation-only VPA:

kubectl delete vpa php-apache-vpa
kubectl apply -f vpa-recommend-only.yaml

    View recommendations without automatic updates:

kubectl describe vpa php-apache-vpa-recommend

Task 4: Advanced Autoscaling Scenarios
Subtask 4.1: Multi-Metric HPA

Create an HPA that scales based on multiple metrics:

cat > multi-metric-hpa.yaml << 'EOF'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache-multi-metric
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 2
  maxReplicas: 15
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 70
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Pods
        value: 1
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Pods
        value: 2
        periodSeconds: 60
EOF

Subtask 4.2: Custom Metrics HPA

For advanced scenarios, you can also scale based on custom metrics:

cat > custom-metric-hpa.yaml << 'EOF'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache-custom
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "1k"
EOF

Troubleshooting Common Issues
Issue 1: HPA Shows "Unknown" Status

Problem: HPA status shows "Unknown" for current metrics.

Solution:

    Check if metrics server is running:

kubectl get pods -n kube-system | grep metrics-server

    Verify pod resource requests are set:

kubectl describe deployment php-apache

    Check metrics server logs:

kubectl logs -n kube-system deployment/metrics-server

Issue 2: VPA Not Updating Resources

Problem: VPA recommendations are generated but pods are not updated.

Solution:

    Ensure VPA is in "Auto" mode:

kubectl describe vpa php-apache-vpa

    Check VPA admission controller:

kubectl get pods -n kube-system | grep vpa-admission-controller

    Verify no resource quotas are blocking updates:

kubectl describe resourcequota

Issue 3: Scaling Too Aggressive or Too Slow

Problem: Autoscaling behavior is not optimal.

Solution:

    Adjust scaling policies in HPA behavior section
    Modify stabilization windows
    Fine-tune target utilization percentages

Cleanup

Clean up the resources created in this lab:

# Delete deployments
kubectl delete deployment php-apache load-generator

# Delete services
kubectl delete service php-apache

# Delete HPA
kubectl delete hpa --all

# Delete VPA
kubectl delete vpa --all

# Delete configuration files
rm -f php-apache-deployment.yaml hpa-config.yaml vpa-config.yaml load-generator-deployment.yaml
rm -f multi-metric-hpa.yaml custom-metric-hpa.yaml vpa-recommend-only.yaml

# Clean up VPA installation (optional)
cd autoscaler/vertical-pod-autoscaler/
./hack/vpa-down.sh
cd ../../../
rm -rf autoscaler/

Conclusion

In this comprehensive lab, you have successfully:

• Implemented Horizontal Pod Autoscaler (HPA) to automatically scale applications based on CPU utilization, learning how Kubernetes can dynamically adjust the number of pod replicas to handle varying workloads

• Generated synthetic traffic and observed real-time scaling behavior, understanding how HPA responds to load changes and the importance of proper resource requests and limits

• Configured Vertical Pod Autoscaler (VPA) to automatically adjust resource requests and limits, learning the difference between horizontal scaling (more pods) and vertical scaling (bigger pods)

• Explored advanced autoscaling scenarios including multi-metric scaling and custom metrics, preparing you for complex production environments

• Gained hands-on experience with monitoring tools and troubleshooting techniques essential for managing autoscaling in production Kubernetes clusters

This knowledge is crucial for the Kubernetes and Cloud Native Associate (KCNA) certification and real-world Kubernetes operations. Autoscaling is a fundamental capability that enables applications to handle varying loads efficiently while optimizing resource utilization and costs. Understanding both HPA and VPA allows you to choose the right scaling strategy for different application patterns and requirements.

The skills you've developed in this lab will help you design resilient, cost-effective Kubernetes applications that can automatically adapt to changing demands, making you a more effective cloud-native engineer.




Lab 16: Integrating Kubernetes with CI/CD Pipelines
Objectives

By the end of this lab, you will be able to:

• Set up a complete CI/CD pipeline using GitHub Actions • Automatically build and push Docker images to a container registry • Deploy applications to a Kubernetes cluster through automation • Implement automated testing and deployment verification • Configure rollback procedures for failed deployments • Understand the integration between CI/CD tools and Kubernetes • Apply best practices for container-based deployment workflows
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Docker containers and images • Familiarity with Kubernetes concepts (pods, deployments, services) • Knowledge of Git version control system • Understanding of YAML configuration files • Basic command-line interface experience • GitHub account (free tier is sufficient)
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with all necessary tools pre-installed. Simply click Start Lab to access your environment. No need to build your own VM or install additional software.

Your lab environment includes: • Ubuntu 20.04 LTS with Docker pre-installed • kubectl command-line tool configured • Minikube for local Kubernetes cluster • Git client and text editors • All necessary networking configurations
Task 1: Setting Up the Development Environment
Subtask 1.1: Initialize the Project Repository

First, we'll create a sample application and set up version control.

    Create a new directory for your project:

mkdir k8s-cicd-lab
cd k8s-cicd-lab

    Initialize a Git repository:

git init
git config user.name "Your Name"
git config user.email "your.email@example.com"

    Create a simple Node.js application:

cat > app.js << 'EOF'
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Kubernetes CI/CD Pipeline!',
    version: process.env.APP_VERSION || '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`App running on port ${port}`);
});
EOF

    Create package.json file:

cat > package.json << 'EOF'
{
  "name": "k8s-cicd-app",
  "version": "1.0.0",
  "description": "Sample app for Kubernetes CI/CD integration",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "test": "echo \"Running tests...\" && exit 0"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

Subtask 1.2: Create Dockerfile

Create a Dockerfile to containerize the application:

cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --only=production

COPY . .

EXPOSE 3000

USER node

CMD ["npm", "start"]
EOF

Subtask 1.3: Create Kubernetes Manifests

    Create a deployment manifest:

mkdir k8s-manifests
cat > k8s-manifests/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cicd-app
  labels:
    app: cicd-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: cicd-app
  template:
    metadata:
      labels:
        app: cicd-app
    spec:
      containers:
      - name: cicd-app
        image: cicd-app:latest
        ports:
        - containerPort: 3000
        env:
        - name: APP_VERSION
          value: "1.0.0"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
EOF

    Create a service manifest:

cat > k8s-manifests/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: cicd-app-service
spec:
  selector:
    app: cicd-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: LoadBalancer
EOF

Task 2: Setting Up CI/CD Pipeline with GitHub Actions
Subtask 2.1: Create GitHub Actions Workflow

    Create the GitHub Actions directory structure:

mkdir -p .github/workflows

    Create the main CI/CD workflow file:

cat > .github/workflows/ci-cd.yaml << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: docker.io
  IMAGE_NAME: cicd-app

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'

    - name: Install dependencies
      run: npm ci

    - name: Run tests
      run: npm test

    - name: Run security audit
      run: npm audit --audit-level high

  build-and-push:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
      image-digest: ${{ steps.build.outputs.digest }}
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Log in to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha,prefix={{branch}}-
          type=raw,value=latest,enable={{is_default_branch}}

    - name: Build and push Docker image
      id: build
      uses: docker/build-push-action@v5
      with:
        context: .
        platforms: linux/amd64,linux/arm64
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'v1.28.0'

    - name: Configure kubectl
      run: |
        mkdir -p $HOME/.kube
        echo "${{ secrets.KUBECONFIG }}" | base64 -d > $HOME/.kube/config

    - name: Update deployment image
      run: |
        sed -i 's|image: cicd-app:latest|image: ${{ needs.build-and-push.outputs.image-tag }}|g' k8s-manifests/deployment.yaml

    - name: Deploy to Kubernetes
      run: |
        kubectl apply -f k8s-manifests/
        kubectl rollout status deployment/cicd-app --timeout=300s

    - name: Verify deployment
      run: |
        kubectl get pods -l app=cicd-app
        kubectl get services cicd-app-service
EOF

Subtask 2.2: Create Rollback Workflow

Create a separate workflow for handling rollbacks:

cat > .github/workflows/rollback.yaml << 'EOF'
name: Rollback Deployment

on:
  workflow_dispatch:
    inputs:
      revision:
        description: 'Revision number to rollback to (leave empty for previous)'
        required: false
        type: string

jobs:
  rollback:
    runs-on: ubuntu-latest
    steps:
    - name: Setup kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'v1.28.0'

    - name: Configure kubectl
      run: |
        mkdir -p $HOME/.kube
        echo "${{ secrets.KUBECONFIG }}" | base64 -d > $HOME/.kube/config

    - name: Rollback deployment
      run: |
        if [ -n "${{ github.event.inputs.revision }}" ]; then
          kubectl rollout undo deployment/cicd-app --to-revision=${{ github.event.inputs.revision }}
        else
          kubectl rollout undo deployment/cicd-app
        fi

    - name: Wait for rollback completion
      run: |
        kubectl rollout status deployment/cicd-app --timeout=300s

    - name: Verify rollback
      run: |
        kubectl get pods -l app=cicd-app
        kubectl describe deployment cicd-app
EOF

Task 3: Setting Up Local Kubernetes Environment
Subtask 3.1: Start Minikube Cluster

    Start Minikube with appropriate resources:

minikube start --driver=docker --memory=4096 --cpus=2

    Verify cluster is running:

kubectl cluster-info
kubectl get nodes

    Enable necessary addons:

minikube addons enable ingress
minikube addons enable metrics-server

Subtask 3.2: Configure Docker Environment

Configure Docker to use Minikube's Docker daemon:

eval $(minikube docker-env)

This allows you to build images directly in Minikube's Docker environment.
Task 4: Manual Testing and Deployment
Subtask 4.1: Build and Test Locally

Before setting up the full CI/CD pipeline, let's test everything manually:

    Build the Docker image:

docker build -t cicd-app:v1.0.0 .

    Test the container locally:

docker run -d -p 3000:3000 --name test-app cicd-app:v1.0.0

    Verify the application is working:

curl http://localhost:3000
curl http://localhost:3000/health

    Stop and remove the test container:

docker stop test-app
docker rm test-app

Subtask 4.2: Deploy to Kubernetes Manually

    Update the deployment manifest to use the local image:

sed -i 's|image: cicd-app:latest|image: cicd-app:v1.0.0|g' k8s-manifests/deployment.yaml
sed -i 's|imagePullPolicy: Always|imagePullPolicy: Never|g' k8s-manifests/deployment.yaml

    Deploy the application:

kubectl apply -f k8s-manifests/

    Check deployment status:

kubectl get deployments
kubectl get pods
kubectl get services

    Wait for deployment to be ready:

kubectl rollout status deployment/cicd-app

Subtask 4.3: Test the Deployed Application

    Get the service URL:

minikube service cicd-app-service --url

    Test the application (replace URL with the output from previous command):

SERVICE_URL=$(minikube service cicd-app-service --url)
curl $SERVICE_URL
curl $SERVICE_URL/health

Task 5: Setting Up GitHub Repository and Secrets
Subtask 5.1: Create GitHub Repository

    Add all files to Git:

git add .
git commit -m "Initial commit: Add application and CI/CD configuration"

    Create a new repository on GitHub (through the web interface):
        Go to https://github.com
        Click "New repository"
        Name it "k8s-cicd-lab"
        Make it public or private as preferred
        Don't initialize with README (we already have files)

    Push to GitHub:

git remote add origin https://github.com/YOUR_USERNAME/k8s-cicd-lab.git
git branch -M main
git push -u origin main

Subtask 5.2: Configure GitHub Secrets

You need to set up the following secrets in your GitHub repository:

    Go to your repository on GitHub
    Click Settings → Secrets and variables → Actions
    Add the following secrets:

DOCKER_USERNAME: Your Docker Hub username DOCKER_PASSWORD: Your Docker Hub password or access token KUBECONFIG: Base64 encoded kubeconfig file

To get the base64 encoded kubeconfig:

cat ~/.kube/config | base64 -w 0

Task 6: Testing the Complete CI/CD Pipeline
Subtask 6.1: Trigger the Pipeline

    Make a change to the application:

sed -i 's/version: process.env.APP_VERSION || '\''1.0.0'\''/version: process.env.APP_VERSION || '\''1.1.0'\''/g' app.js

    Commit and push the change:

git add app.js
git commit -m "Update application version to 1.1.0"
git push origin main

    Monitor the GitHub Actions workflow:
        Go to your repository on GitHub
        Click the "Actions" tab
        Watch the workflow execution

Subtask 6.2: Verify Automated Deployment

    Check if the deployment was updated:

kubectl get deployments
kubectl describe deployment cicd-app

    Verify the new version is running:

kubectl get pods
SERVICE_URL=$(minikube service cicd-app-service --url)
curl $SERVICE_URL

Task 7: Testing Rollback Procedures
Subtask 7.1: Simulate a Failed Deployment

    Create a broken version of the application:

cat > app.js << 'EOF'
const express = require('express');
const app = express();
const port = 3000;

// Intentionally broken code
app.get('/', (req, res) => {
  // This will cause an error
  nonExistentFunction();
  res.json({
    message: 'This version is broken!',
    version: '2.0.0'
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`App running on port ${port}`);
});
EOF

    Commit and push the broken version:

git add app.js
git commit -m "Deploy broken version 2.0.0 (for rollback testing)"
git push origin main

Subtask 7.2: Monitor the Failed Deployment

    Watch the deployment status:

kubectl rollout status deployment/cicd-app --timeout=60s

    Check pod status:

kubectl get pods
kubectl describe pods -l app=cicd-app

Subtask 7.3: Perform Manual Rollback

    Check rollout history:

kubectl rollout history deployment/cicd-app

    Rollback to previous version:

kubectl rollout undo deployment/cicd-app

    Verify rollback success:

kubectl rollout status deployment/cicd-app
SERVICE_URL=$(minikube service cicd-app-service --url)
curl $SERVICE_URL

Subtask 7.4: Test Automated Rollback via GitHub Actions

    Go to your GitHub repository
    Click Actions → Rollback Deployment → Run workflow
    Leave revision empty to rollback to previous version
    Click "Run workflow"

Task 8: Advanced Pipeline Features
Subtask 8.1: Add Environment-Specific Deployments

Create separate deployment configurations for different environments:

mkdir -p k8s-manifests/environments/{staging,production}

# Staging environment
cat > k8s-manifests/environments/staging/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../deployment.yaml
- ../../service.yaml

namePrefix: staging-
namespace: staging

replicas:
- name: cicd-app
  count: 1

patches:
- patch: |-
    - op: replace
      path: /spec/template/spec/containers/0/env/0/value
      value: "staging-1.0.0"
  target:
    kind: Deployment
    name: cicd-app
EOF

# Production environment
cat > k8s-manifests/environments/production/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../deployment.yaml
- ../../service.yaml

namePrefix: prod-
namespace: production

replicas:
- name: cicd-app
  count: 5

patches:
- patch: |-
    - op: replace
      path: /spec/template/spec/containers/0/env/0/value
      value: "production-1.0.0"
  target:
    kind: Deployment
    name: cicd-app
EOF

Subtask 8.2: Create Namespaces

kubectl create namespace staging
kubectl create namespace production

Subtask 8.3: Deploy to Multiple Environments

# Deploy to staging
kubectl apply -k k8s-manifests/environments/staging/

# Deploy to production
kubectl apply -k k8s-manifests/environments/production/

# Verify deployments
kubectl get deployments --all-namespaces

Troubleshooting Common Issues
Issue 1: Docker Build Failures

Problem: Docker build fails with permission errors Solution:

sudo usermod -aG docker $USER
newgrp docker

Issue 2: Kubernetes Deployment Stuck

Problem: Pods remain in Pending state Solution:

kubectl describe pods -l app=cicd-app
kubectl get events --sort-by=.metadata.creationTimestamp

Issue 3: Service Not Accessible

Problem: Cannot access the application through the service Solution:

kubectl port-forward service/cicd-app-service 8080:80
curl http://localhost:8080

Issue 4: GitHub Actions Workflow Fails

Problem: CI/CD pipeline fails due to missing secrets Solution:

    Verify all required secrets are set in GitHub repository settings
    Check secret names match exactly with workflow file
    Ensure Docker Hub credentials are correct

Issue 5: Image Pull Errors

Problem: Kubernetes cannot pull the Docker image Solution:

# For local development with Minikube
eval $(minikube docker-env)
docker build -t cicd-app:latest .

Conclusion

Congratulations! You have successfully completed Lab 16: Integrating Kubernetes with CI/CD Pipelines. In this comprehensive lab, you have accomplished the following:

Key Achievements: • Built a complete CI/CD pipeline using GitHub Actions that automatically builds, tests, and deploys applications • Integrated Docker containerization with Kubernetes deployment workflows • Implemented automated testing and security auditing in your pipeline • Configured multi-environment deployments with staging and production configurations • Mastered rollback procedures both manual and automated for handling deployment failures • Applied DevOps best practices including proper secret management and environment separation

Technical Skills Developed: • Container orchestration with Kubernetes • Continuous Integration and Continuous Deployment (CI/CD) concepts • Infrastructure as Code using YAML manifests • Automated testing and deployment verification • Rollback strategies and disaster recovery procedures • Multi-environment deployment management

Real-World Applications: This lab simulates real-world enterprise scenarios where development teams need to:

    Automatically deploy code changes to production environments
    Maintain high availability during deployments
    Quickly recover from failed deployments
    Manage multiple environments with different configurations
    Ensure code quality through automated testing

Why This Matters: Modern software development relies heavily on automation to deliver reliable, scalable applications. The CI/CD pipeline you've built represents industry-standard practices used by companies worldwide to:

    Reduce manual errors in deployment processes
    Increase deployment frequency and reliability
    Enable rapid response to issues through automated rollbacks
    Maintain consistent environments across development lifecycle
    Support agile development methodologies

Next Steps: To further enhance your skills, consider exploring:

    Advanced Kubernetes features like Helm charts and operators
    Monitoring and observability tools like Prometheus and Grafana
    Security scanning integration in CI/CD pipelines
    GitOps workflows with tools like ArgoCD or Flux
    Service mesh technologies like Istio for advanced traffic management

You now have the foundational knowledge to implement robust CI/CD pipelines in production environments and are well-prepared for the Kubernetes and Cloud Native Associate (KCNA) certification exam.




Lab 17: Exploring Kubernetes Security Best Practices
Objectives

By the end of this lab, you will be able to:

• Understand and implement Pod Security Standards in Kubernetes clusters • Configure and apply Network Policies to control Pod-to-Pod communication • Set up image vulnerability scanning using Trivy • Implement security best practices for container workloads • Troubleshoot common security configuration issues in Kubernetes
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (Pods, Services, Deployments) • Familiarity with YAML configuration files • Basic knowledge of Linux command line operations • Understanding of container security concepts • Completion of previous Kubernetes labs or equivalent experience
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with Kubernetes pre-installed. Simply click Start Lab to access your environment - no need to build your own VM or install Kubernetes from scratch.

Your lab environment includes: • Ubuntu 22.04 LTS with kubectl pre-configured • Kubernetes cluster (kind or minikube) ready to use • All necessary tools pre-installed • Internet access for downloading container images
Task 1: Implementing Pod Security Standards

Pod Security Standards replace the deprecated PodSecurityPolicies and provide a simpler way to enforce security policies.
Subtask 1.1: Understanding Pod Security Standards

Pod Security Standards define three security profiles: • Privileged: Unrestricted policy (no restrictions) • Baseline: Minimally restrictive policy (prevents known privilege escalations) • Restricted: Heavily restricted policy (follows Pod hardening best practices)
Subtask 1.2: Enable Pod Security Admission

First, let's check if Pod Security Admission is enabled in your cluster:

kubectl api-versions | grep admissionregistration

Create a namespace with Pod Security Standards enforcement:

# Create a restricted namespace
kubectl create namespace secure-apps

# Apply Pod Security Standards labels
kubectl label namespace secure-apps \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted

Subtask 1.3: Test Pod Security Standards

Create a test deployment that violates security policies:

# Create file: insecure-pod.yaml
cat << 'EOF' > insecure-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: insecure-pod
  namespace: secure-apps
spec:
  containers:
  - name: nginx
    image: nginx:latest
    securityContext:
      privileged: true
      runAsUser: 0
    ports:
    - containerPort: 80
EOF

Try to apply this insecure pod:

kubectl apply -f insecure-pod.yaml

You should see warnings or errors about security policy violations.
Subtask 1.4: Create a Compliant Pod

Now create a security-compliant pod:

# Create file: secure-pod.yaml
cat << 'EOF' > secure-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: secure-apps
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: nginx
    image: nginx:latest
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
    ports:
    - containerPort: 8080
    volumeMounts:
    - name: tmp-volume
      mountPath: /tmp
    - name: var-cache-nginx
      mountPath: /var/cache/nginx
    - name: var-run
      mountPath: /var/run
  volumes:
  - name: tmp-volume
    emptyDir: {}
  - name: var-cache-nginx
    emptyDir: {}
  - name: var-run
    emptyDir: {}
EOF

Apply the secure pod:

kubectl apply -f secure-pod.yaml

Verify the pod is running:

kubectl get pods -n secure-apps
kubectl describe pod secure-pod -n secure-apps

Task 2: Implementing Network Policies

Network Policies control traffic flow between Pods and other network endpoints.
Subtask 2.1: Prepare the Environment

Create namespaces for our network policy demonstration:

# Create namespaces
kubectl create namespace frontend
kubectl create namespace backend
kubectl create namespace database

# Label namespaces for easy identification
kubectl label namespace frontend tier=frontend
kubectl label namespace backend tier=backend
kubectl label namespace database tier=database

Subtask 2.2: Deploy Test Applications

Deploy applications in each namespace:

# Create file: frontend-app.yaml
cat << 'EOF' > frontend-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: frontend
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

# Create file: backend-app.yaml
cat << 'EOF' > backend-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
        tier: backend
    spec:
      containers:
      - name: httpd
        image: httpd:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: backend
spec:
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

# Create file: database-app.yaml
cat << 'EOF' > database-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database
  namespace: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
        tier: database
    spec:
      containers:
      - name: postgres
        image: postgres:alpine
        env:
        - name: POSTGRES_PASSWORD
          value: "password123"
        ports:
        - containerPort: 5432
---
apiVersion: v1
kind: Service
metadata:
  name: database-service
  namespace: database
spec:
  selector:
    app: database
  ports:
  - port: 5432
    targetPort: 5432
  type: ClusterIP
EOF

Deploy all applications:

kubectl apply -f frontend-app.yaml
kubectl apply -f backend-app.yaml
kubectl apply -f database-app.yaml

Verify deployments:

kubectl get pods -n frontend
kubectl get pods -n backend
kubectl get pods -n database

Subtask 2.3: Test Initial Connectivity

Before applying network policies, test connectivity between namespaces:

# Get a frontend pod name
FRONTEND_POD=$(kubectl get pods -n frontend -o jsonpath='{.items[0].metadata.name}')

# Test connectivity to backend
kubectl exec -n frontend $FRONTEND_POD -- wget -qO- --timeout=2 http://backend-service.backend.svc.cluster.local

# Test connectivity to database
kubectl exec -n frontend $FRONTEND_POD -- nc -zv database-service.database.svc.cluster.local 5432

Subtask 2.4: Implement Network Policies

Create a network policy to restrict database access:

# Create file: database-network-policy.yaml
cat << 'EOF' > database-network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
  namespace: database
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 5432
  egress:
  - {}  # Allow all egress traffic
EOF

Create a network policy for backend services:

# Create file: backend-network-policy.yaml
cat << 'EOF' > backend-network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          tier: database
    ports:
    - protocol: TCP
      port: 5432
  - to: {}  # Allow DNS resolution
    ports:
    - protocol: UDP
      port: 53
EOF

Apply the network policies:

kubectl apply -f database-network-policy.yaml
kubectl apply -f backend-network-policy.yaml

Subtask 2.5: Test Network Policy Enforcement

Test that the database is now protected:

# This should fail - frontend cannot directly access database
kubectl exec -n frontend $FRONTEND_POD -- nc -zv database-service.database.svc.cluster.local 5432

# This should work - frontend can access backend
kubectl exec -n frontend $FRONTEND_POD -- wget -qO- --timeout=2 http://backend-service.backend.svc.cluster.local

# Test from backend to database (should work)
BACKEND_POD=$(kubectl get pods -n backend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n backend $BACKEND_POD -- nc -zv database-service.database.svc.cluster.local 5432

Task 3: Container Image Scanning with Trivy

Trivy is an open-source vulnerability scanner for containers and other artifacts.
Subtask 3.1: Install Trivy

Install Trivy on your system:

# Download and install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.48.0

# Verify installation
trivy version

Subtask 3.2: Scan Container Images

Scan a container image for vulnerabilities:

# Scan nginx image
trivy image nginx:latest

# Scan with specific severity levels
trivy image --severity HIGH,CRITICAL nginx:latest

# Generate JSON report
trivy image --format json --output nginx-scan.json nginx:latest

Subtask 3.3: Scan Images in Kubernetes

Create a script to scan all images in your cluster:

# Create file: scan-cluster-images.sh
cat << 'EOF' > scan-cluster-images.sh
#!/bin/bash

echo "Scanning all container images in the cluster..."

# Get all unique images from all namespaces
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}' | sort -u > cluster-images.txt

# Scan each image
while IFS= read -r image; do
    echo "Scanning image: $image"
    trivy image --severity HIGH,CRITICAL --quiet "$image"
    echo "---"
done < cluster-images.txt

rm cluster-images.txt
EOF

chmod +x scan-cluster-images.sh

Run the cluster image scan:

./scan-cluster-images.sh

Subtask 3.4: Implement Image Scanning in CI/CD

Create a sample admission controller configuration that would reject images with high vulnerabilities:

# Create file: image-policy.yaml
cat << 'EOF' > image-policy.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: image-security-policy
  namespace: kube-system
data:
  policy.yaml: |
    apiVersion: v1
    kind: Policy
    rules:
    - name: "scan-images"
      match:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
      validate:
        message: "Images must be scanned and have no HIGH or CRITICAL vulnerabilities"
        pattern:
          spec:
            containers:
            - name: "*"
              image: "!*:latest"  # Discourage latest tags
EOF

Subtask 3.5: Create Secure Image Build Process

Create a sample Dockerfile with security best practices:

# Create file: Dockerfile.secure
cat << 'EOF' > Dockerfile.secure
# Use specific version, not latest
FROM nginx:1.25-alpine

# Create non-root user
RUN addgroup -g 1001 -S nginx-user && \
    adduser -u 1001 -D -S -G nginx-user nginx-user

# Remove unnecessary packages and clean cache
RUN apk del --purge wget curl && \
    rm -rf /var/cache/apk/*

# Set proper permissions
RUN chown -R nginx-user:nginx-user /var/cache/nginx && \
    chown -R nginx-user:nginx-user /var/log/nginx && \
    chown -R nginx-user:nginx-user /etc/nginx/conf.d

# Use non-root user
USER nginx-user

# Expose non-privileged port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
EOF

Task 4: Additional Security Configurations
Subtask 4.1: Configure RBAC (Role-Based Access Control)

Create a service account with limited permissions:

# Create file: rbac-config.yaml
cat << 'EOF' > rbac-config.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-service-account
  namespace: secure-apps
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: secure-apps
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: secure-apps
subjects:
- kind: ServiceAccount
  name: app-service-account
  namespace: secure-apps
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
EOF

Apply RBAC configuration:

kubectl apply -f rbac-config.yaml

Subtask 4.2: Configure Resource Quotas and Limits

Create resource quotas to prevent resource exhaustion:

# Create file: resource-quota.yaml
cat << 'EOF' > resource-quota.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: secure-apps-quota
  namespace: secure-apps
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
    pods: "10"
    services: "5"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: secure-apps-limits
  namespace: secure-apps
spec:
  limits:
  - default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    type: Container
EOF

Apply resource constraints:

kubectl apply -f resource-quota.yaml

Subtask 4.3: Verify Security Configurations

Check all security configurations:

# Check Pod Security Standards
kubectl get namespace secure-apps --show-labels

# Check Network Policies
kubectl get networkpolicies --all-namespaces

# Check RBAC
kubectl get serviceaccounts -n secure-apps
kubectl get roles -n secure-apps
kubectl get rolebindings -n secure-apps

# Check Resource Quotas
kubectl get resourcequota -n secure-apps
kubectl describe resourcequota secure-apps-quota -n secure-apps

Troubleshooting Common Issues
Issue 1: Pod Security Standards Not Working

Problem: Pods are not being blocked by security policies.

Solution:

# Check if Pod Security Admission is enabled
kubectl api-versions | grep admissionregistration

# Verify namespace labels
kubectl get namespace secure-apps --show-labels

# Check cluster configuration
kubectl get nodes -o wide

Issue 2: Network Policies Not Enforcing

Problem: Network policies are not blocking traffic.

Solution:

# Check if your CNI supports Network Policies
kubectl get pods -n kube-system | grep -E "(calico|cilium|weave)"

# Verify network policy syntax
kubectl describe networkpolicy database-policy -n database

# Test with verbose output
kubectl exec -n frontend $FRONTEND_POD -- nc -zv database-service.database.svc.cluster.local 5432

Issue 3: Trivy Scanning Errors

Problem: Trivy fails to scan images.

Solution:

# Update Trivy database
trivy image --download-db-only

# Check internet connectivity
curl -I https://github.com

# Scan with debug output
trivy image --debug nginx:latest

Lab Validation

Verify your lab completion by running these validation commands:

# Check Pod Security Standards
echo "=== Pod Security Standards ==="
kubectl get pods -n secure-apps
kubectl describe pod secure-pod -n secure-apps | grep -A 10 "Security Context"

# Check Network Policies
echo "=== Network Policies ==="
kubectl get networkpolicies --all-namespaces

# Check Image Scanning
echo "=== Image Scanning ==="
trivy image --severity HIGH,CRITICAL --quiet nginx:alpine | head -10

# Check RBAC
echo "=== RBAC Configuration ==="
kubectl auth can-i get pods --as=system:serviceaccount:secure-apps:app-service-account -n secure-apps

# Check Resource Quotas
echo "=== Resource Quotas ==="
kubectl describe resourcequota secure-apps-quota -n secure-apps

Conclusion

Congratulations! You have successfully completed Lab 17: Exploring Kubernetes Security Best Practices. In this comprehensive lab, you have:

• Implemented Pod Security Standards to enforce security policies at the pod level, replacing deprecated PodSecurityPolicies with a more modern and flexible approach • Configured Network Policies to control traffic flow between pods and namespaces, implementing a zero-trust network security model • Set up container image vulnerability scanning using Trivy to identify and address security vulnerabilities before deployment • Applied additional security configurations including RBAC, resource quotas, and security contexts

Why This Matters: Security in Kubernetes is not optional—it's essential. As containerized applications become more prevalent in production environments, implementing these security best practices helps protect against:

    Container breakouts and privilege escalation attacks
    Lateral movement within the cluster through network segmentation
    Vulnerable dependencies in container images
    Resource exhaustion attacks through proper quotas and limits
    Unauthorized access through proper RBAC implementation

These skills are fundamental for the Kubernetes and Cloud Native Associate (KCNA) certification and are critical for anyone working with Kubernetes in production environments. The security practices you've learned today form the foundation of a comprehensive Kubernetes security strategy that protects both your applications and your infrastructure.

Remember to regularly update your security policies, scan images for new vulnerabilities, and review access controls as your applications and teams evolve. Security is an ongoing process, not a one-time configuration.



Lab 18: Observability with Prometheus and Grafana
Objectives

By the end of this lab, you will be able to:

• Deploy Prometheus monitoring system to a Kubernetes cluster • Configure Prometheus to scrape metrics from cluster components • Install and configure Grafana for data visualization • Create custom dashboards in Grafana to monitor cluster health • Set up alerting rules for critical metrics like CPU and memory usage • Understand the fundamentals of observability in cloud-native environments • Implement monitoring best practices for Kubernetes workloads
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (pods, services, deployments) • Familiarity with YAML configuration files • Basic knowledge of Linux command line operations • Understanding of containerization concepts • Access to kubectl command-line tool • Basic understanding of monitoring and metrics concepts
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with all necessary tools pre-installed. Simply click Start Lab to begin - no need to build your own VM or install additional software.

Your lab environment includes: • Ubuntu 20.04 LTS with Docker pre-installed • Kubernetes cluster (minikube) ready to use • kubectl configured and ready • Helm package manager installed • All necessary networking configured
Task 1: Deploy Prometheus to the Cluster
Subtask 1.1: Verify Cluster Status

First, let's ensure our Kubernetes cluster is running properly.

# Check cluster status
kubectl cluster-info

# Verify nodes are ready
kubectl get nodes

# Check if minikube is running (if using minikube)
minikube status

Subtask 1.2: Create Monitoring Namespace

Create a dedicated namespace for our monitoring stack.

# Create monitoring namespace
kubectl create namespace monitoring

# Verify namespace creation
kubectl get namespaces

Subtask 1.3: Deploy Prometheus Using Helm

We'll use Helm to deploy Prometheus, which simplifies the installation process.

# Add Prometheus community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Update Helm repositories
helm repo update

# Install Prometheus stack (includes Prometheus, Grafana, and AlertManager)
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false

Subtask 1.4: Verify Prometheus Deployment

Check that all components are deployed successfully.

# Check all pods in monitoring namespace
kubectl get pods -n monitoring

# Check services
kubectl get services -n monitoring

# Wait for all pods to be ready (this may take 2-3 minutes)
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=300s

Subtask 1.5: Access Prometheus Web Interface

Set up port forwarding to access Prometheus web interface.

# Port forward Prometheus service
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090 &

# Note: The & runs the command in background
# You can now access Prometheus at http://localhost:9090

Open a web browser and navigate to http://localhost:9090 to verify Prometheus is running.
Task 2: Configure Prometheus to Scrape Metrics
Subtask 2.1: Understand Default Configuration

Prometheus is already configured to scrape basic Kubernetes metrics. Let's examine the configuration.

# View Prometheus configuration
kubectl get configmap -n monitoring prometheus-kube-prometheus-prometheus-rulefiles-0 -o yaml

Subtask 2.2: Deploy Sample Application for Monitoring

Let's deploy a sample application that exposes metrics.

# Create a sample application deployment
cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  namespace: default
  labels:
    app: sample-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: sample-app
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
          name: metrics
---
apiVersion: v1
kind: Service
metadata:
  name: sample-app-service
  namespace: default
  labels:
    app: sample-app
spec:
  selector:
    app: sample-app
  ports:
  - port: 9100
    targetPort: 9100
    name: metrics
EOF

Subtask 2.3: Create ServiceMonitor for Custom Application

Create a ServiceMonitor to tell Prometheus to scrape our sample application.

# Create ServiceMonitor
cat << EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: sample-app-monitor
  namespace: monitoring
  labels:
    app: sample-app
spec:
  selector:
    matchLabels:
      app: sample-app
  namespaceSelector:
    matchNames:
    - default
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
EOF

Subtask 2.4: Verify Metrics Collection

Check that Prometheus is collecting metrics from our application.

# Check if ServiceMonitor is created
kubectl get servicemonitor -n monitoring

# Verify targets in Prometheus web interface
# Go to http://localhost:9090/targets to see all monitored targets

Task 3: Install and Configure Grafana
Subtask 3.1: Access Grafana

Grafana was installed as part of the Prometheus stack. Let's access it.

# Get Grafana admin password
kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
echo

# Port forward Grafana service
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 &

Subtask 3.2: Login to Grafana

    Open web browser and go to http://localhost:3000
    Login with:
        Username: admin
        Password: (use the password from previous step)

Subtask 3.3: Verify Prometheus Data Source

Grafana should already be configured with Prometheus as a data source.

    In Grafana, go to Configuration → Data Sources
    Verify that Prometheus is listed and connected
    The URL should be: http://prometheus-kube-prometheus-prometheus:9090

Task 4: Create Custom Dashboards in Grafana
Subtask 4.1: Import Pre-built Kubernetes Dashboard

Let's import a comprehensive Kubernetes dashboard.

    In Grafana, click the + icon → Import
    Enter dashboard ID: 315 (Kubernetes cluster monitoring dashboard)
    Click Load
    Select Prometheus as the data source
    Click Import

Subtask 4.2: Create Custom Dashboard for Node Metrics

Create a custom dashboard to monitor node-specific metrics.

    Click + → Dashboard → Add new panel

    Configure the first panel:
        Title: CPU Usage by Node
        Query: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
        Visualization: Time series
        Click Apply

    Add another panel:
        Title: Memory Usage by Node
        Query: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
        Visualization: Stat
        Unit: Percent (0-100)
        Click Apply

    Add third panel:
        Title: Disk Usage
        Query: 100 - ((node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100)
        Visualization: Gauge
        Unit: Percent (0-100)
        Click Apply

    Save the dashboard:
        Click Save (disk icon)
        Name: Custom Node Monitoring
        Click Save

Subtask 4.3: Create Pod Monitoring Dashboard

Create a dashboard specifically for pod metrics.

    Create new dashboard: + → Dashboard

    Add panel for Pod CPU Usage:
        Title: Pod CPU Usage
        Query: sum(rate(container_cpu_usage_seconds_total{container!="POD",container!=""}[5m])) by (pod)
        Visualization: Time series

    Add panel for Pod Memory Usage:
        Title: Pod Memory Usage
        Query: sum(container_memory_working_set_bytes{container!="POD",container!=""}) by (pod)
        Visualization: Time series
        Unit: Bytes

    Add panel for Pod Count:
        Title: Running Pods
        Query: count(kube_pod_info)
        Visualization: Stat

    Save dashboard as Pod Monitoring

Task 5: Set Up Alerts for Critical Metrics
Subtask 5.1: Create CPU Usage Alert Rule

Create an alert rule for high CPU usage.

# Create PrometheusRule for CPU alerts
cat << EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: cpu-usage-alerts
  namespace: monitoring
  labels:
    prometheus: kube-prometheus
    role: alert-rules
spec:
  groups:
  - name: cpu.rules
    rules:
    - alert: HighCPUUsage
      expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage detected"
        description: "CPU usage is above 80% for more than 2 minutes on {{ \$labels.instance }}"
    
    - alert: CriticalCPUUsage
      expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 95
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Critical CPU usage detected"
        description: "CPU usage is above 95% for more than 1 minute on {{ \$labels.instance }}"
EOF

Subtask 5.2: Create Memory Usage Alert Rule

Create alert rules for memory usage.

# Create PrometheusRule for Memory alerts
cat << EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: memory-usage-alerts
  namespace: monitoring
  labels:
    prometheus: kube-prometheus
    role: alert-rules
spec:
  groups:
  - name: memory.rules
    rules:
    - alert: HighMemoryUsage
      expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage detected"
        description: "Memory usage is above 85% for more than 2 minutes on {{ \$labels.instance }}"
    
    - alert: CriticalMemoryUsage
      expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 95
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Critical memory usage detected"
        description: "Memory usage is above 95% for more than 1 minute on {{ \$labels.instance }}"
EOF

Subtask 5.3: Create Pod-specific Alert Rules

Create alerts for pod-related issues.

# Create PrometheusRule for Pod alerts
cat << EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: pod-alerts
  namespace: monitoring
  labels:
    prometheus: kube-prometheus
    role: alert-rules
spec:
  groups:
  - name: pod.rules
    rules:
    - alert: PodCrashLooping
      expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Pod is crash looping"
        description: "Pod {{ \$labels.pod }} in namespace {{ \$labels.namespace }} is restarting frequently"
    
    - alert: PodNotReady
      expr: kube_pod_status_ready{condition="false"} == 1
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Pod not ready"
        description: "Pod {{ \$labels.pod }} in namespace {{ \$labels.namespace }} has been not ready for more than 5 minutes"
EOF

Subtask 5.4: Verify Alert Rules

Check that alert rules are loaded correctly.

# Verify PrometheusRules are created
kubectl get prometheusrules -n monitoring

# Check Prometheus web interface for alerts
# Go to http://localhost:9090/alerts to see all configured alerts

Subtask 5.5: Configure Grafana Alerting

Set up alerting in Grafana for dashboard panels.

    In Grafana, go to your Custom Node Monitoring dashboard
    Edit the CPU Usage by Node panel
    Go to Alert tab
    Click Create Alert
    Configure alert condition:
        Query: A (use existing query)
        Condition: IS ABOVE 80
        Evaluation: Every 10s for 1m
    Add notification:
        Name: High CPU Alert
        Message: CPU usage is critically high
    Click Save

Subtask 5.6: Test Alert Functionality

Create a high CPU load to test our alerts.

# Deploy a CPU stress test pod
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: cpu-stress-test
  namespace: default
spec:
  containers:
  - name: stress
    image: progrium/stress
    command: ["stress"]
    args: ["--cpu", "2", "--timeout", "300s"]
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
EOF

Monitor the alerts in both Prometheus (http://localhost:9090/alerts) and Grafana to see if they trigger.
Task 6: Advanced Monitoring Configuration
Subtask 6.1: Configure Custom Metrics Collection

Create a custom application that exposes business metrics.

# Deploy a sample application with custom metrics
cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: custom-metrics-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: custom-metrics-app
  template:
    metadata:
      labels:
        app: custom-metrics-app
    spec:
      containers:
      - name: metrics-app
        image: nginx:alpine
        ports:
        - containerPort: 80
        - containerPort: 9113
          name: metrics
---
apiVersion: v1
kind: Service
metadata:
  name: custom-metrics-service
  namespace: default
  labels:
    app: custom-metrics-app
spec:
  selector:
    app: custom-metrics-app
  ports:
  - port: 80
    name: http
  - port: 9113
    name: metrics
EOF

Subtask 6.2: Create ServiceMonitor for Custom Metrics

# Create ServiceMonitor for custom application
cat << EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: custom-metrics-monitor
  namespace: monitoring
  labels:
    app: custom-metrics-app
spec:
  selector:
    matchLabels:
      app: custom-metrics-app
  namespaceSelector:
    matchNames:
    - default
  endpoints:
  - port: metrics
    interval: 15s
    path: /metrics
EOF

Troubleshooting Common Issues
Issue 1: Pods Not Starting

If pods are not starting properly:

# Check pod status and events
kubectl describe pod -n monitoring

# Check logs
kubectl logs -n monitoring -l app.kubernetes.io/name=prometheus

# Verify resource availability
kubectl top nodes
kubectl top pods -n monitoring

Issue 2: Metrics Not Appearing

If metrics are not showing up in Prometheus:

# Verify ServiceMonitor configuration
kubectl get servicemonitor -n monitoring -o yaml

# Check Prometheus targets
# Go to http://localhost:9090/targets

# Verify service endpoints
kubectl get endpoints -n default

Issue 3: Grafana Connection Issues

If Grafana cannot connect to Prometheus:

# Check Grafana logs
kubectl logs -n monitoring -l app.kubernetes.io/name=grafana

# Verify Prometheus service
kubectl get svc -n monitoring prometheus-kube-prometheus-prometheus

# Test connectivity from Grafana pod
kubectl exec -n monitoring -it deployment/prometheus-grafana -- wget -qO- http://prometheus-kube-prometheus-prometheus:9090/api/v1/status/config

Cleanup

When you're finished with the lab, clean up the resources:

# Stop port forwarding processes
pkill -f "kubectl port-forward"

# Delete test applications
kubectl delete pod cpu-stress-test
kubectl delete deployment sample-app custom-metrics-app
kubectl delete service sample-app-service custom-metrics-service

# Delete ServiceMonitors
kubectl delete servicemonitor -n monitoring sample-app-monitor custom-metrics-monitor

# Delete PrometheusRules
kubectl delete prometheusrules -n monitoring cpu-usage-alerts memory-usage-alerts pod-alerts

# Uninstall Prometheus stack (optional)
helm uninstall prometheus -n monitoring

# Delete monitoring namespace (optional)
kubectl delete namespace monitoring

Conclusion

Congratulations! You have successfully completed Lab 18: Observability with Prometheus and Grafana. In this comprehensive lab, you have accomplished the following:

Key Achievements:

• Deployed a complete monitoring stack using Prometheus and Grafana in a Kubernetes environment • Configured metric collection from both system components and custom applications • Created custom dashboards in Grafana to visualize cluster health and performance metrics • Implemented alerting rules for critical metrics including CPU usage, memory consumption, and pod health • Set up automated monitoring for Kubernetes workloads using ServiceMonitors • Learned troubleshooting techniques for common monitoring issues

Why This Matters:

Observability is crucial in modern cloud-native environments because it provides the visibility needed to:

    Maintain system reliability by detecting issues before they impact users
    Optimize resource utilization and reduce costs through data-driven decisions
    Meet SLA requirements by monitoring performance metrics continuously
    Enable proactive maintenance through predictive alerting
    Support incident response with detailed metrics and historical data

Real-World Applications:

The skills you've developed in this lab are directly applicable to:

    Production Kubernetes clusters in enterprise environments
    DevOps practices for continuous monitoring and improvement
    Site Reliability Engineering (SRE) responsibilities
    Cloud-native application development with built-in observability
    Compliance and audit requirements for system monitoring

Next Steps:

To further enhance your observability skills, consider exploring:

    Advanced Prometheus query language (PromQL) for complex metrics analysis
    Integration with external alerting systems like PagerDuty or Slack
    Log aggregation with tools like Fluentd and Elasticsearch
    Distributed tracing with Jaeger or Zipkin
    Custom metric exporters for specific applications

This lab has provided you with a solid foundation in Kubernetes observability that will serve you well in your cloud-native journey and preparation for the Kubernetes and Cloud Native Associate (KCNA) certification.




Lab 19: Configuring and Using Service Mesh
Objectives

By the end of this lab, you will be able to:

• Deploy and configure Istio service mesh on a Kubernetes cluster • Understand service mesh architecture and components • Configure traffic routing and load balancing between microservices • Implement mutual TLS (mTLS) for secure service-to-service communication • Monitor and observe service mesh traffic using built-in tools • Apply traffic management policies including circuit breakers and retries
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (Pods, Services, Deployments) • Familiarity with kubectl command-line tool • Knowledge of YAML configuration files • Understanding of microservices architecture • Basic networking concepts (HTTP, TLS, load balancing)
Lab Environment

Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with Kubernetes pre-installed. Simply click Start Lab to begin - no need to build your own VM or install additional software.

Your lab environment includes:

    Ubuntu 22.04 LTS with kubectl configured
    Kubernetes cluster (single-node for lab purposes)
    Internet connectivity for downloading Istio
    All necessary permissions configured

Task 1: Deploy Istio Service Mesh
Subtask 1.1: Download and Install Istio

First, we'll download and install Istio, one of the most popular service mesh solutions.

    Download Istio installation script:

curl -L https://istio.io/downloadIstio | sh -

    Navigate to Istio directory and add istioctl to PATH:

cd istio-*
export PATH=$PWD/bin:$PATH

    Verify istioctl installation:

istioctl version

Subtask 1.2: Install Istio on Kubernetes Cluster

    Install Istio with default configuration profile:

istioctl install --set values.defaultRevision=default

    Verify Istio installation:

kubectl get pods -n istio-system

You should see pods like istiod, istio-proxy, and others running.

    Enable automatic sidecar injection for default namespace:

kubectl label namespace default istio-injection=enabled

    Verify namespace labeling:

kubectl get namespace -L istio-injection

Subtask 1.3: Deploy Sample Application

We'll deploy a sample bookinfo application to demonstrate service mesh capabilities.

    Deploy the Bookinfo application:

kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

    Verify all services and pods are running:

kubectl get services
kubectl get pods

Wait until all pods show status Running and Ready 2/2 (indicating both application and sidecar containers are running).

    Create Istio Gateway and VirtualService:

kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

    Get the external IP of Istio ingress gateway:

kubectl get svc istio-ingressgateway -n istio-system

Task 2: Configure Traffic Routing and Load Balancing
Subtask 2.1: Create Multiple Versions of a Service

    Deploy different versions of the reviews service:

kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

    Create destination rules for traffic management:

Create a file called destination-rule.yaml:

apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews
spec:
  host: reviews
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
  - name: v3
    labels:
      version: v3

    Apply the destination rule:

kubectl apply -f destination-rule.yaml

Subtask 2.2: Configure Traffic Splitting

    Create a VirtualService for traffic splitting:

Create a file called reviews-virtual-service.yaml:

apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  http:
  - match:
    - headers:
        end-user:
          exact: jason
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v1
      weight: 50
    - destination:
        host: reviews
        subset: v3
      weight: 50

    Apply the VirtualService:

kubectl apply -f reviews-virtual-service.yaml

    Test traffic routing:

# Get the gateway URL
export GATEWAY_URL=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test the application multiple times
for i in {1..10}; do
  curl -s "http://$GATEWAY_URL/productpage" | grep -o "glyphicon-star\|color:red"
done

Subtask 2.3: Implement Load Balancing Policies

    Create advanced destination rule with load balancing:

Create a file called advanced-destination-rule.yaml:

apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews-lb
spec:
  host: reviews
  trafficPolicy:
    loadBalancer:
      simple: LEAST_CONN
    connectionPool:
      tcp:
        maxConnections: 10
      http:
        http1MaxPendingRequests: 10
        maxRequestsPerConnection: 2
    circuitBreaker:
      consecutiveErrors: 3
      interval: 30s
      baseEjectionTime: 30s
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
  - name: v3
    labels:
      version: v3

    Apply the advanced destination rule:

kubectl apply -f advanced-destination-rule.yaml

Task 3: Implement Mutual TLS (mTLS)
Subtask 3.1: Enable Automatic mTLS

    Check current mTLS status:

istioctl authn tls-check productpage.default.svc.cluster.local

    Create PeerAuthentication policy for strict mTLS:

Create a file called peer-authentication.yaml:

apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: default
spec:
  mtls:
    mode: STRICT

    Apply the PeerAuthentication policy:

kubectl apply -f peer-authentication.yaml

Subtask 3.2: Verify mTLS Configuration

    Check mTLS status after applying policy:

istioctl authn tls-check productpage.default.svc.cluster.local

    Verify mTLS is working by checking proxy configuration:

istioctl proxy-config cluster productpage-v1-<pod-id>.default --fqdn reviews.default.svc.cluster.local

Replace <pod-id> with actual pod ID from kubectl get pods.

    Test secure communication:

# Deploy a test pod without Istio sidecar
kubectl create namespace test
kubectl run test-pod --image=curlimages/curl -n test --rm -it --restart=Never -- sh

# Try to access the service (should fail due to mTLS)
curl http://productpage.default.svc.cluster.local:9080/productpage

Subtask 3.3: Configure Authorization Policies

    Create AuthorizationPolicy for service access control:

Create a file called authorization-policy.yaml:

apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: productpage-viewer
  namespace: default
spec:
  selector:
    matchLabels:
      app: productpage
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/default/sa/bookinfo-productpage"]
  - to:
    - operation:
        methods: ["GET"]

    Apply the authorization policy:

kubectl apply -f authorization-policy.yaml

Task 4: Monitor and Observe Service Mesh Traffic
Subtask 4.1: Install Observability Add-ons

    Install Kiali, Prometheus, and Grafana:

kubectl apply -f samples/addons/kiali.yaml
kubectl apply -f samples/addons/prometheus.yaml
kubectl apply -f samples/addons/grafana.yaml
kubectl apply -f samples/addons/jaeger.yaml

    Wait for all observability pods to be ready:

kubectl get pods -n istio-system

Subtask 4.2: Generate Traffic and Monitor

    Generate continuous traffic to the application:

# Run this in a separate terminal
while true; do
  curl -s "http://$GATEWAY_URL/productpage" > /dev/null
  sleep 1
done

    Access Kiali dashboard:

kubectl port-forward -n istio-system svc/kiali 20001:20001

Open browser and navigate to http://localhost:20001 (username: admin, password: admin)

    Access Grafana dashboard:

kubectl port-forward -n istio-system svc/grafana 3000:3000

Open browser and navigate to http://localhost:3000
Subtask 4.3: Analyze Service Mesh Metrics

    View service topology in Kiali:
        Navigate to Graph section
        Select default namespace
        Observe service communication patterns

    Check Istio metrics in Grafana:
        Go to Dashboards → Istio
        Explore Istio Service Dashboard
        Analyze request rates, error rates, and latencies

    Use istioctl for proxy analysis:

# Check proxy configuration
istioctl proxy-config cluster productpage-v1-<pod-id>.default

# Check listeners
istioctl proxy-config listener productpage-v1-<pod-id>.default

# Check routes
istioctl proxy-config route productpage-v1-<pod-id>.default

Task 5: Advanced Traffic Management
Subtask 5.1: Implement Fault Injection

    Create fault injection policy:

Create a file called fault-injection.yaml:

apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews-fault
spec:
  http:
  - fault:
      delay:
        percentage:
          value: 50
        fixedDelay: 5s
      abort:
        percentage:
          value: 10
        httpStatus: 500
    match:
    - headers:
        end-user:
          exact: jason
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v1

    Apply fault injection:

kubectl apply -f fault-injection.yaml

    Test fault injection:

# Test with jason user (should experience delays and errors)
curl -H "end-user: jason" "http://$GATEWAY_URL/productpage"

Subtask 5.2: Configure Timeout and Retry Policies

    Create timeout and retry configuration:

Create a file called timeout-retry.yaml:

apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews-timeout
spec:
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
    timeout: 3s
    retries:
      attempts: 3
      perTryTimeout: 1s

    Apply timeout and retry policy:

kubectl apply -f timeout-retry.yaml

Troubleshooting Tips
Common Issues and Solutions

    Pods not showing 2/2 ready status:
        Check if namespace has istio-injection label
        Restart pods after enabling injection: kubectl rollout restart deployment/productpage-v1

    Cannot access application through gateway:
        Verify gateway and virtual service configuration
        Check if LoadBalancer service has external IP assigned

    mTLS not working:
        Ensure PeerAuthentication policy is applied correctly
        Check proxy configuration with istioctl commands

    Observability tools not accessible:
        Verify all add-on pods are running
        Check port-forward commands are correct

Verification Commands

# Check Istio installation
istioctl verify-install

# Check proxy status
istioctl proxy-status

# Analyze configuration
istioctl analyze

# Check mTLS status
istioctl authn tls-check <service-name>

Cleanup

To clean up the lab environment:

# Remove sample application
kubectl delete -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl delete -f samples/bookinfo/networking/bookinfo-gateway.yaml

# Remove custom configurations
kubectl delete -f destination-rule.yaml
kubectl delete -f reviews-virtual-service.yaml
kubectl delete -f peer-authentication.yaml
kubectl delete -f authorization-policy.yaml

# Remove observability add-ons
kubectl delete -f samples/addons/

# Uninstall Istio
istioctl uninstall --purge
kubectl delete namespace istio-system

Conclusion

In this comprehensive lab, you have successfully:

• Deployed Istio service mesh on a Kubernetes cluster and understood its core components • Configured advanced traffic management including routing, load balancing, and traffic splitting • Implemented mutual TLS (mTLS) for secure service-to-service communication • Applied authorization policies to control access between services • Set up observability tools like Kiali, Prometheus, and Grafana for monitoring • Implemented fault injection and resilience patterns including timeouts and retries

Why This Matters: Service mesh technology is crucial for managing complex microservices architectures in production environments. The skills you've learned enable you to:

    Secure communication between services without modifying application code
    Implement sophisticated traffic management and deployment strategies
    Gain deep visibility into service behavior and performance
    Build resilient applications with automatic retry and circuit breaker patterns

These capabilities are essential for cloud-native applications and are highly valued in the industry, particularly for roles involving Kubernetes, DevOps, and cloud architecture. The knowledge gained in this lab directly supports preparation for the Kubernetes and Cloud Native Associate (KCNA) certification and real-world microservices deployments.




Lab 20: Exploring Cloud Native Application Delivery with GitOps
Objectives

By the end of this lab, you will be able to:

• Understand the core principles and benefits of GitOps methodology • Install and configure ArgoCD as a GitOps tool in a Kubernetes cluster • Create and structure a Git repository for Kubernetes manifests • Deploy applications using GitOps workflows • Observe automatic synchronization between Git repository changes and cluster state • Update applications through Git commits and monitor the deployment process • Troubleshoot common GitOps deployment issues
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (pods, services, deployments) • Familiarity with Git version control system • Basic knowledge of YAML syntax • Understanding of container concepts and Docker • Access to command-line interface (CLI) tools
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with all necessary tools pre-installed. Simply click Start Lab to begin - no need to build your own VM or install additional software.

Your lab environment includes: • Ubuntu 20.04 LTS with kubectl pre-installed • Minikube for local Kubernetes cluster • Git client configured and ready to use • Text editor (nano/vim) for file editing
Task 1: Understanding GitOps and Setting Up the Environment
Subtask 1.1: Start Your Kubernetes Cluster

First, let's start our local Kubernetes cluster using Minikube:

# Start Minikube cluster
minikube start --driver=docker --memory=4096 --cpus=2

# Verify cluster is running
kubectl cluster-info

# Check node status
kubectl get nodes

Subtask 1.2: Create Namespace for ArgoCD

Create a dedicated namespace for ArgoCD installation:

# Create argocd namespace
kubectl create namespace argocd

# Verify namespace creation
kubectl get namespaces

Task 2: Installing and Configuring ArgoCD
Subtask 2.1: Install ArgoCD

Install ArgoCD using the official installation manifests:

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for all pods to be ready (this may take 2-3 minutes)
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Check ArgoCD pods status
kubectl get pods -n argocd

Subtask 2.2: Access ArgoCD UI

Set up port forwarding to access the ArgoCD web interface:

# Port forward ArgoCD server (run this in background)
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

Note: Save the password output - you'll need it to log into ArgoCD UI.
Subtask 2.3: Install ArgoCD CLI

Install the ArgoCD command-line interface:

# Download ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

# Make it executable and move to PATH
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd

# Verify installation
argocd version --client

Subtask 2.4: Login to ArgoCD

Login to ArgoCD using the CLI:

# Login to ArgoCD (use the password from step 2.2)
argocd login localhost:8080 --username admin --password <your-password> --insecure

# Verify login
argocd account get-user-info

Task 3: Creating Git Repository for Kubernetes Manifests
Subtask 3.1: Initialize Local Git Repository

Create a local Git repository to store your Kubernetes manifests:

# Create project directory
mkdir ~/gitops-demo
cd ~/gitops-demo

# Initialize Git repository
git init

# Configure Git user (if not already configured)
git config user.name "GitOps Student"
git config user.email "student@example.com"

Subtask 3.2: Create Application Manifests

Create a sample application with Kubernetes manifests:

# Create application directory structure
mkdir -p apps/sample-app

# Create deployment manifest
cat > apps/sample-app/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  labels:
    app: sample-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
      - name: sample-app
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
EOF

# Create service manifest
cat > apps/sample-app/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: sample-app-service
  labels:
    app: sample-app
spec:
  selector:
    app: sample-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
EOF

# Create namespace manifest
cat > apps/sample-app/namespace.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: sample-app
EOF

Subtask 3.3: Commit Initial Manifests

Commit your manifests to the Git repository:

# Add files to Git
git add .

# Commit changes
git commit -m "Initial commit: Add sample application manifests"

# View commit history
git log --oneline

Task 4: Integrating Git Repository with ArgoCD
Subtask 4.1: Create ArgoCD Application

Create an ArgoCD application that monitors your Git repository:

# Create ArgoCD application manifest
cat > argocd-app.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: file:///home/student/gitops-demo
    targetRevision: HEAD
    path: apps/sample-app
  destination:
    server: https://kubernetes.default.svc
    namespace: sample-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

# Apply the ArgoCD application
kubectl apply -f argocd-app.yaml

Subtask 4.2: Verify Application Creation

Check that your application was created successfully in ArgoCD:

# List ArgoCD applications
argocd app list

# Get detailed application information
argocd app get sample-app

# Check application status
argocd app status sample-app

Task 5: Deploying Applications Through GitOps
Subtask 5.1: Sync Application

Manually trigger the first synchronization:

# Sync the application
argocd app sync sample-app

# Wait for sync to complete
argocd app wait sample-app --timeout 300

Subtask 5.2: Verify Deployment

Verify that your application has been deployed to the cluster:

# Check if namespace was created
kubectl get namespaces

# Check pods in sample-app namespace
kubectl get pods -n sample-app

# Check services
kubectl get services -n sample-app

# Check deployment status
kubectl get deployments -n sample-app

Subtask 5.3: Test Application Connectivity

Test that your application is running correctly:

# Port forward to test the application
kubectl port-forward -n sample-app svc/sample-app-service 8081:80 &

# Test the application (in a new terminal or after a few seconds)
curl http://localhost:8081

# Stop port forwarding
pkill -f "kubectl port-forward"

Task 6: Updating Applications Through Git Commits
Subtask 6.1: Modify Application Configuration

Update the application by changing the replica count:

# Navigate to repository directory
cd ~/gitops-demo

# Update deployment to use 3 replicas
sed -i 's/replicas: 2/replicas: 3/' apps/sample-app/deployment.yaml

# Verify the change
grep "replicas:" apps/sample-app/deployment.yaml

Subtask 6.2: Update Container Image

Update the nginx image version:

# Update nginx image version
sed -i 's/nginx:1.21/nginx:1.22/' apps/sample-app/deployment.yaml

# Verify the change
grep "image:" apps/sample-app/deployment.yaml

Subtask 6.3: Commit Changes

Commit your changes to trigger GitOps synchronization:

# Add changes to Git
git add apps/sample-app/deployment.yaml

# Commit changes
git commit -m "Update: Increase replicas to 3 and upgrade nginx to 1.22"

# View commit history
git log --oneline -n 3

Task 7: Observing Synchronization Process
Subtask 7.1: Monitor ArgoCD Synchronization

Watch ArgoCD automatically detect and sync the changes:

# Check application status
argocd app get sample-app

# Watch the sync process (press Ctrl+C to stop)
watch -n 2 'argocd app get sample-app | grep -E "(Health|Sync)"'

Subtask 7.2: Verify Changes in Cluster

Confirm that changes have been applied to the cluster:

# Check if replicas increased to 3
kubectl get pods -n sample-app

# Check deployment details
kubectl describe deployment sample-app -n sample-app | grep -E "(Replicas|Image)"

# Verify image version
kubectl get deployment sample-app -n sample-app -o jsonpath='{.spec.template.spec.containers[0].image}'
echo

Subtask 7.3: View Synchronization History

Check the synchronization history in ArgoCD:

# View application history
argocd app history sample-app

# Get detailed sync information
argocd app get sample-app --show-operation

Task 8: Advanced GitOps Operations
Subtask 8.1: Add ConfigMap to Application

Create a ConfigMap for application configuration:

# Create ConfigMap manifest
cat > apps/sample-app/configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: sample-app-config
  namespace: sample-app
data:
  app.properties: |
    environment=production
    debug=false
    max_connections=100
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <title>GitOps Demo App</title>
    </head>
    <body>
        <h1>Welcome to GitOps Demo!</h1>
        <p>This application was deployed using GitOps with ArgoCD.</p>
        <p>Version: 2.0</p>
    </body>
    </html>
EOF

Subtask 8.2: Update Deployment to Use ConfigMap

Modify the deployment to mount the ConfigMap:

# Update deployment to include ConfigMap volume
cat > apps/sample-app/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  labels:
    app: sample-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
      - name: sample-app
        image: nginx:1.22
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        volumeMounts:
        - name: config-volume
          mountPath: /usr/share/nginx/html/index.html
          subPath: index.html
      volumes:
      - name: config-volume
        configMap:
          name: sample-app-config
EOF

Subtask 8.3: Commit and Observe Changes

Commit the new changes and observe the synchronization:

# Add all changes
git add .

# Commit changes
git commit -m "Add ConfigMap and update deployment to use custom index.html"

# Monitor the sync process
argocd app sync sample-app

# Wait for sync completion
argocd app wait sample-app

Subtask 8.4: Test Updated Application

Test the updated application with custom content:

# Port forward to test updated application
kubectl port-forward -n sample-app svc/sample-app-service 8082:80 &

# Test the updated application
curl http://localhost:8082

# Clean up port forwarding
pkill -f "kubectl port-forward"

Task 9: Troubleshooting GitOps Deployments
Subtask 9.1: Simulate a Deployment Issue

Create a problematic manifest to see how ArgoCD handles errors:

# Create a deployment with invalid image
cat > apps/sample-app/broken-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: broken-app
  labels:
    app: broken-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: broken-app
  template:
    metadata:
      labels:
        app: broken-app
    spec:
      containers:
      - name: broken-app
        image: nonexistent-image:latest
        ports:
        - containerPort: 80
EOF

# Commit the problematic manifest
git add apps/sample-app/broken-deployment.yaml
git commit -m "Add broken deployment for troubleshooting demo"

Subtask 9.2: Observe Error Handling

Watch how ArgoCD handles the deployment error:

# Check application status
argocd app get sample-app

# View detailed error information
kubectl get events -n sample-app --sort-by='.lastTimestamp'

# Check pod status
kubectl get pods -n sample-app

Subtask 9.3: Fix the Issue

Remove the problematic manifest and restore normal operation:

# Remove the broken deployment file
rm apps/sample-app/broken-deployment.yaml

# Commit the fix
git add -A
git commit -m "Remove broken deployment manifest"

# Sync the application
argocd app sync sample-app

Task 10: Monitoring and Observability
Subtask 10.1: View Application Metrics

Check ArgoCD's built-in monitoring capabilities:

# Get application resource usage
kubectl top pods -n sample-app

# View application logs
kubectl logs -n sample-app -l app=sample-app --tail=20

# Check application health
argocd app get sample-app --show-params

Subtask 10.2: Set Up Application Health Checks

Add health check configuration to your application:

# Update deployment with health checks
cat > apps/sample-app/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  labels:
    app: sample-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
      - name: sample-app
        image: nginx:1.22
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: config-volume
          mountPath: /usr/share/nginx/html/index.html
          subPath: index.html
      volumes:
      - name: config-volume
        configMap:
          name: sample-app-config
EOF

# Commit health check updates
git add apps/sample-app/deployment.yaml
git commit -m "Add liveness and readiness probes to deployment"

Cleanup
Clean Up Resources

Remove all resources created during the lab:

# Delete ArgoCD application
argocd app delete sample-app --cascade

# Delete sample-app namespace
kubectl delete namespace sample-app

# Delete ArgoCD namespace (optional)
kubectl delete namespace argocd

# Stop Minikube
minikube stop

Troubleshooting Common Issues
Issue 1: ArgoCD Pods Not Starting

Problem: ArgoCD pods remain in Pending or CrashLoopBackOff state.

Solution:

# Check pod events
kubectl describe pods -n argocd

# Ensure sufficient resources
minikube config set memory 4096
minikube config set cpus 2
minikube delete && minikube start

Issue 2: Application Not Syncing

Problem: ArgoCD application shows "OutOfSync" status but doesn't sync automatically.

Solution:

# Check application configuration
argocd app get sample-app

# Manual sync
argocd app sync sample-app --force

# Check sync policy
kubectl get application sample-app -n argocd -o yaml

Issue 3: Git Repository Access Issues

Problem: ArgoCD cannot access the local Git repository.

Solution:

# Ensure correct repository path
pwd
ls -la ~/gitops-demo

# Check ArgoCD application source configuration
argocd app get sample-app | grep -A 5 "Source:"

Conclusion

Congratulations! You have successfully completed the GitOps lab using ArgoCD. Here's what you accomplished:

Key Achievements: • Installed and configured ArgoCD as a GitOps tool in your Kubernetes cluster • Created a structured Git repository with Kubernetes manifests for application deployment • Implemented GitOps workflows that automatically sync cluster state with Git repository changes • Deployed and updated applications through Git commits, observing the complete synchronization process • Learned troubleshooting techniques for common GitOps deployment issues • Implemented monitoring and health checks for cloud-native applications

Why This Matters: GitOps represents a paradigm shift in how we deploy and manage cloud-native applications. By treating Git as the single source of truth for your infrastructure and applications, you achieve:

• Improved Security: All changes go through Git's audit trail and review process • Better Reliability: Declarative configurations ensure consistent deployments • Enhanced Collaboration: Teams can collaborate using familiar Git workflows • Faster Recovery: Easy rollbacks through Git history • Compliance: Complete audit trail of all infrastructure changes

Real-World Applications: The skills you've learned are directly applicable to: • Enterprise DevOps pipelines using tools like ArgoCD, Flux, or Jenkins X • Multi-environment deployments (development, staging, production) • Microservices architectures with independent service deployments • Infrastructure as Code practices with Kubernetes • Continuous deployment in cloud-native environments

This lab has prepared you for the Kubernetes and Cloud Native Associate (KCNA) certification by providing hands-on experience with GitOps principles and practices that are essential in modern cloud-native development workflows.







---

## 🎓 Learning Path & Tips

### Study Schedule
- **Week 1:** Labs 1-5 (Foundations)
- **Week 2:** Labs 6-10 (Core Concepts)
- **Week 3:** Labs 11-15 (Advanced Topics)
- **Week 4:** Labs 16-20 (Production Skills)

### Exam Preparation Tips
1. ✅ Practice all kubectl commands without looking
2. ✅ Understand Kubernetes architecture thoroughly
3. ✅ Review CNCF landscape and cloud-native concepts
4. ✅ Take practice exams
5. ✅ Join Kubernetes community forums
6. ✅ Review official documentation regularly

### Key Topics for KCNA
- Kubernetes architecture and components
- Container orchestration fundamentals
- Cloud-native architecture principles
- Kubernetes API and objects
- Services and networking
- Storage and persistence
- Security basics
- Observability fundamentals

---

## 🚀 Next Steps After KCNA

1. **CKA** - Certified Kubernetes Administrator
2. **CKAD** - Certified Kubernetes Application Developer  
3. **CKS** - Certified Kubernetes Security Specialist

---

**Created by:** Saleem Ali  
**Institution:** Al-Nafi International College (AIOps Program)  
**Date:** January 2026  
**Status:** ✅ Complete & Production-Ready
