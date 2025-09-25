#!/bin/bash

# Reverse Engineering Lab Setup Script
# Sets up the complete practice environment

echo "Reverse Engineering Lab Setup"
echo "============================"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please don't run this script as root"
    exit 1
fi

# Create main directory structure
echo "Creating directory structure..."
mkdir -p reverse-engineering-lab/{python-lab,go-lab,cloud-lab,tools,docker,challenges,resources}

# Create subdirectories
mkdir -p reverse-engineering-lab/python-lab/{beginner,intermediate,advanced,tools,samples}
mkdir -p reverse-engineering-lab/go-lab/{beginner,intermediate,advanced,tools,samples}
mkdir -p reverse-engineering-lab/cloud-lab/{containers,apis,infrastructure,tools,samples}

# Set permissions
chmod +x reverse-engineering-lab/docker/setup.sh
chmod +x reverse-engineering-lab/cloud-lab/containers/docker_analysis.sh

# Check for required tools
echo "Checking for required tools..."

# Check Python
if command -v python3 &> /dev/null; then
    echo "✓ Python3 found"
else
    echo "✗ Python3 not found. Please install Python3"
fi

# Check Go
if command -v go &> /dev/null; then
    echo "✓ Go found"
else
    echo "✗ Go not found. Please install Go"
fi

# Check Docker
if command -v docker &> /dev/null; then
    echo "✓ Docker found"
else
    echo "✗ Docker not found. Please install Docker"
fi

# Check basic tools
for tool in objdump strings hexdump file; do
    if command -v $tool &> /dev/null; then
        echo "✓ $tool found"
    else
        echo "✗ $tool not found. Please install binutils"
    fi
done

# Install Python packages
echo "Installing Python packages..."
pip3 install --user requests beautifulsoup4 scapy pwntools uncompyle6 pyinstxtractor-ng dis3 flask django numpy pandas matplotlib jupyter ipython

# Install Go tools
echo "Installing Go tools..."
go install github.com/go-delve/delve/cmd/dlv@latest

# Create sample files
echo "Creating sample files..."

# Python samples
cat > reverse-engineering-lab/python-lab/samples/sample1.py << 'EOF'
#!/usr/bin/env python3
# Sample Python file for analysis

def secret_function():
    secret = "This is a secret message"
    return secret

def main():
    result = secret_function()
    print(result)

if __name__ == "__main__":
    main()
EOF

# Go samples
cat > reverse-engineering-lab/go-lab/samples/sample1.go << 'EOF'
package main

import "fmt"

func secretFunction() string {
    secret := "This is a secret message"
    return secret
}

func main() {
    result := secretFunction()
    fmt.Println(result)
}
EOF

# Docker samples
cat > reverse-engineering-lab/cloud-lab/samples/Dockerfile.sample << 'EOF'
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y python3
COPY app.py /app/
WORKDIR /app
CMD ["python3", "app.py"]
EOF

# Create practice scripts
cat > reverse-engineering-lab/tools/practice.sh << 'EOF'
#!/bin/bash
# Practice script for reverse engineering

echo "Reverse Engineering Practice"
echo "==========================="

# Python practice
echo "Python Practice:"
echo "1. cd python-lab/beginner && python3 bytecode_analysis.py"
echo "2. cd python-lab/intermediate && python3 obfuscation_analysis.py"
echo "3. cd python-lab/tools && python3 pyinstxtractor.py <sample>"

# Go practice
echo "Go Practice:"
echo "1. cd go-lab/beginner && go run binary_analysis.go"
echo "2. cd go-lab/intermediate && go run runtime_analysis.go"
echo "3. cd go-lab/tools && python3 go_analyzer.py <binary>"

# Cloud practice
echo "Cloud Practice:"
echo "1. cd cloud-lab/containers && ./docker_analysis.sh"
echo "2. cd cloud-lab/apis && python3 api_analyzer.py <url>"
echo "3. cd cloud-lab/infrastructure && terraform init"

echo "Practice complete!"
EOF

chmod +x reverse-engineering-lab/tools/practice.sh

# Create quick start guide
cat > reverse-engineering-lab/QUICKSTART.md << 'EOF'
# Quick Start Guide

## 🚀 Getting Started

1. **Setup Environment**:
   ```bash
   ./setup.sh
   ```

2. **Start with Python**:
   ```bash
   cd python-lab/beginner
   python3 bytecode_analysis.py
   ```

3. **Try Go Analysis**:
   ```bash
   cd go-lab/beginner
   go run binary_analysis.go
   ```

4. **Practice Cloud Security**:
   ```bash
   cd cloud-lab/containers
   ./docker_analysis.sh
   ```

## 🐳 Docker Environment

1. **Start Docker Lab**:
   ```bash
   cd docker
   ./setup.sh
   ```

2. **Access Lab**:
   ```bash
   docker exec -it reverse-engineering-lab /bin/bash
   ```

## 📚 Learning Path

1. **Week 1-2**: Python bytecode analysis
2. **Week 3-4**: Go binary analysis
3. **Week 5-6**: Cloud security analysis
4. **Week 7+**: Advanced techniques

## 🛠️ Tools

- **Python**: uncompyle6, pyinstxtractor, dis
- **Go**: gobjdump, strings, hexdump
- **Cloud**: docker, kubectl, terraform
- **General**: radare2, ghidra, wireshark

## 📖 Resources

- [Free Courses](resources/courses.md)
- [CTF Platforms](resources/ctf-platforms.md)
- [Practice Challenges](challenges/README.md)
EOF

echo ""
echo "Setup complete!"
echo "==============="
echo ""
echo "Next steps:"
echo "1. Read the README.md file"
echo "2. Try the QUICKSTART.md guide"
echo "3. Start with beginner exercises"
echo "4. Join the community for help"
echo ""
echo "Happy reverse engineering!"