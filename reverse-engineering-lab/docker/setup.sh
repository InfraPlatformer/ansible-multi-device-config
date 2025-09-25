#!/bin/bash

# Setup script for Reverse Engineering Lab Docker environment

echo "Reverse Engineering Lab - Docker Setup"
echo "======================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

# Create necessary directories
echo "Creating directories..."
mkdir -p ../python-lab/samples
mkdir -p ../go-lab/samples
mkdir -p ../cloud-lab/samples
mkdir -p ../tools
mkdir -p ../challenges

# Build Docker images
echo "Building Docker images..."
docker-compose build

# Start services
echo "Starting services..."
docker-compose up -d

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 10

# Check service status
echo "Service status:"
docker-compose ps

# Show access information
echo ""
echo "Access Information:"
echo "=================="
echo "Main Lab: docker exec -it reverse-engineering-lab /bin/bash"
echo "Python Lab: http://localhost:8001"
echo "Go Lab: docker exec -it go-re-lab /bin/bash"
echo "Cloud Lab: docker exec -it cloud-re-lab /bin/bash"
echo "PostgreSQL: localhost:5432 (reuser/repass)"
echo "Redis: localhost:6379"

echo ""
echo "Setup complete! You can now start practicing reverse engineering."
echo "Run 'docker-compose logs' to see service logs."
echo "Run 'docker-compose down' to stop all services."