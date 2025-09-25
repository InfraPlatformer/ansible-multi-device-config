# Cloud Security & Reverse Engineering Lab

This lab focuses on cloud security, container analysis, and infrastructure reverse engineering using free resources.

## ☁️ Topics Covered

1. **Container Security**
   - Docker image analysis
   - Container runtime security
   - Kubernetes security

2. **API Analysis**
   - REST API reverse engineering
   - GraphQL analysis
   - API security testing

3. **Infrastructure Analysis**
   - Terraform/IaC analysis
   - Cloud configuration analysis
   - Network security

4. **Cloud Services**
   - AWS/GCP/Azure analysis
   - Serverless function analysis
   - Cloud storage security

## 📁 Exercise Structure

- `containers/` - Docker and container analysis
- `apis/` - API reverse engineering
- `infrastructure/` - IaC and cloud config
- `tools/` - Analysis scripts and tools
- `samples/` - Practice samples

## 🛠️ Required Tools

```bash
# Docker and container tools
sudo apt-get install docker.io docker-compose

# Kubernetes tools
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Cloud CLI tools
pip install awscli gcloud azure-cli

# Analysis tools
pip install requests beautifulsoup4
```

## 🚀 Getting Started

1. Start with `containers/docker_analysis.sh`
2. Practice API analysis in `apis/`
3. Learn infrastructure analysis
4. Use `tools/` for automation