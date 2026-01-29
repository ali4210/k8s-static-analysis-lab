# 🚀 KCNA Lab 1: Exploring Container Orchestration

> **Enhanced Interactive Lab Guide**  
> Prepared for: Saleem Ali  
> Duration: 2-3 hours  
> Difficulty: Beginner to Intermediate

---

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Learning Objectives](#learning-objectives)
- [Task 1: Deploy Applications Manually](#task-1-deploy-applications-manually)
- [Task 2: Scaling and Failure Scenarios](#task-2-scaling-and-failure-scenarios)
- [Task 3: Document and Analyze Challenges](#task-3-document-and-analyze-challenges)
- [Task 4: Orchestration Benefits](#task-4-orchestration-benefits)
- [Task 5: Cleanup](#task-5-cleanup)
- [Troubleshooting](#troubleshooting)
- [Conclusion](#conclusion)

---

## 🎯 Overview

In this hands-on lab, you'll experience the **challenges of manually managing containers** without orchestration tools. This will help you understand **why Kubernetes is essential** for production workloads.

### What You'll Build

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ Web App  │  │ Web App  │  │ Web App  │             │
│  │   :8080  │  │   :8081  │  │   :8082  │             │
│  └──────────┘  └──────────┘  └──────────┘             │
│                                                         │
│  ┌──────────────────────────────────────────────┐      │
│  │        Nginx Load Balancer :8888            │      │
│  └──────────────────────────────────────────────┘      │
│                        │                                │
│         ┌──────────────┴──────────────┐                │
│         │                             │                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ Backend  │  │ Backend  │  │ Backend  │             │
│  │  :9001   │  │  :9002   │  │  :9003   │             │
│  └──────────┘  └──────────┘  └──────────┘             │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## ✅ Prerequisites

Before starting, ensure you have:

- ✅ **Docker** installed and running
- ✅ Basic **Linux command-line** knowledge
- ✅ Access to **Al-Nafi cloud lab** environment
- ✅ Text editor (nano, vim, or VS Code)

---

## 🎓 Learning Objectives

By the end of this lab, you will:

- ✅ Deploy multiple containerized applications manually
- ✅ Identify port conflicts and resource management challenges
- ✅ Simulate scaling and failure scenarios
- ✅ Understand why orchestration is critical
- ✅ Compare manual management vs Kubernetes

---

## 🔧 Task 1: Deploy Applications Manually

### 📌 Subtask 1.1: Verify Docker Installation

Let's make sure Docker is ready!

#### Check Docker Version

```bash
docker --version
```

**Expected Output:**
```
Docker version 20.10.x or higher
```

#### Check Docker Service Status

```bash
sudo systemctl status docker
```

#### Start Docker (if not running)

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

#### Verify Docker Works

```bash
docker ps
```

**Expected Output:**
```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

> 💡 **Tip:** If you get a permission error, add your user to the docker group:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

### 📁 Create Lab Directory Structure

```bash
# Create main lab directory
mkdir -p ~/container-orchestration-lab
cd ~/container-orchestration-lab

# Create subdirectories
mkdir -p app1 app2 app3 logs scripts docs

# Verify structure
ls -la
```

**Expected Output:**
```
drwxrwxr-x  2 user user 4096 Jan 29 23:00 app1
drwxrwxr-x  2 user user 4096 Jan 29 23:00 app2
drwxrwxr-x  2 user user 4096 Jan 29 23:00 app3
drwxrwxr-x  2 user user 4096 Jan 29 23:00 docs
drwxrwxr-x  2 user user 4096 Jan 29 23:00 logs
drwxrwxr-x  2 user user 4096 Jan 29 23:00 scripts
```

---

### 📌 Subtask 1.2: Deploy First Application

#### Pull Nginx Image

```bash
docker pull nginx:latest
```

#### Verify Image Downloaded

```bash
docker images | grep nginx
```

#### 🚀 Run Your First Container

```bash
docker run -d \
  --name web-app-1 \
  -p 8080:80 \
  nginx:latest
```

**Command Breakdown:**
- `-d` → Run in background (detached mode)
- `--name web-app-1` → Give it a friendly name
- `-p 8080:80` → Map host port 8080 to container port 80
- `nginx:latest` → Use the nginx image

#### ✅ Verify Container is Running

```bash
docker ps
```

**Expected Output:**
```
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                  NAMES
abc123def456   nginx:latest   "/docker-entrypoint.…"   5 seconds ago   Up 4 seconds   0.0.0.0:8080->80/tcp   web-app-1
```

#### 🧪 Test the Application

```bash
curl http://localhost:8080
```

**Expected:** You should see HTML content of the nginx welcome page!

---

### 🎨 Create Custom HTML Page

Let's make our app look unique:

```bash
cat > ~/container-orchestration-lab/app1/index.html << 'EOF'
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
```

#### Copy Custom HTML to Container

```bash
docker cp ~/container-orchestration-lab/app1/index.html web-app-1:/usr/share/nginx/html/index.html
```

#### 🧪 Test Custom Page

```bash
curl http://localhost:8080 | grep "Web Application 1"
```

> 🎉 **Success!** You should see your custom page content!

---

### 📌 Subtask 1.3: Deploy Second Application (Port Conflict!)

Now let's try to deploy a second app on the **same port** and see what happens!

#### ❌ This Will FAIL (Intentionally)

```bash
docker run -d \
  --name web-app-2 \
  -p 8080:80 \
  nginx:latest
```

**Expected Error:**
```
Error response from daemon: driver failed programming external connectivity:
Bind for 0.0.0.0:8080 failed: port is already allocated
```

> 🔥 **Challenge Discovered!** Port conflicts are a major issue with manual container management!

#### ✅ Fix: Use a Different Port

```bash
docker run -d \
  --name web-app-2 \
  -p 8081:80 \
  nginx:latest
```

#### Verify Both Containers Running

```bash
docker ps
```

**Expected Output:**
```
CONTAINER ID   IMAGE          PORTS                  NAMES
abc123...      nginx:latest   0.0.0.0:8080->80/tcp   web-app-1
def456...      nginx:latest   0.0.0.0:8081->80/tcp   web-app-2
```

---

### 🎨 Create Custom Page for App 2

```bash
cat > ~/container-orchestration-lab/app2/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Web Application 2</title>
    <style>
        body { 
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 40px;
            max-width: 600px;
        }
        h1 { 
            color: #f5576c;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎯 Web Application 2</h1>
        <p style="text-align: center; margin-top: 20px;">Running on Port 8081</p>
    </div>
</body>
</html>
EOF
```

#### Copy to Container

```bash
docker cp ~/container-orchestration-lab/app2/index.html web-app-2:/usr/share/nginx/html/index.html
```

#### 🧪 Test Both Applications

```bash
# Test App 1
echo "=== Testing App 1 (Port 8080) ==="
curl -s http://localhost:8080 | grep -o '<h1>.*</h1>'

# Test App 2
echo "=== Testing App 2 (Port 8081) ==="
curl -s http://localhost:8081 | grep -o '<h1>.*</h1>'
```

---

### 📌 Subtask 1.4: Resource Management

Let's see resource usage!

#### Check Resource Usage

```bash
docker stats --no-stream
```

**Expected Output:**
```
CONTAINER ID   NAME        CPU %   MEM USAGE / LIMIT   MEM %   NET I/O
abc123...      web-app-1   0.01%   5.2MiB / 7.7GiB    0.07%   1.4kB / 0B
def456...      web-app-2   0.01%   5.1MiB / 7.7GiB    0.07%   1.3kB / 0B
```

#### 🚀 Deploy Container WITH Resource Limits

```bash
docker run -d \
  --name web-app-3-limited \
  --memory="128m" \
  --cpus="0.5" \
  -p 8082:80 \
  nginx:latest
```

**Resource Limits Explained:**
- `--memory="128m"` → Max 128 MB RAM
- `--cpus="0.5"` → Max 50% of one CPU core

#### Compare Resource Usage

```bash
docker stats --no-stream web-app-1 web-app-2 web-app-3-limited
```

> 🎓 **Learning Point:** Without limits, containers can consume all system resources!

---

### 📊 Create Monitoring Script

```bash
cat > ~/container-orchestration-lab/scripts/monitor.sh << 'EOF'
#!/bin/bash

echo "🔍 Container Resource Monitor"
echo "=============================="
echo ""

while true; do
    clear
    echo "=== Container Monitor ==="
    echo "⏰ $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""

    echo "📦 Container Status:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null

    echo ""
    echo "💻 Resource Usage:"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

    echo ""
    echo "Press Ctrl+C to stop"
    sleep 5
done
EOF

chmod +x ~/container-orchestration-lab/scripts/monitor.sh
```

#### Run Monitor (Press Ctrl+C to stop)

```bash
~/container-orchestration-lab/scripts/monitor.sh
```

---

## 🔄 Task 2: Scaling and Failure Scenarios

### 📌 Subtask 2.1: Manual Scaling

Now let's see how painful it is to scale manually!

#### Create Scaling Script

```bash
cat > ~/container-orchestration-lab/scripts/scale-app.sh << 'EOF'
#!/bin/bash

echo "📈 Manual Scaling Script"
echo "========================"
echo ""

APP_NAME="web-app"
BASE_PORT=9000
INSTANCES=5

START_TIME=$(date +%s)

for i in $(seq 1 $INSTANCES); do
    PORT=$((BASE_PORT + i))
    CONTAINER_NAME="${APP_NAME}-instance-${i}"

    echo -n "[$i/$INSTANCES] Deploying $CONTAINER_NAME on port $PORT... "

    docker run -d \
      --name $CONTAINER_NAME \
      -p $PORT:80 \
      --memory="128m" \
      nginx:latest >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "✅ Success"
    else
        echo "❌ Failed"
    fi

    sleep 2
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "✅ Completed in $DURATION seconds"
echo "📊 Average: $((DURATION / INSTANCES))s per instance"
EOF

chmod +x ~/container-orchestration-lab/scripts/scale-app.sh
```

#### Run Scaling Script

```bash
~/container-orchestration-lab/scripts/scale-app.sh
```

**Expected Output:**
```
📈 Manual Scaling Script
========================

[1/5] Deploying web-app-instance-1 on port 9001... ✅ Success
[2/5] Deploying web-app-instance-2 on port 9002... ✅ Success
[3/5] Deploying web-app-instance-3 on port 9003... ✅ Success
[4/5] Deploying web-app-instance-4 on port 9004... ✅ Success
[5/5] Deploying web-app-instance-5 on port 9005... ✅ Success

✅ Completed in 15 seconds
📊 Average: 3s per instance
```

> ⏱️ **Note:** With Kubernetes, this would take ~5 seconds for 50 instances!

---

### 📌 Subtask 2.2: Simulate Failures

Let's break things and see what happens!

#### Stop Some Containers

```bash
docker stop web-app-instance-2 web-app-instance-4
```

#### Check Status

```bash
docker ps -a --filter name=web-app-instance --format "table {{.Names}}\t{{.Status}}"
```

**Expected Output:**
```
NAMES                  STATUS
web-app-instance-1     Up 2 minutes
web-app-instance-2     Exited (0) 5 seconds ago  ❌
web-app-instance-3     Up 2 minutes
web-app-instance-4     Exited (0) 5 seconds ago  ❌
web-app-instance-5     Up 2 minutes
```

> 💀 **Challenge:** Containers stay down! No auto-recovery!

#### Manual Recovery

```bash
# Identify failed containers
docker ps -a --filter name=web-app-instance --filter status=exited

# Restart manually
docker start web-app-instance-2
docker start web-app-instance-4

# Verify recovery
docker ps --filter name=web-app-instance
```

> 🤔 **Think:** What if this happened at 3 AM? Kubernetes restarts automatically!

---

## 📊 Task 3: Document Challenges

### Challenge Summary Table

| Challenge | Manual Effort | Error Risk | With Kubernetes |
|-----------|---------------|------------|-----------------|
| Port Management | High (manual tracking) | 8/10 | Automatic |
| Scaling | 15-20s for 5 instances | 9/10 | 5s for 50 instances |
| Failure Recovery | 5-10 minutes | 6/10 | <30 seconds |
| Load Balancing | Manual nginx setup | 7/10 | Built-in |
| Service Discovery | Hardcoded IPs | 9/10 | DNS-based |

---

## 🧹 Task 5: Cleanup

### Remove All Containers

```bash
# Stop all web-app containers
docker ps --filter name=web-app --format '{{.Names}}' | xargs docker stop

# Remove all web-app containers
docker ps -a --filter name=web-app --format '{{.Names}}' | xargs docker rm

# Verify cleanup
docker ps -a
```

### Clean Up Images (Optional)

```bash
docker image prune -f
```

---

## 🆘 Troubleshooting

### Issue: Docker Permission Denied

**Error:** `permission denied while trying to connect to the Docker daemon socket`

**Solution:**
```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

### Issue: Port Already in Use

**Error:** `port is already allocated`

**Solution:**
```bash
# Find what's using the port
sudo lsof -i :8080

# Or kill the process
sudo fuser -k 8080/tcp
```

---

## 🎓 Conclusion

### What You Learned

✅ Manual container management challenges  
✅ Port conflicts and resource limits  
✅ Scaling difficulties  
✅ No automatic failure recovery  
✅ **Why Kubernetes is essential!**

### Next Steps

1. ✅ Complete Lab 1 ← **You are here!**
2. 🔜 **Lab 2:** Introduction to Kubernetes
3. 🔜 **Lab 3:** Kubernetes Architecture
4. 🔜 **Lab 4:** Deploy Apps in Kubernetes

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [KCNA Exam Guide](https://training.linuxfoundation.org/certification/kubernetes-cloud-native-associate/)

---

<div align="center">

### 🌟 Great Job, Saleem! 🌟

**You've completed Lab 1!**

Ready for Kubernetes? Let's go! 🚀

---

**Created by:** Perplexity AI  
**For:** Saleem Ali  
**Date:** January 2026

</div>
