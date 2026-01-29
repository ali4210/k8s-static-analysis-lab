# 🚀 KCNA Lab 1: Exploring Container Orchestration

> **Complete Interactive Lab Guide - NOTHING SKIPPED!**  
> **Prepared for:** Saleem Ali  
> **Duration:** 2-3 hours  
> **Difficulty:** Beginner to Intermediate

---

## 📋 Table of Contents

- [Objectives](#objectives)
- [Prerequisites](#prerequisites)
- [Lab Environment Setup](#lab-environment-setup)
- [Task 1: Deploy Two Containerized Applications Manually](#task-1-deploy-two-containerized-applications-manually)
- [Task 2: Simulate Scaling and Failure Scenarios](#task-2-simulate-scaling-and-failure-scenarios)
- [Task 3: Document and Analyze Challenges](#task-3-document-and-analyze-challenges)
- [Task 4: Demonstrate Orchestration Benefits](#task-4-demonstrate-orchestration-benefits)
- [Troubleshooting](#troubleshooting)
- [Conclusion](#conclusion)
- [Key Takeaways](#key-takeaways)

---

## 🎯 Objectives

By the end of this lab, students will be able to:

- ✅ Understand the challenges of manually managing containerized applications
- ✅ Deploy multiple containerized applications without orchestration tools
- ✅ Identify and experience common issues such as port conflicts and resource management problems
- ✅ Simulate scaling scenarios and observe manual intervention requirements
- ✅ Analyze failure scenarios and recovery challenges in non-orchestrated environments
- ✅ Explain how container orchestration platforms address these operational challenges
- ✅ Compare manual container management with orchestrated solutions

---

## ✅ Prerequisites

Before starting this lab, students should have:

- ✅ Basic understanding of Linux command line operations
- ✅ Fundamental knowledge of Docker containers and basic Docker commands
- ✅ Understanding of networking concepts (ports, IP addresses)
- ✅ Familiarity with text editors (nano, vim, or similar)
- ✅ Basic knowledge of web applications and HTTP protocols

---

## 🖥️ Lab Environment Setup

### Ready-to-Use Cloud Machines

**Al Nafi** provides pre-configured Linux-based cloud machines with Docker already installed. Simply click **Start Lab** to access your environment - no need to build your own VM or install Docker manually.

Your lab environment includes:

- ✅ **Ubuntu 20.04 LTS** with Docker Engine installed
- ✅ Pre-configured user with sudo privileges
- ✅ Network access for downloading container images
- ✅ Multiple terminal sessions available

---

## 🔧 Task 1: Deploy Two Containerized Applications Manually

### 📌 Subtask 1.1: Verify Docker Installation and Prepare Environment

First, let's verify that Docker is properly installed and running on your system.

#### Check Docker Version

```bash
docker --version
```

#### Check Docker Service Status

```bash
sudo systemctl status docker
```

#### Verify Docker is Running

```bash
docker ps
```

#### Create Lab Directory Structure

```bash
# Create lab directory
mkdir ~/container-orchestration-lab
cd ~/container-orchestration-lab

# Create subdirectories for our applications
mkdir app1 app2
```

---

### 📌 Subtask 1.2: Deploy First Application - Web Server

We'll deploy a simple nginx web server as our first application.

#### Pull Nginx Image

```bash
docker pull nginx:latest
```

#### Run First Nginx Container

```bash
docker run -d \
  --name web-app-1 \
  -p 8080:80 \
  nginx:latest
```

#### Verify Container is Running

```bash
docker ps
```

#### Test the Application

```bash
curl http://localhost:8080
```

---

### 🎨 Create Custom HTML Page

```bash
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
```

#### Copy Custom Content to Container

```bash
docker cp ~/container-orchestration-lab/app1/index.html web-app-1:/usr/share/nginx/html/index.html
```

#### Verify Custom Content

```bash
curl http://localhost:8080
```

---

### 📌 Subtask 1.3: Deploy Second Application - Another Web Server

Now let's deploy a second web application and observe port conflict issues.

#### ❌ Attempt to Run on Same Port (THIS WILL FAIL!)

```bash
docker run -d \
  --name web-app-2 \
  -p 8080:80 \
  nginx:latest
```

**Expected Result:** This command will fail with a port binding error. This demonstrates our first challenge - **port conflicts**.

#### Check Error Message

```bash
docker logs web-app-2
```

#### ✅ Run Second Container on Different Port

```bash
docker run -d \
  --name web-app-2-fixed \
  -p 8081:80 \
  nginx:latest
```

#### Verify Both Containers Running

```bash
docker ps
```

---

### 🎨 Create Custom Content for Second Application

```bash
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
```

#### Copy Custom Content to Second Container

```bash
docker cp ~/container-orchestration-lab/app2/index.html web-app-2-fixed:/usr/share/nginx/html/index.html
```

#### Test Both Applications

```bash
echo "Testing Application 1:"
curl http://localhost:8080

echo -e "\nTesting Application 2:"
curl http://localhost:8081
```

---

### 📌 Subtask 1.4: Analyze Resource Management Challenges

Let's examine resource usage and management challenges.

#### Check Resource Usage

```bash
docker stats --no-stream
```

#### Check Detailed Container Information

```bash
docker inspect web-app-1 | grep -A 10 "Memory"
docker inspect web-app-2-fixed | grep -A 10 "Memory"
```

#### Run Container with Resource Limits

```bash
docker run -d \
  --name web-app-3-limited \
  --memory="128m" \
  --cpus="0.5" \
  -p 8082:80 \
  nginx:latest
```

#### Compare Resource Usage

```bash
docker stats --no-stream web-app-1 web-app-2-fixed web-app-3-limited
```

---

### 📊 Create Monitoring Script

```bash
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
```

#### Make Script Executable

```bash
chmod +x ~/container-orchestration-lab/monitor.sh
```

#### Run Monitoring Script

```bash
./monitor.sh
# Let it run for 30 seconds, then stop with Ctrl+C
```

---

## 🔄 Task 2: Simulate Scaling and Failure Scenarios

### 📌 Subtask 2.1: Manual Scaling Challenges

Let's simulate the need to scale our applications and observe the manual effort required.

#### Create Scaling Script

```bash
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
```

#### Make Script Executable and Run

```bash
chmod +x ~/container-orchestration-lab/scale-app.sh
./scale-app.sh
```

---

### 🧪 Test All Scaled Instances

```bash
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
```

---

### 📌 Subtask 2.2: Simulate Container Failures

Let's simulate container failures and observe the manual recovery process.

#### Simulate Failures

```bash
echo "Simulating container failures..."
docker stop web-app-instance-2 web-app-instance-4
```

#### Check Running Containers

```bash
docker ps | grep web-app-instance
```

#### Test Instances to See Failures

```bash
./test-instances.sh
```

#### Manual Recovery Process

```bash
echo "Manual recovery process:"
echo "1. Identify failed containers"
docker ps -a | grep web-app-instance | grep Exited

echo "2. Restart failed containers manually"
docker start web-app-instance-2
docker start web-app-instance-4

echo "3. Verify recovery"
./test-instances.sh
```

---

### 📌 Subtask 2.3: Load Balancing Challenges

Without orchestration, load balancing requires manual configuration. Let's explore this challenge.

#### Install Nginx for Load Balancing

```bash
sudo apt-get update
sudo apt-get install -y nginx
```

#### Create Load Balancer Configuration

```bash
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
```

#### Enable Configuration

```bash
sudo ln -sf /etc/nginx/sites-available/load-balancer /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
```

#### Test and Restart Nginx

```bash
sudo nginx -t
sudo systemctl restart nginx
```

#### Test Load Balancing

```bash
echo "Testing load balancer:"
for i in {1..10}; do
    echo "Request $i:"
    curl -s http://localhost | grep -o "Welcome to.*" || echo "Failed"
    sleep 1
done
```

---

## 📊 Task 3: Document and Analyze Challenges

### 📌 Subtask 3.1: Create Challenge Documentation

Let's document all the challenges we've encountered:

```bash
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

cat ~/container-orchestration-lab/challenges-report.md
```

---

### 📌 Subtask 3.2: Performance Impact Analysis

Let's measure the performance impact of our manual setup:

```bash
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
```

---

## 🌟 Task 4: Demonstrate Orchestration Benefits

### 📌 Subtask 4.1: Compare with Orchestration Concepts

Let's create a comparison document showing how orchestration would solve our challenges:

```bash
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
- **Example**: \`kubectl scale deployment myapp --replicas=10\`

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
| Scaling | Manual scripts | \`docker service scale\` | \`kubectl scale\` |
| Load Balancing | External setup | Built-in | Built-in |
| Self-Healing | Manual restart | Automatic | Automatic |
| Rolling Updates | Manual process | \`docker service update\` | \`kubectl rollout\` |
| Service Discovery | Hard-coded IPs | Built-in | DNS-based |
| Configuration | Individual setup | Docker configs | ConfigMaps/Secrets |
EOF

cat ~/container-orchestration-lab/orchestration-benefits.md
```

---

### 📌 Subtask 4.2: Cleanup and Resource Management

Let's clean up our manual deployment and observe the effort required:

```bash
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
```

---

## 🆘 Troubleshooting

### Issue 1: Port Already in Use

```bash
# Check what's using a port
sudo netstat -tulpn | grep :8080

# Kill process using port (if needed)
sudo fuser -k 8080/tcp
```

### Issue 2: Docker Service Not Running

```bash
# Start Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker
```

### Issue 3: Permission Denied

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login again, or use:
newgrp docker
```

### Issue 4: Container Won't Start

```bash
# Check container logs
docker logs <container-name>

# Check container configuration
docker inspect <container-name>
```

---

## 🎓 Conclusion

In this lab, you have successfully:

### ✅ Experienced Manual Container Management
You deployed multiple containerized applications manually and encountered real-world challenges including port conflicts, resource management issues, and scaling difficulties.

### ✅ Identified Operational Challenges
Through hands-on experience, you discovered the complexity of managing containers without orchestration, including the need for manual intervention in failure scenarios and the time-consuming nature of scaling operations.

### ✅ Analyzed Performance Impact
You measured the performance implications of manual container management and documented the operational overhead required to maintain multiple container instances.

### ✅ Understood Orchestration Value
By comparing manual processes with orchestration capabilities, you now understand why container orchestration platforms like Kubernetes, Docker Swarm, and others are essential for production environments.

---

## 🔑 Key Takeaways

### Manual Management Challenges

- ❌ Port conflicts require careful planning and tracking
- ❌ Resource management needs constant monitoring
- ❌ Scaling is time-consuming and error-prone
- ❌ Failure recovery requires 24/7 monitoring
- ❌ Load balancing needs separate infrastructure
- ❌ Configuration management becomes complex at scale

### Orchestration Benefits

- ✅ Automatic port and resource management
- ✅ Declarative scaling with single commands
- ✅ Self-healing capabilities with zero-downtime recovery
- ✅ Built-in load balancing and service discovery
- ✅ Centralized configuration management
- ✅ Simplified deployment and update processes

### Why This Matters

**Container orchestration is not just a convenience—it's a necessity for production environments.** As you've experienced firsthand, managing even a few containers manually becomes complex quickly. In real-world scenarios with hundreds or thousands of containers, manual management is simply impossible.

This lab has prepared you for understanding container orchestration platforms by giving you practical experience with the problems they solve. You're now ready to appreciate the value that platforms like Kubernetes bring to modern application deployment and management.

The challenges you've encountered and documented in this lab directly relate to the **Kubernetes and Cloud Native Associate (KCNA)** certification objectives, particularly in understanding the problems that cloud-native technologies solve and the benefits of container orchestration in production environments.

---

<div align="center">

### 🌟 Excellent Work, Saleem! 🌟

**You've completed Lab 1 with ALL sections included!**

Ready for Lab 2: Introduction to Kubernetes? 🚀

---

**Created by:** Perplexity AI  
**For:** Saleem Ali  
**Date:** January 2026  
**Status:** ✅ COMPLETE - Nothing Skipped!

</div>

