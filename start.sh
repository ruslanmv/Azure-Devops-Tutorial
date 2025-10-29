#!/bin/bash
# Exit on any error, undefined variable, or pipe failure
set -euo pipefail

# ============================================
# Configuration from environment variables
# ============================================

# Azure DevOps settings (required)
AZP_URL="${AZP_URL:-}"
AZP_TOKEN="${AZP_TOKEN:-}"
AZP_POOL="${AZP_POOL:-Default}"
AZP_AGENT_NAME="${AZP_AGENT_NAME:-docker-agent}"
AZP_WORK_DIR="${AZP_WORK_DIR:-_work}"

# SSH settings
SSH_USER="devops"
SSH_PASSWORD="${SSH_PASSWORD:-devops}"
SSH_PUBLIC_KEY="${SSH_PUBLIC_KEY:-}"
SSH_DISABLE_PASSWORD="${SSH_DISABLE_PASSWORD:-false}"

# Agent installation directory
AGENT_DIR="/azp/agent"

# ============================================
# Helper function: logging
# ============================================
log() {
    echo -e "[init] $*"
}

# ============================================
# FUNCTION: Configure SSH user
# ============================================
configure_ssh_user() {
    log "Configuring SSH user ${SSH_USER}..."
    
    # Verify user exists
    if ! id -u "${SSH_USER}" >/dev/null 2>&1; then
        echo "ERROR: User ${SSH_USER} does not exist!" >&2
        exit 1
    fi
    
    # Set password authentication
    if [ "${SSH_DISABLE_PASSWORD}" != "true" ]; then
        # Enable password login
        echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd
        log "Password authentication enabled for ${SSH_USER}"
    else
        # Disable password login (key-only)
        sed -i 's/^PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
        log "Password authentication disabled (key-only mode)"
    fi
    
    # Configure SSH public key if provided
    if [ -n "${SSH_PUBLIC_KEY}" ]; then
        log "Adding SSH public key for ${SSH_USER}..."
        
        # Create .ssh directory with correct permissions
        su - "${SSH_USER}" -c "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
        
        # Add public key to authorized_keys
        echo "${SSH_PUBLIC_KEY}" >> "/home/${SSH_USER}/.ssh/authorized_keys"
        
        # Set correct ownership and permissions
        chown -R "${SSH_USER}:${SSH_USER}" "/home/${SSH_USER}/.ssh"
        chmod 600 "/home/${SSH_USER}/.ssh/authorized_keys"
        
        log "SSH public key configured successfully"
    fi
}

# ============================================
# FUNCTION: Download and install agent
# ============================================
install_agent() {
    # Check if agent already exists
    if [ -d "${AGENT_DIR}" ] && [ -f "${AGENT_DIR}/config.sh" ]; then
        log "Azure Pipelines agent already installed at ${AGENT_DIR}"
        return
    fi
    
    log "Downloading latest Azure Pipelines agent (Linux x64)..."
    
    # Create agent directory
    mkdir -p "${AGENT_DIR}"
    cd "${AGENT_DIR}"
    
    # Get latest agent download URL from GitHub
    AGENT_URL=$(curl -LsS https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest \
        | jq -r '.assets[] | select(.name | test("linux-x64.*\\.tar\\.gz$")) | .browser_download_url')
    
    # Validate URL
    if [ -z "$AGENT_URL" ] || [ "$AGENT_URL" = "null" ]; then
        echo "ERROR: Could not find agent download URL" >&2
        exit 1
    fi
    
    log "Downloading from: ${AGENT_URL}"
    
    # Download agent package
    curl -LsS "$AGENT_URL" -o agent.tar.gz
    
    # Extract agent
    tar -zxvf agent.tar.gz > /dev/null
    rm agent.tar.gz
    
    # Set ownership to devops user
    chown -R ${SSH_USER}:${SSH_USER} "${AGENT_DIR}"
    
    log "Agent downloaded and extracted successfully"
}

# ============================================
# FUNCTION: Configure agent with Azure DevOps
# ============================================
configure_agent() {
    # Validate required environment variables
    if [ -z "${AZP_URL}" ] || [ -z "${AZP_TOKEN}" ]; then
        echo "ERROR: AZP_URL and AZP_TOKEN must be set!" >&2
        exit 1
    fi
    
    cd "${AGENT_DIR}"
    
    # Check if agent is already configured
    if [ -f ".agent" ]; then
        log "Agent already configured (found .agent file)"
        return
    fi
    
    log "Configuring agent for ${AZP_URL}"
    log "  Pool: ${AZP_POOL}"
    log "  Agent name: ${AZP_AGENT_NAME}"
    
    # Run configuration as devops user
    sudo -u ${SSH_USER} ./config.sh \
        --unattended \
        --url "${AZP_URL}" \
        --auth pat \
        --token "${AZP_TOKEN}" \
        --pool "${AZP_POOL}" \
        --agent "${AZP_AGENT_NAME}" \
        --work "${AZP_WORK_DIR}" \
        --replace \
        --acceptTeeEula
    
    log "Agent configured successfully!"
}

# ============================================
# FUNCTION: Run the agent
# ============================================
run_agent() {
    cd "${AGENT_DIR}"
    
    log "Starting Azure Pipelines agent..."
    log "Agent will now listen for jobs from ${AZP_URL}"
    
    # Run agent as devops user (never as root!)
    # This is a blocking call - the agent runs in the foreground
    exec sudo -u ${SSH_USER} ./run.sh
}

# ============================================
# MAIN: Entry point
# ============================================
MODE="${1:-agent}"

case "$MODE" in
    agent)
        log "=== DevOps Box Initialization ==="
        configure_ssh_user
        install_agent
        configure_agent
        run_agent
        ;;
    *)
        echo "Usage: $0 agent" >&2
        exit 1
        ;;
esac