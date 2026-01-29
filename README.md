
################################################################################
#                                                                              #
#           KCNA LAB 1: EXPLORING CONTAINER ORCHESTRATION                      #
#                                                                              #
#           Enhanced and Optimized for Hands-On Practice                       #
#           Prepared for: Saleem Ali                                           #
#           Date: January 2026                                                 #
#                                                                              #
################################################################################

================================================================================
TABLE OF CONTENTS
================================================================================

1. LAB OVERVIEW
   - Objectives
   - Prerequisites
   - Lab Environment Setup
   - Learning Outcomes

2. TASK 1: Deploy Two Containerized Applications Manually
   - Subtask 1.1: Verify Docker Installation and Prepare Environment
   - Subtask 1.2: Deploy First Application - Web Server
   - Subtask 1.3: Deploy Second Application - Another Web Server
   - Subtask 1.4: Analyze Resource Management Challenges
   - [ENHANCED] Advanced Networking and Inter-Container Communication

3. TASK 2: Simulate Scaling and Failure Scenarios
   - Subtask 2.1: Manual Scaling Challenges
   - Subtask 2.2: Simulate Container Failures
   - Subtask 2.3: Load Balancing Challenges
   - [ENHANCED] Advanced Load Testing and Health Monitoring

4. TASK 3: Document and Analyze Challenges
   - Subtask 3.1: Create Challenge Documentation
   - Subtask 3.2: Performance Impact Analysis
   - [ENHANCED] Metrics Comparison and Analysis

5. TASK 4: Demonstrate Orchestration Benefits
   - Subtask 4.1: Compare with Orchestration Concepts
   - Subtask 4.2: Practical Feature Comparison
   - [ENHANCED] Interactive Demos and Decision Matrix

6. TASK 5: Cleanup and Resource Management
   - Subtask 5.1: Clean Up Resources
   - [ENHANCED] Cleanup with Backup and Verification

7. TROUBLESHOOTING GUIDE
   - Common Issues and Solutions
   - Diagnostic Scripts
   - Best Practices

8. CONCLUSION
   - Key Takeaways
   - Next Steps
   - KCNA Certification Alignment

================================================================================
1. LAB OVERVIEW
================================================================================

OBJECTIVES
----------
By the end of this lab, you will be able to:

• Understand the challenges of manually managing containerized applications
• Deploy multiple containerized applications without orchestration tools
• Identify and experience common issues (port conflicts, resource management)
• Simulate scaling scenarios and observe manual intervention requirements
• Analyze failure scenarios and recovery challenges in non-orchestrated environments
• Explain how container orchestration platforms address operational challenges
• Compare manual container management with orchestrated solutions

PREREQUISITES
-------------
Before starting this lab, you should have:

• Basic understanding of Linux command line operations
• Fundamental knowledge of Docker containers and basic Docker commands
• Understanding of networking concepts (ports, IP addresses)
• Familiarity with text editors (nano, vim, or similar)
• Basic knowledge of web applications and HTTP protocols

LAB ENVIRONMENT SETUP
---------------------
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud 
machines with Docker already installed. Simply click "Start Lab" to access your 
environment.

Your lab environment includes:
• Ubuntu 20.04 LTS (or later) with Docker Engine installed
• Pre-configured user with sudo privileges
• Network access for downloading container images
• Multiple terminal sessions available

LEARNING OUTCOMES
-----------------
After completing this lab, you will:

✓ Have hands-on experience with manual container management
✓ Understand why orchestration is essential for production workloads
✓ Be prepared to appreciate Kubernetes and other orchestration platforms
✓ Have practical knowledge aligned with KCNA certification objectives

ESTIMATED TIME
--------------
• Core lab exercises: 90-120 minutes
• Optional advanced features: 30-45 minutes
• Total: 2-3 hours

================================================================================
2. TASK 1: DEPLOY TWO CONTAINERIZED APPLICATIONS MANUALLY
================================================================================

Subtask 1.1: Verify Docker Installation and Prepare Environment
----------------------------------------------------------------

First, let's verify that Docker is properly installed and running on your system.

# Check Docker version
docker --version

# Expected output: Docker version 20.10.x or higher

# Check Docker service status
sudo systemctl status docker

# If Docker is not running, start it
sudo systemctl start docker

# Enable Docker to start on system boot
sudo systemctl enable docker

# Verify Docker is running by listing containers
docker ps

# Expected output: Empty list (no containers running yet)

# Check Docker system information
docker info

# This shows detailed information about Docker installation

# Verify you can run Docker without sudo (user should be in docker group)
docker run hello-world

# If you get permission denied, add your user to docker group:
sudo usermod -aG docker $USER

# Then logout and login again, or run:
newgrp docker

Create a working directory for this lab:

# Create lab directory structure
mkdir -p ~/container-orchestration-lab
cd ~/container-orchestration-lab

# Create subdirectories for our applications
mkdir -p app1 app2 app3 logs scripts docs

# Verify directory structure
tree . || ls -la

# You should see:
# container-orchestration-lab/
# ├── app1/
# ├── app2/
# ├── app3/
# ├── logs/
# ├── scripts/
# └── docs/

# Set working directory
export LAB_DIR=~/container-orchestration-lab
echo "Lab directory: $LAB_DIR"

Subtask 1.2: Deploy First Application - Web Server
---------------------------------------------------

We'll deploy a simple nginx web server as our first application.

# Pull nginx image from Docker Hub
docker pull nginx:latest

# Verify image downloaded successfully
docker images | grep nginx

# Expected output:
# nginx    latest    xxx   xxx   xxxMB

# Run first nginx container on port 8080
docker run -d \
  --name web-app-1 \
  -p 8080:80 \
  nginx:latest

# Command explanation:
# -d              : Run in detached mode (background)
# --name          : Assign a name to the container
# -p 8080:80      : Map host port 8080 to container port 80
# nginx:latest    : Image to use

# Verify the container is running
docker ps

# Expected output shows container with STATUS "Up"

# Get detailed container information
docker inspect web-app-1

# Check container logs
docker logs web-app-1

# Test the application using curl
curl http://localhost:8080

# Expected: HTML content of nginx welcome page

# Alternative: Use wget if curl is not available
wget -qO- http://localhost:8080

# Check container resource usage
docker stats web-app-1 --no-stream

Create a custom HTML page for our first application:

# Create custom HTML content for App 1
cat > $LAB_DIR/app1/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Web Application 1</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 40px;
            max-width: 600px;
            width: 100%;
        }
        h1 { 
            color: #667eea;
            margin-bottom: 30px;
            text-align: center;
            font-size: 2.5em;
        }
        .info {
            background: #f7fafc;
            padding: 20px;
            border-radius: 10px;
            margin: 15px 0;
        }
        .info-item {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #e2e8f0;
        }
        .info-item:last-child {
            border-bottom: none;
        }
        .label {
            font-weight: 600;
            color: #4a5568;
        }
        .value {
            color: #667eea;
            font-family: 'Courier New', monospace;
        }
        .status {
            display: inline-block;
            padding: 5px 15px;
            background: #48bb78;
            color: white;
            border-radius: 20px;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Web Application 1</h1>
        <div class="info">
            <div class="info-item">
                <span class="label">Port:</span>
                <span class="value">8080</span>
            </div>
            <div class="info-item">
                <span class="label">Container:</span>
                <span class="value">web-app-1</span>
            </div>
            <div class="info-item">
                <span class="label">Status:</span>
                <span class="status">✓ Running</span>
            </div>
            <div class="info-item">
                <span class="label">Deployment:</span>
                <span class="value">Manual (No Orchestration)</span>
            </div>
            <div class="info-item">
                <span class="label">Timestamp:</span>
                <span class="value" id="timestamp"></span>
            </div>
        </div>
    </div>
    <script>
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF

# Copy custom content to running container
docker cp $LAB_DIR/app1/index.html web-app-1:/usr/share/nginx/html/index.html

# Verify custom content is served
curl http://localhost:8080 | grep "Web Application 1"

# Open in browser (if GUI available)
# Or use lynx for text-based browsing:
# lynx http://localhost:8080

# Inspect the container's network settings
docker inspect web-app-1 | grep -i ipaddress

# Get container IP
CONTAINER_IP=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' web-app-1)
echo "Container IP: $CONTAINER_IP"

Subtask 1.3: Deploy Second Application - Another Web Server
------------------------------------------------------------

Now let's deploy a second web application and observe port conflict issues.

# INTENTIONAL FAILURE - Attempt to run second container on same port
# This demonstrates the port conflict challenge
echo "Attempting to deploy second container on port 8080 (will fail)..."

docker run -d \
  --name web-app-2 \
  -p 8080:80 \
  nginx:latest

# Expected Result: ERROR - "Bind for 0.0.0.0:8080 failed: port is already allocated"

# Verify the error
docker ps -a | grep web-app-2

# Clean up the failed container attempt (if created)
docker rm web-app-2 2>/dev/null || echo "No failed container to remove"

# CORRECT APPROACH - Run second container on DIFFERENT port
echo "Deploying second container on port 8081..."

docker run -d \
  --name web-app-2 \
  -p 8081:80 \
  nginx:latest

# Verify both containers are running
docker ps

# Expected: Both web-app-1 and web-app-2 listed

# Check resource usage of both containers
docker stats --no-stream web-app-1 web-app-2

Create custom content for the second application:

# Create custom HTML for App 2 with different styling
cat > $LAB_DIR/app2/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Web Application 2</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 40px;
            max-width: 600px;
            width: 100%;
        }
        h1 { 
            color: #f5576c;
            margin-bottom: 30px;
            text-align: center;
            font-size: 2.5em;
        }
        .info {
            background: #fff5f7;
            padding: 20px;
            border-radius: 10px;
            margin: 15px 0;
        }
        .info-item {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #fce4ec;
        }
        .info-item:last-child {
            border-bottom: none;
        }
        .label {
            font-weight: 600;
            color: #4a5568;
        }
        .value {
            color: #f5576c;
            font-family: 'Courier New', monospace;
        }
        .status {
            display: inline-block;
            padding: 5px 15px;
            background: #48bb78;
            color: white;
            border-radius: 20px;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎯 Web Application 2</h1>
        <div class="info">
            <div class="info-item">
                <span class="label">Port:</span>
                <span class="value">8081</span>
            </div>
            <div class="info-item">
                <span class="label">Container:</span>
                <span class="value">web-app-2</span>
            </div>
            <div class="info-item">
                <span class="label">Status:</span>
                <span class="status">✓ Running</span>
            </div>
            <div class="info-item">
                <span class="label">Deployment:</span>
                <span class="value">Manual (No Orchestration)</span>
            </div>
            <div class="info-item">
                <span class="label">Timestamp:</span>
                <span class="value" id="timestamp"></span>
            </div>
        </div>
    </div>
    <script>
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF

# Copy custom content to second container
docker cp $LAB_DIR/app2/index.html web-app-2:/usr/share/nginx/html/index.html

# Test both applications
echo "=== Testing Application 1 (Port 8080) ==="
curl -s http://localhost:8080 | grep -o '<h1>.*</h1>'

echo ""
echo "=== Testing Application 2 (Port 8081) ==="
curl -s http://localhost:8081 | grep -o '<h1>.*</h1>'

# Verify both are accessible
echo ""
echo "=== HTTP Response Codes ==="
echo -n "App 1: HTTP "
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080
echo ""
echo -n "App 2: HTTP "
curl -s -o /dev/null -w "%{http_code}" http://localhost:8081
echo ""

Subtask 1.4: Analyze Resource Management Challenges
----------------------------------------------------

Let's examine resource usage and management challenges.

# Check real-time resource usage
docker stats --no-stream

# Check detailed memory information
echo "=== Memory Information ==="
docker inspect web-app-1 | grep -A 10 "Memory"
docker inspect web-app-2 | grep -A 10 "Memory"

# Notice: Without explicit limits, containers can use unlimited resources!

# Deploy a third container WITH resource limits
echo "Deploying App 3 with resource constraints..."

docker run -d \
  --name web-app-3-limited \
  --memory="128m" \
  --memory-reservation="64m" \
  --cpus="0.5" \
  -p 8082:80 \
  nginx:latest

# Resource limit explanation:
# --memory="128m"              : Hard limit - container killed if exceeded
# --memory-reservation="64m"   : Soft limit - container throttled if exceeded
# --cpus="0.5"                 : Limit to 50% of one CPU core

# Compare resource usage across all containers
echo "=== Resource Usage Comparison ==="
docker stats --no-stream web-app-1 web-app-2 web-app-3-limited

# Check which containers have resource limits
echo ""
echo "=== Container Resource Limits ==="
echo "Web-App-1 (no limits):"
docker inspect web-app-1 | jq '.[0].HostConfig.Memory, .[0].HostConfig.NanoCpus'

echo ""
echo "Web-App-3 (with limits):"
docker inspect web-app-3-limited | jq '.[0].HostConfig.Memory, .[0].HostConfig.NanoCpus'

# If jq not available, use grep:
# docker inspect web-app-3-limited | grep -E "Memory|NanoCpus"

Create a script to monitor resource usage:

# Create comprehensive monitoring script
cat > $LAB_DIR/scripts/monitor.sh << 'EOF'
#!/bin/bash

echo "Container Resource Monitoring"
echo "============================="
echo ""

while true; do
    clear
    echo "=== Container Resource Monitor ==="
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""

    echo "Container Status:"
    echo "----------------"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No containers running"

    echo ""
    echo "Resource Usage:"
    echo "---------------"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}" 2>/dev/null

    echo ""
    echo "Disk Usage:"
    echo "-----------"
    docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}\t{{.Reclaimable}}"

    echo ""
    echo "Press Ctrl+C to stop monitoring"
    echo "Refreshing in 5 seconds..."

    sleep 5
done
EOF

# Make script executable
chmod +x $LAB_DIR/scripts/monitor.sh

# Run monitoring (press Ctrl+C to stop)
echo "Starting resource monitor..."
echo "Press Ctrl+C after 30 seconds of monitoring"

# Run for limited time using timeout
timeout 30s $LAB_DIR/scripts/monitor.sh || echo "Monitor stopped"

# Alternative: Check resource usage once
echo ""
echo "=== Current Resource Snapshot ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

[ENHANCED SECTION - OPTIONAL ADVANCED FEATURES]
------------------------------------------------

# Advanced: Check network connectivity between containers
echo ""
echo "=== Network Analysis ==="

# List Docker networks
docker network ls

# Inspect the default bridge network
docker network inspect bridge | jq '.[0].Containers'

# Get IP addresses of all containers
echo ""
echo "Container IP Addresses:"
docker inspect -f '{{.Name}} - {{.NetworkSettings.IPAddress}}' $(docker ps -q)

# Test inter-container communication
WEB1_IP=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' web-app-1)
WEB2_IP=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' web-app-2)

echo ""
echo "Testing inter-container connectivity..."
echo "Web-App-1 IP: $WEB1_IP"
echo "Web-App-2 IP: $WEB2_IP"

# Test connectivity from web-app-2 to web-app-1
docker exec web-app-2 curl -s http://$WEB1_IP | grep -o '<h1>.*</h1>' && echo "✓ Can communicate" || echo "✗ Cannot communicate"

# Create custom bridge network for better isolation
docker network create --driver bridge app-network

# Note: In production, you'd attach containers to custom networks
# This is just an example - we'll keep containers on default bridge for this lab

================================================================================
3. TASK 2: SIMULATE SCALING AND FAILURE SCENARIOS
================================================================================

Subtask 2.1: Manual Scaling Challenges
---------------------------------------

Let's simulate the need to scale our applications and observe manual effort required.

# Create a script to deploy multiple instances
cat > $LAB_DIR/scripts/scale-app.sh << 'EOF'
#!/bin/bash

APP_NAME="web-app"
BASE_PORT=9000
INSTANCES=5

echo "Manual Scaling Script"
echo "===================="
echo "Deploying $INSTANCES instances of $APP_NAME..."
echo ""

# Track deployment time
START_TIME=$(date +%s)

for i in $(seq 1 $INSTANCES); do
    PORT=$((BASE_PORT + i))
    CONTAINER_NAME="${APP_NAME}-instance-${i}"

    echo -n "[$i/$INSTANCES] Deploying $CONTAINER_NAME on port $PORT... "

    # Deploy container
    docker run -d \
      --name $CONTAINER_NAME \
      -p $PORT:80 \
      --memory="128m" \
      --cpus="0.25" \
      nginx:latest >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "✓ Success"
    else
        echo "✗ Failed"
        # Check why it failed
        docker logs $CONTAINER_NAME 2>&1 | tail -n 3
    fi

    # Simulate human processing time
    sleep 2
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "Scaling completed in $DURATION seconds"
echo "Average time per instance: $((DURATION / INSTANCES)) seconds"
echo ""
echo "Verifying deployment..."
docker ps --filter name=web-app-instance --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
EOF

chmod +x $LAB_DIR/scripts/scale-app.sh

# Execute the scaling script
echo "Running manual scaling script..."
$LAB_DIR/scripts/scale-app.sh

# Verify all instances are running
echo ""
echo "=== All Running Instances ==="
docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}" | grep -E "NAMES|web-app"

# Count running instances
RUNNING_COUNT=$(docker ps --filter name=web-app-instance --format '{{.Names}}' | wc -l)
echo ""
echo "Total instances running: $RUNNING_COUNT/5"

Test all scaled instances:

# Create comprehensive testing script
cat > $LAB_DIR/scripts/test-instances.sh << 'EOF'
#!/bin/bash

echo "Application Instance Testing"
echo "============================"
echo ""

SUCCESS_COUNT=0
FAIL_COUNT=0

for port in {9001..9005}; do
    echo -n "Testing instance on port $port: "

    # Test HTTP response
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port 2>/dev/null)

    if [ "$response" = "200" ]; then
        echo "✓ OK (HTTP $response)"
        ((SUCCESS_COUNT++))
    else
        echo "✗ Failed (HTTP $response)"
        ((FAIL_COUNT++))
    fi
done

echo ""
echo "Test Summary:"
echo "  Success: $SUCCESS_COUNT"
echo "  Failed:  $FAIL_COUNT"
echo "  Total:   $((SUCCESS_COUNT + FAIL_COUNT))"

if [ $FAIL_COUNT -eq 0 ]; then
    echo "  Status: ✓ All tests passed"
else
    echo "  Status: ✗ Some tests failed"
fi
EOF

chmod +x $LAB_DIR/scripts/test-instances.sh

# Run tests
$LAB_DIR/scripts/test-instances.sh

Subtask 2.2: Simulate Container Failures
-----------------------------------------

Let's simulate container failures and observe the manual recovery process.

# Simulate failures by stopping containers
echo ""
echo "=== Simulating Container Failures ==="
echo "Stopping web-app-instance-2 and web-app-instance-4..."

docker stop web-app-instance-2 web-app-instance-4

echo "Containers stopped"
echo ""

# Check which containers are still running
echo "=== Container Status After Failure ==="
docker ps --filter name=web-app-instance --format "table {{.Names}}\t{{.Status}}"

echo ""
echo "=== Including Stopped Containers ==="
docker ps -a --filter name=web-app-instance --format "table {{.Names}}\t{{.Status}}"

# Test instances again to see failures
echo ""
$LAB_DIR/scripts/test-instances.sh

# Manual recovery process
echo ""
echo "=== Manual Recovery Process ==="
echo ""

echo "Step 1: Identify failed containers"
docker ps -a --filter name=web-app-instance --filter status=exited --format "table {{.Names}}\t{{.Status}}"

echo ""
echo "Step 2: Restart failed containers manually"
echo "Restarting web-app-instance-2..."
docker start web-app-instance-2

echo "Restarting web-app-instance-4..."
docker start web-app-instance-4

echo ""
echo "Step 3: Verify recovery"
sleep 3

# Check status
docker ps --filter name=web-app-instance --format "table {{.Names}}\t{{.Status}}"

echo ""
echo "Step 4: Test recovered instances"
$LAB_DIR/scripts/test-instances.sh

echo ""
echo "Recovery completed manually!"
echo "Note: This required manual intervention and time."
echo "Kubernetes would have done this automatically in seconds!"

Subtask 2.3: Load Balancing Challenges
---------------------------------------

Without orchestration, load balancing requires manual configuration.

# Check if nginx is already installed
if ! command -v nginx &> /dev/null; then
    echo "Installing nginx for load balancing..."
    sudo apt-get update -qq
    sudo apt-get install -y nginx
else
    echo "Nginx already installed"
fi

# Stop system nginx if running (to avoid conflicts)
sudo systemctl stop nginx 2>/dev/null || true

# Create nginx load balancer configuration
sudo tee /etc/nginx/sites-available/load-balancer << 'EOF'
upstream backend {
    # Define backend servers
    server localhost:9001;
    server localhost:9002;
    server localhost:9003;
    server localhost:9004;
    server localhost:9005;
}

server {
    listen 8888;
    server_name localhost;

    # Main application location
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Timeout settings
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Status page for monitoring
    location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        deny all;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Enable the configuration
sudo ln -sf /etc/nginx/sites-available/load-balancer /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
echo "Testing nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✓ Nginx configuration is valid"

    # Start nginx
    sudo systemctl start nginx

    # Check status
    sudo systemctl status nginx --no-pager | head -n 10

    echo ""
    echo "✓ Load balancer started successfully"
else
    echo "✗ Nginx configuration has errors"
    exit 1
fi

# Test load balancing
echo ""
echo "=== Testing Load Balancer ==="
echo "Sending 10 requests through load balancer..."
echo ""

for i in {1..10}; do
    echo -n "Request $i: "
    response=$(curl -s http://localhost:8888 | grep -o '<h1>.*</h1>' || echo "Response received")
    echo "$response"
    sleep 1
done

# Check nginx statistics
echo ""
echo "=== Nginx Load Balancer Statistics ==="
curl -s http://localhost:8888/nginx_status

# Check health
echo ""
echo "=== Health Check ==="
curl -s http://localhost:8888/health

[ENHANCED SECTION - OPTIONAL ADVANCED FEATURES]
------------------------------------------------

# Create advanced load testing script
cat > $LAB_DIR/scripts/load-test.sh << 'EOF'
#!/bin/bash

echo "Load Testing - Advanced"
echo "======================="
echo ""

REQUESTS=100
CONCURRENCY=10
URL="http://localhost:8888"

echo "Configuration:"
echo "  Target URL: $URL"
echo "  Total Requests: $REQUESTS"
echo "  Concurrent Connections: $CONCURRENCY"
echo ""

# Check if apache bench is available
if command -v ab &> /dev/null; then
    echo "Using Apache Bench for load testing..."
    ab -n $REQUESTS -c $CONCURRENCY $URL/
else
    echo "Apache Bench not available, using simple concurrent curl..."

    START_TIME=$(date +%s)

    # Simple concurrent request simulation
    for batch in $(seq 1 $((REQUESTS / CONCURRENCY))); do
        for i in $(seq 1 $CONCURRENCY); do
            curl -s $URL > /dev/null &
        done
        wait
    done

    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))

    echo ""
    echo "Load test completed!"
    echo "  Total time: ${DURATION}s"
    echo "  Requests/sec: $((REQUESTS / DURATION))"
fi

echo ""
echo "=== Nginx Statistics After Load Test ==="
curl -s http://localhost:8888/nginx_status

echo ""
echo ""
echo "=== Backend Container Resource Usage ==="
docker stats --no-stream $(docker ps --filter name=web-app-instance --format '{{.Names}}')
EOF

chmod +x $LAB_DIR/scripts/load-test.sh

# Run load test
echo ""
echo "Running load test..."
$LAB_DIR/scripts/load-test.sh

# Create health monitoring script
cat > $LAB_DIR/scripts/health-check.sh << 'EOF'
#!/bin/bash

echo "Container Health Check"
echo "======================"
echo ""

HEALTHY=0
UNHEALTHY=0

for container in $(docker ps --format '{{.Names}}' | grep web-app); do
    echo -n "Checking $container: "

    # Check if container is running
    status=$(docker inspect -f '{{.State.Status}}' $container 2>/dev/null)

    if [ "$status" == "running" ]; then
        # Check if nginx is responding
        port=$(docker port $container 80 2>/dev/null | cut -d: -f2)

        if [ ! -z "$port" ]; then
            http_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port 2>/dev/null)

            if [ "$http_code" == "200" ]; then
                echo "✓ Healthy (HTTP $http_code on port $port)"
                ((HEALTHY++))
            else
                echo "⚠ Warning - Running but HTTP $http_code"
                ((UNHEALTHY++))
            fi
        else
            echo "⚠ Warning - No port mapping found"
            ((UNHEALTHY++))
        fi
    else
        echo "✗ Unhealthy (Status: $status)"
        ((UNHEALTHY++))
    fi
done

echo ""
echo "Health Check Summary:"
echo "  Healthy: $HEALTHY"
echo "  Unhealthy: $UNHEALTHY"
echo "  Total: $((HEALTHY + UNHEALTHY))"
EOF

chmod +x $LAB_DIR/scripts/health-check.sh

# Run health check
echo ""
$LAB_DIR/scripts/health-check.sh


================================================================================
4. TASK 3: DOCUMENT AND ANALYZE CHALLENGES
================================================================================

Subtask 3.1: Create Challenge Documentation
--------------------------------------------

Let's document all the challenges we've encountered in this lab.

# Create comprehensive challenge analysis document
cat > $LAB_DIR/docs/challenges-report.md << 'EOF'
# Container Management Challenges - Comprehensive Report

## Executive Summary

This report documents the challenges encountered when manually managing 
containerized applications without orchestration tools. Based on hands-on 
experience deploying and managing 8 nginx containers, we identified 10 major 
challenge categories that make manual management impractical at scale.

---

## Challenge Categories

### 1. Port Conflicts

**Description**: Multiple containers cannot bind to the same host port simultaneously.

**Observations from Lab**:
- Attempted to run web-app-2 on port 8080 (already used by web-app-1)
- Received error: "Bind for 0.0.0.0:8080 failed: port is already allocated"
- Required manual port assignment: 8080, 8081, 8082, 9001-9005

**Manual Solutions Required**:
- Manually track and assign unique ports for each container
- Maintain port allocation documentation (spreadsheet/notebook)
- Coordinate across teams to prevent conflicts
- Update firewall rules for each new port

**Complexity Factors**:
- Linear increase with number of applications
- Exponential increase with instances per application
- Cross-team coordination overhead

**Real-World Impact**:
- Port conflicts cause deployment failures
- Manual tracking becomes error-prone
- Difficult to automate CI/CD pipelines
- Security risks (too many open ports)

**Orchestration Solution**:
- Kubernetes Services handle port mapping automatically
- Internal cluster networking eliminates port conflicts
- Service discovery via DNS names (not ports)

---

### 2. Resource Management

**Description**: No automatic resource allocation, limits, or quality of service.

**Observations from Lab**:
- web-app-1 and web-app-2: No resource limits (can consume unlimited RAM/CPU)
- web-app-3-limited: Manual `--memory` and `--cpus` flags required
- No mechanism to prevent resource starvation

**Manual Solutions Required**:
- Calculate resource requirements per application
- Manually set memory/CPU limits for each container
- Monitor resource usage constantly
- Adjust limits through trial and error

**Risks Identified**:
- **Resource Starvation**: One container can starve others
- **OOM Kills**: Containers killed unexpectedly when exceeding memory
- **Performance Degradation**: No CPU throttling leads to "noisy neighbor" problems
- **Inefficient Utilization**: Over-provisioning to be safe (40-50% utilization typical)

**Complexity**: Requires deep application profiling and monitoring

**Orchestration Solution**:
- Resource requests and limits per pod
- Quality of Service (QoS) classes
- ResourceQuotas at namespace level
- Automatic bin-packing and scheduling
- 70-80% resource utilization achievable

---

### 3. Scaling Challenges

**Description**: Manual deployment of multiple instances is slow and error-prone.

**Observations from Lab**:
- Created bash script to deploy 5 instances
- Sequential deployment: ~15-20 seconds total (2-4 seconds per instance)
- Manual tracking of instance names and ports required
- No automated health checking during scale-up

**Time Analysis**:
| Instances | Manual Time | With Script | Kubernetes |
|-----------|-------------|-------------|------------|
| 5         | 5-10 min    | 15-20 sec   | 5-10 sec   |
| 10        | 10-20 min   | 30-40 sec   | 10-15 sec  |
| 50        | 1-2 hours   | 3-5 min     | 30-60 sec  |
| 100       | Impossible  | 6-10 min    | 1-2 min    |

**Error Patterns**:
- Typos in container names
- Port conflicts during rapid scaling
- Inconsistent configuration across instances
- Missing resource limits on some instances

**Maintenance Burden**:
- Scripts must be updated for configuration changes
- No version control for infrastructure
- Difficult to track which instances are running which versions

**Orchestration Solution**:
```bash
# Scale to 50 replicas in seconds
kubectl scale deployment myapp --replicas=50
```

---

### 4. Failure Recovery

**Description**: No automatic restart or self-healing capabilities.

**Observations from Lab**:
- Manually stopped web-app-instance-2 and web-app-instance-4
- Containers remained in "Exited" state indefinitely
- Required manual identification and restart
- Recovery time: 3-5 minutes (including detection)

**Manual Recovery Steps**:
1. Detect failure (requires monitoring system)
2. Identify which container(s) failed
3. Check logs to determine cause
4. Decide whether to restart or redeploy
5. Execute restart command(s)
6. Verify service restoration
7. Update documentation/incident log

**Monitoring Requirements**:
- 24/7 monitoring needed
- Alert fatigue with many containers
- After-hours failures may go unnoticed
- Manual log analysis for root cause

**Downtime Impact**:
- **Detection Time**: 1-10 minutes (depends on monitoring interval)
- **Response Time**: 5-30 minutes (depends on human availability)
- **Recovery Time**: 1-5 minutes
- **Total Downtime**: 7-45 minutes per incident

**Orchestration Solution**:
- Kubernetes automatically restarts failed containers
- Liveness and readiness probes for health checking
- Self-healing maintains desired replica count
- **Total Downtime**: < 30 seconds (automatic)

---

### 5. Load Balancing

**Description**: No built-in traffic distribution mechanism.

**Observations from Lab**:
- Required separate nginx installation and configuration
- Manual upstream backend configuration (localhost:9001-9005)
- Static configuration with hardcoded ports
- Single point of failure (load balancer itself)

**Manual Setup Complexity**:
1. Install load balancer software (nginx/haproxy)
2. Configure upstream servers
3. Set proxy headers and timeouts
4. Configure health checks
5. Set up SSL/TLS (if needed)
6. Configure logging and monitoring
7. Test configuration
8. Restart load balancer

**Maintenance Challenges**:
- Manual updates when instances added/removed
- Load balancer restart required for config changes
- No dynamic service discovery
- Difficult to implement advanced routing (canary, blue-green)

**Load Balancer as SPOF**:
- If load balancer fails, entire application is down
- Requires its own high-availability setup
- Increases infrastructure complexity

**Orchestration Solution**:
- Built-in Service load balancing
- Automatic backend discovery and updates
- No configuration file changes needed
- HA load balancing by default

---

### 6. Service Discovery

**Description**: Hard-coded IP addresses and ports create brittle configurations.

**Observations from Lab**:
- nginx config: `server localhost:9001; server localhost:9002;` etc.
- Container IPs change on restart
- No DNS-based discovery

**Problems Identified**:
- **Configuration Brittleness**: Hardcoded values break easily
- **Manual Coordination**: Every service needs to know about every other service
- **Update Propagation**: Changes require updates in multiple places
- **Testing Difficulty**: Cannot easily test with different backends

**Example Failure Scenario**:
1. Container restarts and gets new IP
2. Load balancer still points to old IP
3. Health check fails
4. Manual intervention needed to update config
5. Load balancer restart required

**Scalability Issues**:
- Adding new instance: Update load balancer config
- Removing instance: Remove from config (or risk errors)
- Microservices architecture: Combinatorial explosion of configurations

**Orchestration Solution**:
- DNS-based service discovery
- Services accessible by name (e.g., `http://backend-service`)
- Automatic IP updates
- Environment variable injection

---

### 7. Configuration Management

**Description**: No centralized configuration management system.

**Observations from Lab**:
- Configuration scattered across scripts and Docker commands
- Each container potentially has different configuration
- No version control for environment variables
- Difficult to audit what's running where

**Configuration Challenges**:
| Aspect | Manual Approach | Issues |
|--------|-----------------|--------|
| Consistency | Manual copying | Configuration drift |
| Updates | Restart each container | Error-prone |
| Secrets | In scripts or env vars | Security risk |
| Versioning | No built-in support | Can't track changes |
| Rollback | Manual process | Time-consuming |

**Security Concerns**:
- Credentials in shell scripts
- Environment variables visible in `docker inspect`
- No secret rotation capability
- Difficult to implement least-privilege access

**Orchestration Solution**:
- ConfigMaps for application configuration
- Secrets for sensitive data
- Version-controlled manifests
- Easy rollback and audit trail

---

### 8. Networking Complexity

**Description**: Manual network management and isolation.

**Observations from Lab**:
- All containers on default bridge network
- No network isolation between applications
- Manual DNS configuration required
- Port mapping complexity

**Security Issues**:
- No network segmentation
- All containers can communicate with each other
- Difficult to implement microsegmentation
- No network policies

**Orchestration Solution**:
- Network policies for microsegmentation
- Automatic network creation per namespace
- Service mesh integration (Istio, Linkerd)

---

### 9. Updates and Rollbacks

**Description**: No built-in mechanism for zero-downtime updates.

**Manual Update Process**:
1. Stop old container
2. Remove old container
3. Pull new image
4. Start new container
5. Verify it's working
6. Repeat for each instance

**Downtime per Update**:
- With sequential updates: 5-30 seconds per instance
- With all-at-once: Complete outage

**Rollback Complexity**:
- No deployment history
- Must manually track previous image versions
- High risk of human error

**Orchestration Solution**:
- Rolling updates with zero downtime
- Automatic rollback on failure
- Deployment history and versioning

---

### 10. Observability

**Description**: Fragmented logging and monitoring across containers.

**Challenges**:
- Logs scattered across multiple containers
- No centralized log aggregation
- Difficult to correlate events across containers
- No distributed tracing

**Monitoring Gaps**:
- Manual metric collection
- No built-in dashboards
- Alert fatigue or missed alerts
- Difficult to troubleshoot distributed issues

**Orchestration Solution**:
- Centralized logging (EFK stack)
- Integrated metrics (Prometheus)
- Distributed tracing (Jaeger)
- Built-in dashboards (Grafana)

---

## Quantitative Analysis

### Manual Effort Scoring

| Challenge | Effort (1-10) | Error Risk (1-10) | Scalability (1-10) | Total Score |
|-----------|---------------|-------------------|-------------------|-------------|
| Port Conflicts | 7 | 8 | 3 | 18/30 |
| Resource Mgmt | 8 | 7 | 4 | 19/30 |
| Scaling | 9 | 9 | 2 | 20/30 |
| Failure Recovery | 10 | 6 | 2 | 18/30 |
| Load Balancing | 8 | 7 | 3 | 18/30 |
| Service Discovery | 9 | 9 | 1 | 19/30 |
| Configuration | 8 | 8 | 3 | 19/30 |
| Networking | 8 | 7 | 3 | 18/30 |
| Updates/Rollbacks | 9 | 9 | 2 | 20/30 |
| Observability | 9 | 6 | 3 | 18/30 |
| **AVERAGE** | **8.5** | **7.6** | **2.6** | **18.7/30** |

**Scale**: 
- Effort: 1=Easy, 10=Very Difficult
- Error Risk: 1=Low Risk, 10=High Risk  
- Scalability: 1=Does Not Scale, 10=Scales Easily

### Time-to-Value Comparison

| Operation | Manual Time | Kubernetes Time | Time Saved |
|-----------|-------------|-----------------|------------|
| Deploy 1 container | 30 sec | 5 sec | 83% |
| Deploy 10 containers | 5 min | 15 sec | 95% |
| Scale 5→10 replicas | 5 min | 5 sec | 98% |
| Update config | 10 min | 30 sec | 95% |
| Rollback deployment | 15 min | 10 sec | 99% |
| Recover from failure | 10 min | 30 sec | 95% |
| Setup load balancing | 30 min | 1 min | 97% |

**Average Time Saved: 95%**

---

## Conclusions

### Key Findings

1. **Manual Management Doesn't Scale**: Beyond 5-10 containers, manual management becomes prohibitively expensive in time and error risk.

2. **Human Error is the Biggest Risk**: 76% average error risk score across all categories.

3. **Operational Overhead is Massive**: Average manual effort score of 8.5/10 indicates extremely high operational burden.

4. **Automation ROI is Clear**: 95% average time savings with orchestration.

### When Manual Management is Acceptable

✓ Development and testing environments
✓ Learning and experimentation
✓ Very small applications (1-3 containers)
✓ Short-lived proof-of-concepts

### When Orchestration is Essential

✓ Production workloads
✓ More than 5-10 containers
✓ High availability requirements
✓ Need for auto-scaling
✓ Multi-team environments
✓ Regulatory compliance requirements

### Recommendation

**For production workloads, container orchestration (Kubernetes) is not optional—it's essential.**

The challenges documented in this lab are not theoretical—they are real operational 
burdens that development and operations teams face daily when managing containers 
manually. While the learning curve for Kubernetes is steep, the operational benefits 
far outweigh the initial investment.

---

## Next Steps

1. **Learn Kubernetes Fundamentals** (Lab 2)
2. **Understand Kubernetes Architecture** (Lab 3)
3. **Practice Deployments and Services**
4. **Prepare for KCNA Certification**

EOF

# Display the report
cat $LAB_DIR/docs/challenges-report.md

echo ""
echo "✓ Challenge report created: $LAB_DIR/docs/challenges-report.md"

Subtask 3.2: Performance Impact Analysis
-----------------------------------------

Create and run performance analysis:

# Create performance testing script
cat > $LAB_DIR/scripts/performance-test.sh << 'EOF'
#!/bin/bash

echo "================================================================"
echo "  PERFORMANCE IMPACT ANALYSIS - Manual Container Management"
echo "================================================================"
echo ""

# Test 1: Individual Container Response Times
echo "TEST 1: Individual Container Response Time"
echo "--------------------------------------------"
echo ""

TOTAL_TIME=0
for port in {9001..9005}; do
    echo -n "Testing port $port: "

    # Measure response time (milliseconds)
    START=$(date +%s%N)
    curl -s http://localhost:$port > /dev/null 2>&1
    END=$(date +%s%N)

    DURATION=$(( (END - START) / 1000000 ))
    TOTAL_TIME=$((TOTAL_TIME + DURATION))

    printf "%4d ms\n" $DURATION
done

AVERAGE=$((TOTAL_TIME / 5))
echo ""
echo "Average response time: ${AVERAGE}ms"
echo ""

# Test 2: Load Balancer Response Time
echo "TEST 2: Load Balancer Response Time"
echo "-------------------------------------"
echo ""

LB_TOTAL=0
REQUESTS=20

echo "Sending $REQUESTS requests through load balancer..."

for i in $(seq 1 $REQUESTS); do
    START=$(date +%s%N)
    curl -s http://localhost:8888 > /dev/null 2>&1
    END=$(date +%s%N)

    DURATION=$(( (END - START) / 1000000 ))
    LB_TOTAL=$((LB_TOTAL + DURATION))
done

LB_AVERAGE=$((LB_TOTAL / REQUESTS))
echo "Average response time through LB: ${LB_AVERAGE}ms"
echo "Overhead of load balancing: $((LB_AVERAGE - AVERAGE))ms"
echo ""

# Test 3: Concurrent Request Handling
echo "TEST 3: Concurrent Request Performance"
echo "----------------------------------------"
echo ""

echo "Sending 50 concurrent requests..."
START=$(date +%s)

for i in {1..50}; do
    curl -s http://localhost:8888 > /dev/null 2>&1 &
done

wait
END=$(date +%s)

DURATION=$((END - START))
THROUGHPUT=$((50 / DURATION))

echo "Time to complete: ${DURATION} seconds"
echo "Throughput: ${THROUGHPUT} requests/second"
echo ""

# Test 4: Resource Utilization
echo "TEST 4: Resource Utilization During Load"
echo "------------------------------------------"
echo ""

docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" | grep web-app-instance
echo ""

# Test 5: Scaling Time Measurement
echo "TEST 5: Manual Scaling Performance"
echo "------------------------------------"
echo ""

echo "Deploying 5 additional instances..."
START=$(date +%s)

for i in {6..10}; do
    PORT=$((9000 + i))
    docker run -d --name web-app-instance-$i -p $PORT:80 nginx:latest > /dev/null 2>&1
done

END=$(date +%s)
SCALE_TIME=$((END - START))

echo "Time to scale from 5 to 10 instances: ${SCALE_TIME} seconds"
echo "Average deployment time per instance: $((SCALE_TIME / 5)) seconds"
echo ""

# Verify new instances
RUNNING=$(docker ps --filter name=web-app-instance --format '{{.Names}}' | wc -l)
echo "Total instances now running: $RUNNING"
echo ""

# Cleanup test instances
echo "Cleaning up test instances (6-10)..."
for i in {6..10}; do
    docker stop web-app-instance-$i > /dev/null 2>&1
    docker rm web-app-instance-$i > /dev/null 2>&1
done

echo ""
echo "================================================================"
echo "  PERFORMANCE SUMMARY"
echo "================================================================"
echo ""
echo "  Individual Container Response:  ${AVERAGE}ms"
echo "  Load Balancer Response:         ${LB_AVERAGE}ms"
echo "  Concurrent Throughput:          ${THROUGHPUT} req/s"
echo "  Scaling Time (5 instances):     ${SCALE_TIME}s"
echo ""
echo "KEY FINDINGS:"
echo "  - Manual operations introduce latency"
echo "  - Scaling requires sequential deployment (not parallel)"
echo "  - Load balancing adds minimal overhead (~${LB_AVERAGE}ms)"
echo "  - Resource utilization is unoptimized"
echo ""
echo "KUBERNETES COMPARISON:"
echo "  - Similar response times for individual containers"
echo "  - Built-in load balancing (no extra hop)"
echo "  - Parallel pod deployment (5x+ faster scaling)"
echo "  - Optimized resource scheduling (70-80% utilization)"
echo ""
EOF

chmod +x $LAB_DIR/scripts/performance-test.sh

# Run performance tests
echo "Running performance analysis..."
$LAB_DIR/scripts/performance-test.sh

[ENHANCED SECTION - OPTIONAL]
------------------------------

# Create detailed metrics comparison document
cat > $LAB_DIR/docs/metrics-comparison.md << 'EOF'
# Manual vs Orchestrated Container Management - Detailed Metrics

## Deployment Speed

| Operation | Manual (Sequential) | Manual (Script) | Kubernetes | Improvement Factor |
|-----------|-------------------|----------------|------------|-------------------|
| Deploy 1 container | 5-10s | 3-5s | 2-5s | 2x |
| Deploy 5 containers | 25-50s | 15-25s | 5-10s | 3-5x |
| Deploy 10 containers | 50-100s | 30-50s | 10-20s | 3-5x |
| Deploy 50 containers | 4-8 min | 2.5-4 min | 30-60s | 5-8x |
| Deploy 100 containers | 8-16 min | 5-8 min | 1-2 min | 5-8x |

## Recovery Time Objectives (RTO)

| Failure Scenario | Manual | Kubernetes | Improvement |
|------------------|--------|------------|-------------|
| Single container crash | 3-10 min | <30s | 10-20x faster |
| Multiple container failures | 10-30 min | <1 min | 10-30x faster |
| Node failure | 30-60 min | 2-5 min | 10-20x faster |
| Complete cluster failure | Hours-Days | 10-30 min | 20-100x faster |

**Note**: Manual recovery times assume someone is available to respond. 
After-hours incidents can take much longer.

## Operational Efficiency

| Task | Manual Effort | Kubernetes Effort | Time Saved |
|------|---------------|-------------------|------------|
| Scale up 10 replicas | 5-10 min | 5 seconds | 98% |
| Scale down 5 replicas | 2-5 min | 5 seconds | 97% |
| Update application version | 15-30 min | 1-2 min | 93-95% |
| Rollback to previous version | 15-30 min | 10-30 seconds | 97-98% |
| Check system health | 5-10 min | 10-30 seconds | 95-97% |
| View application logs | 10-20 min | 30 seconds | 97-98% |
| Apply config change | 10-20 min | 1-2 min | 90-95% |

## Resource Utilization

| Metric | Manual Docker | Kubernetes | Improvement |
|--------|---------------|------------|-------------|
| Average CPU utilization | 30-40% | 60-70% | 75% better |
| Average Memory utilization | 40-50% | 65-75% | 50% better |
| Wasted resources | 50-60% | 25-35% | 40-70% reduction |
| Nodes needed for same workload | 100% | 60-70% | 30-40% reduction |

## Reliability Metrics

| Metric | Manual | Kubernetes | Improvement |
|--------|--------|------------|-------------|
| Mean Time To Recovery (MTTR) | 10-30 min | 30-60s | 10-30x |
| Mean Time Between Failures (MTBF) | Lower | Higher | 2-5x |
| Availability (uptime %) | 99% | 99.9%+ | 10x fewer outages |
| Recovery automation | 0% | 95%+ | Complete automation |

## Cost Analysis (Example: 100-container workload)

### Manual Management Costs

| Cost Category | Monthly Cost | Annual Cost |
|---------------|--------------|-------------|
| Extra infrastructure (poor utilization) | $2,000 | $24,000 |
| DevOps time (deployment & maintenance) | $8,000 | $96,000 |
| Downtime cost (assume 1hr/month) | $5,000 | $60,000 |
| Incident response (on-call, late nights) | $3,000 | $36,000 |
| **TOTAL** | **$18,000** | **$216,000** |

### Kubernetes Costs

| Cost Category | Monthly Cost | Annual Cost |
|---------------|--------------|-------------|
| Managed Kubernetes service | $500 | $6,000 |
| DevOps time (reduced by 80%) | $1,600 | $19,200 |
| Downtime cost (90% reduction) | $500 | $6,000 |
| Incident response (minimal) | $500 | $6,000 |
| Training & initial setup (Year 1 only) | $1,000 | $12,000 |
| **TOTAL** | **$4,100** | **$49,200** |

### ROI Analysis

- **Annual Savings**: $166,800
- **ROI**: 340% in first year
- **Payback Period**: ~3 months

*Note: Costs are illustrative. Actual costs vary by organization size, 
workload, and region.*

## Developer Productivity

| Activity | Manual Time/Week | Kubernetes Time/Week | Time Saved |
|----------|------------------|---------------------|------------|
| Deployments | 5 hours | 30 min | 90% |
| Troubleshooting | 8 hours | 2 hours | 75% |
| Scaling operations | 2 hours | 10 min | 92% |
| Configuration changes | 3 hours | 30 min | 83% |
| Monitoring & alerts | 4 hours | 1 hour | 75% |
| **TOTAL** | **22 hours** | **4 hours** | **82%** |

**Result**: Developers can focus 18 more hours per week on feature development 
instead of operational tasks.

## Security Posture

| Security Feature | Manual | Kubernetes | Improvement |
|------------------|--------|------------|-------------|
| Network segmentation | Difficult | Built-in (NetworkPolicies) | Much better |
| Secrets management | Plain text | Encrypted (Secrets) | Significantly better |
| RBAC | Docker group only | Fine-grained | Much better |
| Security scanning | Manual | Automated (admission controllers) | Much better |
| Compliance auditing | Very difficult | Built-in (audit logs) | Much better |

## Scalability Limits

| Metric | Manual Practical Limit | Kubernetes Limit |
|--------|------------------------|------------------|
| Containers per host | 20-50 | 100-110 |
| Total containers managed | <100 | 5,000+ (single cluster) |
| Deployment frequency | Few times/day | 100s/day |
| Teams sharing infrastructure | 1-2 | 10-50+ (multi-tenancy) |

## Conclusion

The metrics clearly demonstrate that while manual container management may work 
for very small deployments, **Kubernetes provides 3-10x improvements across all 
operational metrics** for production workloads.

The cost savings, improved reliability, and developer productivity gains make 
orchestration essential for any serious containerized application.
EOF

cat $LAB_DIR/docs/metrics-comparison.md
echo ""
echo "✓ Metrics comparison created"

