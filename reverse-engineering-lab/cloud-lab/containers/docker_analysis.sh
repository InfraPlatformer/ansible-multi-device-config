#!/bin/bash

# Docker Container Analysis Script
# Learn to analyze Docker containers for security and reverse engineering

echo "Docker Container Analysis Lab"
echo "=============================="

# Function to create sample containers
create_sample_containers() {
    echo "Creating sample containers for analysis..."
    
    # Sample 1: Simple web server
    cat > Dockerfile.webserver << 'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

    cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Sample Web Server</title>
</head>
<body>
    <h1>Welcome to the Sample Web Server</h1>
    <p>This is a test page for container analysis.</p>
</body>
</html>
EOF

    # Sample 2: Python application
    cat > Dockerfile.python << 'EOF'
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
EOF

    cat > requirements.txt << 'EOF'
flask==2.0.1
requests==2.25.1
EOF

    cat > app.py << 'EOF'
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({"message": "Hello from containerized Flask app!"})

@app.route('/api/data')
def get_data():
    return jsonify({"data": "sensitive information"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

    # Sample 3: Go application
    cat > Dockerfile.go << 'EOF'
FROM golang:1.19-alpine AS builder
WORKDIR /app
COPY main.go .
RUN go build -o app main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/app .
CMD ["./app"]
EOF

    cat > main.go << 'EOF'
package main

import (
    "fmt"
    "net/http"
    "log"
)

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello from Go container!")
}

func main() {
    http.HandleFunc("/", handler)
    log.Fatal(http.ListenAndServe(":8080", nil))
}
EOF

    echo "Sample containers created!"
}

# Function to analyze Docker images
analyze_docker_image() {
    local image_name=$1
    echo "Analyzing Docker image: $image_name"
    echo "================================"
    
    # Build the image
    echo "Building image..."
    docker build -t $image_name -f Dockerfile.$image_name .
    
    # Analyze image layers
    echo "Image layers:"
    docker history $image_name
    
    # Analyze image size
    echo "Image size:"
    docker images $image_name
    
    # Extract image contents
    echo "Extracting image contents..."
    docker save $image_name | tar -x -C /tmp/
    
    # Analyze manifest
    echo "Image manifest:"
    cat /tmp/manifest.json | jq .
    
    # Analyze config
    echo "Image config:"
    cat /tmp/*/json | jq .
    
    echo "Analysis complete for $image_name"
}

# Function to analyze running containers
analyze_running_container() {
    local container_name=$1
    echo "Analyzing running container: $container_name"
    echo "============================================="
    
    # Container info
    echo "Container info:"
    docker inspect $container_name | jq .
    
    # Container processes
    echo "Container processes:"
    docker exec $container_name ps aux
    
    # Container network
    echo "Container network:"
    docker exec $container_name netstat -tulpn
    
    # Container filesystem
    echo "Container filesystem:"
    docker exec $container_name ls -la /
    
    # Container environment
    echo "Container environment:"
    docker exec $container_name env
    
    echo "Analysis complete for $container_name"
}

# Function to analyze container security
analyze_container_security() {
    local container_name=$1
    echo "Security analysis for container: $container_name"
    echo "==============================================="
    
    # Check for root user
    echo "User analysis:"
    docker exec $container_name whoami
    docker exec $container_name id
    
    # Check capabilities
    echo "Capabilities:"
    docker exec $container_name capsh --print
    
    # Check mounted volumes
    echo "Mounted volumes:"
    docker inspect $container_name | jq '.[0].Mounts'
    
    # Check exposed ports
    echo "Exposed ports:"
    docker inspect $container_name | jq '.[0].NetworkSettings.Ports'
    
    # Check environment variables
    echo "Environment variables:"
    docker inspect $container_name | jq '.[0].Config.Env'
    
    echo "Security analysis complete for $container_name"
}

# Function to analyze container network
analyze_container_network() {
    local container_name=$1
    echo "Network analysis for container: $container_name"
    echo "=============================================="
    
    # Network interfaces
    echo "Network interfaces:"
    docker exec $container_name ip addr show
    
    # Network connections
    echo "Network connections:"
    docker exec $container_name netstat -tulpn
    
    # DNS resolution
    echo "DNS resolution:"
    docker exec $container_name nslookup google.com
    
    # Network traffic (if tcpdump available)
    echo "Network traffic (if tcpdump available):"
    docker exec $container_name which tcpdump || echo "tcpdump not available"
    
    echo "Network analysis complete for $container_name"
}

# Main analysis function
main() {
    echo "Docker Container Analysis Lab"
    echo "============================="
    
    # Create sample containers
    create_sample_containers
    
    # Analyze each sample
    for sample in webserver python go; do
        echo "Analyzing sample: $sample"
        analyze_docker_image $sample
        
        # Run container for analysis
        echo "Running container for analysis..."
        docker run -d --name ${sample}_analysis $sample
        
        # Analyze running container
        analyze_running_container ${sample}_analysis
        analyze_container_security ${sample}_analysis
        analyze_container_network ${sample}_analysis
        
        # Cleanup
        docker stop ${sample}_analysis
        docker rm ${sample}_analysis
        
        echo "Analysis complete for $sample"
        echo "============================="
    done
    
    echo "All analyses complete!"
}

# Run main function
main