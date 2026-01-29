# 🎬 Lab 01: Exploring Container Orchestration

> **"The best way to understand why we need container orchestration? Try to live without it!"** 🚀

---

## 🎯 Mission Briefing

**The Scenario:** You're a junior DevOps engineer at TechCorp. Your manager walks in with an urgent request: *"We need to deploy 5 web applications by end of day. No Kubernetes allowed - just Docker."*

Sounds simple, right? 😅 By the end of this lab, you'll understand *exactly* why the industry invented container orchestration platforms like Kubernetes!

---

## 🏆 What You'll Achieve

By completing this lab, you will:

- [ ] Deploy multiple containerized applications manually
- [ ] Experience the pain of port conflicts firsthand
- [ ] Struggle with resource management (it builds character! 💪)
- [ ] Simulate scaling scenarios and feel the manual intervention pain
- [ ] Understand failure recovery challenges
- [ ] Finally appreciate why Kubernetes exists!

---

## 📋 Prerequisites

Before starting, make sure you have:

| Requirement | Status |
|------------|--------|
| Basic Linux command line skills | ☐ |
| Docker installed and running | ☐ |
| Understanding of ports and IP addresses | ☐ |
| A terminal ready to go | ☐ |
| Coffee ☕ (you'll need it!) | ☐ |

---

## 🖥️ Lab Environment

### ===== APPROACH 1: AL-NAFI CLOUD MACHINES =====

Al Nafi provides pre-configured Linux-based cloud machines. Simply click **Start Lab** to access:
- Ubuntu 20.04 LTS with Docker Engine installed
- Pre-configured user with sudo privileges
- Network access for downloading container images
- Multiple terminal sessions available

### ===== APPROACH 2: LOCAL SETUP =====

If you're working locally, ensure Docker is installed:

```bash
# What: Install Docker on Ubuntu
# Why: We need a container runtime to run our applications
# When: Only if Docker is not already installed

sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

---

## 🚀 Task 1: Deploy Two Containerized Applications Manually

### 💡 Think First!

Before we dive in, consider these questions:
- How do containers communicate with the outside world?
- What happens when two applications want the same port?
- Who tracks which container is running on which port?

*Got your answers? Let's find out if you're right!* 👇

---

### ⚡ Step 1.1: Verify Docker Installation

**🎯 The Mission:** Make sure our container engine is ready for action!

```bash
# ===== VERIFY DOCKER IS READY =====
# What: Check Docker version and status
# Why: Can't deploy containers without a working container runtime!
# When: Always at the start of any container work

docker --version
```

**✅ Success Checkpoint:** You should see something like `Docker version 24.x.x`

Now let's make sure the Docker daemon is running:

```bash
# What: Check if Docker service is active
# Why: Docker daemon must be running to manage containers
# When: Before any container operations

sudo systemctl status docker
```

**🎉 If you see "active (running)" - you're ready to rock!**

One more check - let's see if any containers are already running:

```bash
# What: List all running containers
# Why: Start with a clean slate, know your environment
# When: Beginning of each lab session

docker ps
```

---

### ⚡ Step 1.2: Create Your Workspace

**🎯 The Mission:** Set up an organized workspace for this lab.

```bash
# What: Create a dedicated directory for our lab work
# Why: Organization is key! DevOps engineers love clean structures
# When: Starting any new project or lab

mkdir ~/container-orchestration-lab
cd ~/container-orchestration-lab

# Create subdirectories for our applications
mkdir app1 app2

# Verify structure
ls -la
```

> 💎 **PRO TIP:** Real DevOps engineers always organize their work into logical directories. This habit will serve you well in production environments!

---

### ⚡ Step 1.3: Deploy Your First Application - Web Server

**🎬 The Scenario:** Your first task is to deploy a simple nginx web server. Easy mode! 😎

```bash
# ===== DEPLOY FIRST NGINX CONTAINER =====
# What: Pull the nginx image from Docker Hub
# Why: We need the application image before we can run it
# When: First time using an image on this machine

docker pull nginx:latest
```

**🤯 Wait, What Just Happened?**

Docker just downloaded the nginx image from Docker Hub - a public registry of container images. Think of it like an app store for containers!

Now let's run it:

```bash
# What: Start an nginx container on port 8080
# Why: We need to expose the web server to access it
# When: Deploying web-facing applications

docker run -d \
  --name web-app-1 \
  -p 8080:80 \
  nginx:latest
```

**🔍 Command Breakdown:**
| Flag | Meaning |
|------|---------|
| `-d` | Run in detached mode (background) |
| `--name web-app-1` | Give our container a friendly name |
| `-p 8080:80` | Map host port 8080 to container port 80 |
| `nginx:latest` | The image to run |

**✅ Verification Time!**

```bash
# What: Confirm our container is running
# Why: Never assume - always verify!
# When: After every deployment

docker ps
```

You should see your `web-app-1` container in the list with status "Up".

```bash
# What: Test the application is responding
# Why: Running doesn't mean working - test it!
# When: After deployment and port exposure

curl http://localhost:8080
```

**🎉 Success Checkpoint!**
Did you see HTML output with "Welcome to nginx!"? You just deployed your first container! 🌟

---

### ⚡ Step 1.4: Customize Your First Application

**🎯 The Mission:** Let's make this app unique with custom content.

```bash
# What: Create custom HTML content for our first app
# Why: In real world, each app has different content
# When: Customizing application deployments

cat > ~/container-orchestration-lab/app1/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Web Application 1</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            background-color: #e3f2fd; 
            text-align: center; 
            padding: 50px; 
        }
        h1 { color: #1976d2; }
        .container-info { 
            background: white; 
            padding: 20px; 
            border-radius: 10px; 
            margin: 20px auto;
            max-width: 500px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <div class="container-info">
        <h1>🚀 Web Application 1</h1>
        <p><strong>Port:</strong> 8080</p>
        <p><strong>Status:</strong> Running without orchestration!</p>
        <p>Container managed manually... for now 😅</p>
    </div>
</body>
</html>
EOF
```

Now copy it to the running container:

```bash
# What: Copy custom HTML into the container
# Why: Update the default nginx page with our content
# When: Customizing running containers (not best practice in production!)

docker cp ~/container-orchestration-lab/app1/index.html web-app-1:/usr/share/nginx/html/index.html

# Verify the change
curl http://localhost:8080
```

**✅ You should see your custom HTML now!**

> ⚠️ **WARNING:** Copying files into running containers is fine for learning, but in production, you should build custom images with your content baked in!

---

### ⚡ Step 1.5: Deploy Second Application - Here Comes Trouble! 🔥

**🎯 The Mission:** Deploy another web application. *What could go wrong?*

**💡 Think First!**
- We used port 8080 for the first app...
- What happens if we try to use port 8080 again?

Let's find out! 👇

```bash
# ===== ATTEMPT TO DEPLOY SECOND APP ON SAME PORT =====
# What: Try to run another container on port 8080
# Why: To experience port conflict firsthand!
# When: This is a learning exercise - DON'T do this in production!

docker run -d \
  --name web-app-2 \
  -p 8080:80 \
  nginx:latest
```

**😱 BOOM! What Happened?**

You should see an error like:
```
docker: Error response from daemon: driver failed programming external connectivity:
Bind for 0.0.0.0:8080 failed: port is already allocated.
```

**🎓 Lesson Learned #1: PORT CONFLICTS**

This is your first taste of why manual container management is painful:
- ❌ You need to track which ports are used
- ❌ No automatic port allocation
- ❌ Human error is inevitable at scale

> 🤔 **Challenge Question:** Imagine managing 50 applications across 10 servers. How would you track all the ports manually?

---

### ⚡ Step 1.6: Fix the Port Conflict (Manual Labor 😓)

```bash
# What: First, remove the failed container attempt
# Why: Clean up before retrying
# When: After a failed container start

docker rm web-app-2  # Remove the failed container

# Now run on a DIFFERENT port
docker run -d \
  --name web-app-2 \
  -p 8081:80 \
  nginx:latest
```

**✅ Verification:**

```bash
# Check both containers are running
docker ps

# Test both applications
echo "=== Testing Application 1 ==="
curl -s http://localhost:8080 | grep -o "<h1>.*</h1>"

echo "=== Testing Application 2 ==="
curl -s http://localhost:8081 | head -5
```

Now let's give app2 its own identity:

```bash
# Create custom content for second app
cat > ~/container-orchestration-lab/app2/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Web Application 2</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            background-color: #f3e5f5; 
            text-align: center; 
            padding: 50px; 
        }
        h1 { color: #7b1fa2; }
        .container-info { 
            background: white; 
            padding: 20px; 
            border-radius: 10px; 
            margin: 20px auto;
            max-width: 500px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <div class="container-info">
        <h1>🎯 Web Application 2</h1>
        <p><strong>Port:</strong> 8081</p>
        <p><strong>Status:</strong> Also running without orchestration!</p>
        <p>We had to manually pick a different port 🤷</p>
    </div>
</body>
</html>
EOF

# Copy to container
docker cp ~/container-orchestration-lab/app2/index.html web-app-2:/usr/share/nginx/html/index.html

# Test it
curl http://localhost:8081
```

**🏆 Level Up!** You've now manually deployed 2 applications. Only took you... *checks notes* ...way longer than it should! 😅

---

## 🚀 Task 2: Experience Resource Management Nightmares

### 💡 Think First!

In production, you need to control:
- How much memory each container can use
- How much CPU each container can consume
- What happens when containers compete for resources?

---

### ⚡ Step 2.1: Check Resource Usage

```bash
# ===== MONITOR CONTAINER RESOURCES =====
# What: View real-time resource usage of containers
# Why: Understanding resource consumption is critical for capacity planning
# When: Monitoring, debugging performance issues

docker stats --no-stream
```

**🔍 What You're Seeing:**
| Column | Meaning |
|--------|---------|
| CPU % | Percentage of host CPU used |
| MEM USAGE / LIMIT | Memory used vs. allowed |
| NET I/O | Network traffic in/out |
| BLOCK I/O | Disk read/write |

> 💎 **PRO TIP:** The `--no-stream` flag shows a snapshot. Remove it to see live updates (Ctrl+C to exit).

---

### ⚡ Step 2.2: Deploy a Resource-Limited Container

**🎯 The Mission:** Deploy a container with memory and CPU limits.

```bash
# What: Run a container with resource constraints
# Why: Prevent a single container from consuming all resources
# When: Production deployments, multi-tenant environments

docker run -d \
  --name web-app-3-limited \
  --memory="128m" \
  --cpus="0.5" \
  -p 8082:80 \
  nginx:latest
```

**🔍 Resource Flags Explained:**
| Flag | Meaning |
|------|---------|
| `--memory="128m"` | Maximum 128 megabytes of RAM |
| `--cpus="0.5"` | Maximum 50% of one CPU core |

**Compare resource allocations:**

```bash
# Compare all three containers
docker stats --no-stream web-app-1 web-app-2 web-app-3-limited
```

**🤔 Challenge Question:** What happens if `web-app-3-limited` tries to use more than 128MB of memory?

---

### ⚡ Step 2.3: Create a Monitoring Script

**🎯 The Mission:** Build your own container monitoring tool!

```bash
# What: Create a script to continuously monitor containers
# Why: Real DevOps engineers automate monitoring
# When: You need visibility into container health

cat > ~/container-orchestration-lab/monitor.sh << 'EOF'
#!/bin/bash
echo "🔍 Container Resource Monitoring Dashboard"
echo "=========================================="
echo "Press Ctrl+C to stop monitoring"
echo ""

while true; do
    clear
    echo "📅 $(date)"
    echo ""
    echo "📦 Container Status:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "web-app|NAMES"
    echo ""
    echo "📊 Resource Usage:"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" | grep -E "web-app|NAME"
    echo ""
    sleep 5
done
EOF

chmod +x ~/container-orchestration-lab/monitor.sh
```

Run it to see your monitoring dashboard:

```bash
# Run for a few seconds then Ctrl+C to stop
./monitor.sh
```

**🎓 Lesson Learned #2: MANUAL RESOURCE MONITORING**
- ❌ You have to set up your own monitoring
- ❌ No automatic alerting
- ❌ No historical data without additional tools

---

## 🚀 Task 3: The Scaling Nightmare

**🎬 The Scenario:** Your CEO just announced a flash sale! Traffic is about to spike 10x. You need to scale from 1 instance to 5 instances... manually. 😰

---

### ⚡ Step 3.1: Manual Scaling Script

```bash
# What: Create a script to deploy multiple container instances
# Why: Simulate scaling requirements
# When: Traffic increases demand more capacity

cat > ~/container-orchestration-lab/scale-app.sh << 'EOF'
#!/bin/bash

APP_NAME="web-app"
BASE_PORT=9000
INSTANCES=5

echo "🚀 Manually scaling $APP_NAME to $INSTANCES instances..."
echo "=================================================="

for i in $(seq 1 $INSTANCES); do
    PORT=$((BASE_PORT + i))
    CONTAINER_NAME="${APP_NAME}-instance-${i}"
    
    echo ""
    echo "📦 Deploying $CONTAINER_NAME on port $PORT..."
    
    docker run -d \
      --name $CONTAINER_NAME \
      -p $PORT:80 \
      nginx:latest
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Successfully deployed $CONTAINER_NAME"
    else
        echo "   ❌ Failed to deploy $CONTAINER_NAME"
    fi
    
    # Simulate real-world deployment delay
    sleep 2
done

echo ""
echo "🏁 Scaling complete! Checking status..."
echo ""
docker ps | grep web-app-instance
EOF

chmod +x ~/container-orchestration-lab/scale-app.sh
```

**🕐 Time yourself!** How long does it take to scale?

```bash
time ./scale-app.sh
```

**⏱️ Note the time:** _______ seconds

> 💡 **Reality Check:** With Kubernetes, this same operation takes < 1 second with:
> ```bash
> kubectl scale deployment myapp --replicas=5
> ```

---

### ⚡ Step 3.2: Test All Instances

```bash
# Create testing script
cat > ~/container-orchestration-lab/test-instances.sh << 'EOF'
#!/bin/bash

echo "🧪 Testing All Application Instances"
echo "====================================="

for port in {9001..9005}; do
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port 2>/dev/null)
    if [ "$response" = "200" ]; then
        echo "✅ Port $port: OK (HTTP $response)"
    else
        echo "❌ Port $port: FAILED (HTTP $response)"
    fi
done
EOF

chmod +x ~/container-orchestration-lab/test-instances.sh
./test-instances.sh
```

**🏆 Achievement Unlocked: Manual Scaler!** 
But wait... there's more pain coming! 😈

---

## 🚀 Task 4: The Failure Recovery Disaster

**🎬 The Scenario:** It's 3 AM. Your monitoring alerts you that 2 out of 5 instances have crashed. Time to fix it... manually! ☕

---

### ⚡ Step 4.1: Simulate Container Failures

```bash
# What: Stop some containers to simulate failures
# Why: Experience the pain of manual failure detection and recovery
# When: Testing resilience (or when things actually break!)

echo "💥 Simulating container failures..."
docker stop web-app-instance-2 web-app-instance-4

echo ""
echo "🔍 Current container status:"
docker ps | grep web-app-instance

echo ""
echo "🧪 Testing instances after failure:"
./test-instances.sh
```

**😱 Look at that!** Instances 2 and 4 are down!

---

### ⚡ Step 4.2: Manual Recovery Process

Now let's be the human orchestrator:

```bash
echo "🔧 MANUAL RECOVERY PROCESS"
echo "=========================="
echo ""

echo "Step 1: Identify failed containers"
docker ps -a | grep web-app-instance | grep -E "Exited|Created"

echo ""
echo "Step 2: Restart failed containers"
docker start web-app-instance-2
docker start web-app-instance-4

echo ""
echo "Step 3: Verify recovery"
./test-instances.sh
```

**🎓 Lesson Learned #3: NO SELF-HEALING**
- ❌ Containers don't restart automatically
- ❌ You need to monitor 24/7
- ❌ Manual intervention for every failure
- ❌ Downtime between failure and recovery

> 🤔 **Interview Spotlight:**
> **Q:** "How would you handle container failures in production?"
> **Your Answer (before Kubernetes):** "I'd... set up monitoring... wake up at 3 AM... restart containers manually..."
> **Your Answer (with Kubernetes):** "Kubernetes automatically restarts failed containers. I'd sleep peacefully!" 😴

---

## 🚀 Task 5: The Load Balancing Headache

**💡 Think First!**
You have 5 instances running on ports 9001-9005. How do users access them?
- Give them 5 different URLs?
- Build your own load balancer?

Let's try option 2! 🛠️

---

### ⚡ Step 5.1: Set Up Manual Load Balancer

```bash
# What: Install nginx as a load balancer
# Why: Distribute traffic across multiple instances
# When: You need high availability (always in production!)

sudo apt-get update
sudo apt-get install -y nginx
```

Configure the load balancer:

```bash
# Create load balancer configuration
sudo tee /etc/nginx/sites-available/load-balancer << 'EOF'
upstream backend_servers {
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
        proxy_pass http://backend_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# Enable the configuration
sudo ln -sf /etc/nginx/sites-available/load-balancer /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test and restart nginx
sudo nginx -t
sudo systemctl restart nginx
```

---

### ⚡ Step 5.2: Test Load Balancing

```bash
echo "🔄 Testing Load Balancer (10 requests):"
echo "========================================"
for i in {1..10}; do
    echo "Request $i: $(curl -s http://localhost 2>/dev/null | head -1)"
done
```

**🎓 Lesson Learned #4: MANUAL LOAD BALANCING**
- ❌ You have to set up and maintain the load balancer
- ❌ No automatic health checks (sends traffic to dead instances!)
- ❌ Manual configuration updates when instances change

---

## 📊 Task 6: Document Your Suffering

Let's create a report of all the challenges we faced:

```bash
cat > ~/container-orchestration-lab/challenges-report.md << 'EOF'
# 📋 Container Management Challenges Report

## Executive Summary
After attempting to manage containers manually, here are the pain points discovered:

## 🔴 Challenge 1: Port Conflicts
- **Issue:** Multiple containers cannot bind to the same port
- **Manual Solution:** Track and assign unique ports for each container
- **Time Wasted:** 5+ minutes per conflict
- **Scale Impact:** Unmanageable at 50+ containers

## 🔴 Challenge 2: Resource Management  
- **Issue:** No automatic resource allocation or limits
- **Manual Solution:** Set memory/CPU limits individually
- **Risk:** Resource contention, system instability
- **Scale Impact:** Requires spreadsheet tracking! 📊

## 🔴 Challenge 3: Scaling
- **Issue:** Manual deployment of multiple instances
- **Manual Solution:** Run commands repeatedly or write scripts
- **Time Wasted:** 30+ seconds per instance
- **Scale Impact:** 100 instances = 50+ minutes of work

## 🔴 Challenge 4: Failure Recovery
- **Issue:** No automatic restart of failed containers
- **Manual Solution:** 24/7 monitoring + human intervention
- **Downtime:** Minutes to hours depending on detection
- **Scale Impact:** Sleep deprivation! 😴

## 🔴 Challenge 5: Load Balancing
- **Issue:** No built-in traffic distribution
- **Manual Solution:** Set up separate load balancer
- **Maintenance:** Manual updates when instances change
- **Scale Impact:** Configuration drift, human error

## 🔴 Challenge 6: Service Discovery
- **Issue:** Hard-coded IP addresses and ports
- **Risk:** Configuration breaks when containers restart
- **Scale Impact:** Impossible to manage dynamically

## 💡 The Solution? CONTAINER ORCHESTRATION!

Kubernetes solves ALL of these challenges:
✅ Automatic port management via Services
✅ Resource quotas and automatic scaling
✅ One-command scaling: `kubectl scale deployment --replicas=100`
✅ Self-healing: automatic restart of failed containers
✅ Built-in load balancing
✅ DNS-based service discovery
EOF

cat ~/container-orchestration-lab/challenges-report.md
```

---

## 🧹 Lab Cleanup

```bash
# What: Clean up all containers created in this lab
# Why: Free up resources, start fresh for next lab
# When: End of lab session

echo "🧹 Cleaning up lab resources..."

# Stop and remove all web-app containers
docker ps -a | grep web-app | awk '{print $1}' | xargs -r docker stop
docker ps -a | grep web-app | awk '{print $1}' | xargs -r docker rm

# Reset nginx (optional)
sudo rm -f /etc/nginx/sites-enabled/load-balancer
sudo systemctl restart nginx

# Verify cleanup
echo "✅ Remaining containers:"
docker ps -a | grep web-app || echo "None! All cleaned up! 🎉"
```

---

## 🎓 Lab Summary

### 🏆 What You Accomplished

| Task | Challenge Experienced | Kubernetes Solution |
|------|----------------------|---------------------|
| Deploy 2 apps | Port conflicts | Services with automatic port allocation |
| Resource management | Manual limits per container | ResourceQuotas, LimitRanges |
| Scale to 5 instances | 30+ seconds of manual work | `kubectl scale --replicas=5` (instant!) |
| Recover from failures | Manual detection & restart | Self-healing with ReplicaSets |
| Load balancing | External nginx setup | Built-in Service load balancing |

### 🎯 Key Takeaways

1. **Manual container management doesn't scale** - What works for 2 containers fails at 20
2. **Humans make mistakes** - Automation prevents configuration drift
3. **24/7 monitoring is unsustainable** - Self-healing is essential
4. **Port tracking is a nightmare** - Service discovery is a must
5. **Kubernetes exists for a reason!** - It solves real problems

### 🤔 Interview Questions You Can Now Answer

1. *"Why do we need container orchestration?"*
2. *"What challenges does Kubernetes solve?"*
3. *"How does manual container management fail at scale?"*
4. *"What is self-healing in Kubernetes?"*

---

## 🚀 What's Next?

Now that you understand *why* we need container orchestration, let's learn *what* Kubernetes is!

**[➡️ Continue to Lab 02: Introduction to Kubernetes](Lab_02_Introduction_to_Kubernetes.md)**

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [CNCF Cloud Native Landscape](https://landscape.cncf.io/)
- [Kubernetes Official Docs](https://kubernetes.io/docs/)

---

**Created by:** Saleem Ali  
**GitHub:** https://github.com/ali4210  
**LinkedIn:** https://www.linkedin.com/in/saleem-ali-189719325/  
**Institution:** Al-Nafi International College  
**Program:** AIOps (Artificial Intelligence Operations)  
**Location:** Dhaka, Bangladesh

---

*🎯 Remember: The pain you felt today is the foundation for appreciating Kubernetes tomorrow!*
