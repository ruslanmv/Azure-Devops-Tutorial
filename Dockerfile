# Start from Ubuntu 22.04 LTS (Long Term Support)
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Define the non-root user we'll create
ARG USERNAME=devops
ARG USER_UID=1000
ARG USER_GID=1000

# ============================================
# STEP 1: Install base system packages
# ============================================
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      # Essential tools
      ca-certificates \
      curl \
      wget \
      jq \
      git \
      unzip \
      vim \
      # Networking utilities
      apt-transport-https \
      gnupg \
      lsb-release \
      iproute2 \
      dnsutils \
      # SSH server
      openssh-server \
      # Process management
      supervisor \
      # Sudo for the devops user
      sudo && \
    # Clean up apt cache to reduce image size
    rm -rf /var/lib/apt/lists/*

# ============================================
# STEP 2: Create non-root user
# ============================================
# Security best practice: never run as root
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} && \
    # Allow sudo without password (needed for agent operations)
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ============================================
# STEP 3: Install Azure CLI
# ============================================
# Useful for Azure operations in pipelines
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# ============================================
# STEP 4: Configure SSH server
# ============================================
RUN mkdir -p /var/run/sshd && \
    # Enable password authentication
    sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    # Disable root login (security)
    sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    # Set authorized keys file location
    sed -i 's@^#\?AuthorizedKeysFile.*@AuthorizedKeysFile %h/.ssh/authorized_keys@' /etc/ssh/sshd_config && \
    # Keep SSH connections alive (prevents timeout)
    echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config && \
    echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config

# Expose SSH port
EXPOSE 22

# ============================================
# STEP 5: Install Azure Pipelines agent dependencies
# ============================================
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      # Required libraries for the agent
      libicu70 \
      libkrb5-3 \
      zlib1g \
      libssl3 \
      libcurl4 \
      libunwind8 \
      gettext && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# STEP 6: Create agent directory
# ============================================
RUN mkdir -p /azp && chown ${USERNAME}:${USERNAME} /azp

# ============================================
# STEP 7: Copy startup scripts
# ============================================
# Copy our custom scripts into the image
COPY start.sh /start.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make start script executable and set ownership
RUN chmod +x /start.sh && chown ${USERNAME}:${USERNAME} /start.sh

# ============================================
# STEP 8: Set working directory and entry point
# ============================================
WORKDIR /azp

# Start supervisord (which starts SSH and the agent)
CMD ["/usr/bin/supervisord", "-n"]