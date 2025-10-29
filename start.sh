#!/bin/bash
set -euo pipefail

AZP_URL="${AZP_URL:-}"
AZP_TOKEN="${AZP_TOKEN:-}"
AZP_POOL="${AZP_POOL:-Default}"
AZP_AGENT_NAME="${AZP_AGENT_NAME:-docker-agent}"
AZP_WORK_DIR="${AZP_WORK_DIR:-_work}"

SSH_USER="devops"
SSH_PASSWORD="${SSH_PASSWORD:-devops}"
SSH_PUBLIC_KEY="${SSH_PUBLIC_KEY:-}"
SSH_DISABLE_PASSWORD="${SSH_DISABLE_PASSWORD:-false}"

AGENT_DIR="/azp/agent"

log(){ echo -e "[init] $*"; }

configure_ssh_user(){
  id -u "$SSH_USER" >/dev/null 2>&1 || { echo "User $SSH_USER missing"; exit 1; }
  if [ "$SSH_DISABLE_PASSWORD" != "true" ]; then
    echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
  else
    sed -i 's/^PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
  fi
  if [ -n "$SSH_PUBLIC_KEY" ]; then
    su - "$SSH_USER" -c "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    echo "$SSH_PUBLIC_KEY" >> "/home/$SSH_USER/.ssh/authorized_keys"
    chown -R "$SSH_USER:$SSH_USER" "/home/$SSH_USER/.ssh"
    chmod 600 "/home/$SSH_USER/.ssh/authorized_keys"
  fi
}

install_agent(){
  if [ -d "$AGENT_DIR" ] && [ -f "$AGENT_DIR/config.sh" ]; then
    log "Agent already present"; return
  fi
  log "Downloading Azure Pipelines agent ..."
  mkdir -p "$AGENT_DIR" && cd "$AGENT_DIR"
  URL=$(curl -LsS https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest | jq -r '.assets[] | select(.name | test("linux-x64.*\\.tar\\.gz$")) | .browser_download_url')
  [ -z "$URL" -o "$URL" = "null" ] && { echo "Cannot determine agent URL"; exit 1; }
  curl -LsS "$URL" -o agent.tar.gz
  tar -zxvf agent.tar.gz > /dev/null && rm agent.tar.gz
  chown -R "$SSH_USER:$SSH_USER" "$AGENT_DIR"
}

configure_agent(){
  [ -z "$AZP_URL" -o -z "$AZP_TOKEN" ] && { echo "AZP_URL/AZP_TOKEN required"; exit 1; }
  cd "$AGENT_DIR"
  if [ -f ".agent" ]; then return; fi
  sudo -u "$SSH_USER" ./config.sh     --unattended --url "$AZP_URL" --auth pat --token "$AZP_TOKEN"     --pool "$AZP_POOL" --agent "$AZP_AGENT_NAME" --work "$AZP_WORK_DIR"     --replace --acceptTeeEula
}

run_agent(){
  cd "$AGENT_DIR"
  exec sudo -u "$SSH_USER" ./run.sh
}

case "${1:-agent}" in
  agent) configure_ssh_user; install_agent; configure_agent; run_agent ;;
  *) echo "Usage: $0 agent" >&2 ; exit 1 ;;
esac
