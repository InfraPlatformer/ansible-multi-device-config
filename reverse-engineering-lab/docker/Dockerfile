# Reverse Engineering Lab Docker Environment
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Basic tools
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    tree \
    # Python and development tools
    python3 \
    python3-pip \
    python3-dev \
    # Go
    golang-go \
    # Binary analysis tools
    binutils \
    objdump \
    strings \
    hexdump \
    file \
    # Network tools
    netcat-openbsd \
    tcpdump \
    wireshark-common \
    # Container tools
    docker.io \
    docker-compose \
    # Additional tools
    jq \
    yara \
    radare2 \
    ghidra \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install \
    requests \
    beautifulsoup4 \
    scapy \
    pwntools \
    uncompyle6 \
    pyinstxtractor-ng \
    dis3 \
    flask \
    django \
    numpy \
    pandas \
    matplotlib \
    jupyter \
    ipython

# Install Go tools
RUN go install github.com/go-delve/delve/cmd/dlv@latest
RUN go install github.com/golang/go@latest

# Create workspace directory
WORKDIR /workspace

# Copy lab files
COPY . /workspace/

# Set permissions
RUN chmod +x /workspace/*.sh
RUN chmod +x /workspace/*/*.sh

# Create user for security
RUN useradd -m -s /bin/bash reuser
RUN usermod -aG docker reuser
USER reuser

# Expose ports for web services
EXPOSE 8000 8080 5000 3000

# Default command
CMD ["/bin/bash"]