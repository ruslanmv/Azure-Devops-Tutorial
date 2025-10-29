# Azure-Devops-Tutorial 
*A complete, hands‑on tutorial with ready‑to‑run code and scripts.*


This repository is a **complete, hands-on lab** to master **Microsoft Azure DevOps**:

- A one-container **DevOps Box** that runs an Azure Pipelines **self-hosted agent** and **SSHD** with `supervisord`.
- Scripts to split a monorepo (**HDP**) into **Azure-1** (Folder1 + Folder2) and **Azure-2** (Folder3) **preserving history**.
- Sample **YAML pipelines** with **path filters** and secure defaults.

## Quick start
```bash
cp .env.example .env           # set AZP_URL, AZP_TOKEN, etc.
make up                        # start the DevOps Box (agent + SSH)
make docs-serve                # docs at http://127.0.0.1:8000
make ssh                       # ssh devops@localhost -p 2222
```

---

## Why this tutorial?

We’ll go beyond checklists and build a **realistic, reusable “DevOps Box”** using Docker: a single container that runs both an **SSH server** and an **Azure Pipelines self‑hosted agent**. With it you get a disposable, VM‑like build host that you fully control.

Then we’ll solve a classic problem: **splitting a monolithic repository** the right way while **preserving Git history** into **two Azure Repos**.

Finally, we’ll wire **YAML pipelines** that implement **path filters**, **branch policies**, and **secure‑by‑default** configs.

Everything here is **copy‑pasteable** and **works locally**.

---

## What you’ll build

* A one‑container **DevOps Box** (self‑hosted agent + SSH, managed by *supervisord*).
* Two Azure Repos created from one source repo (**HDP**) with three folders:

  * `Azure-1` ⟵ **Folder1 + Folder2**
  * `Azure-2` ⟵ **Folder3**
* Two pipelines with **path filters** and options for **hosted** or **self‑hosted** pools.
* Professional **branch policies** and **security** guardrails.

---

## 0) What you need

* A **Microsoft account** (e.g., Outlook/Hotmail).
* **Git** and a shell (PowerShell 7+ or Bash).
* (Optional) **Docker** if you want to try the self‑hosted agent container.

---

## 1) Create your free Azure DevOps **organization**

1. Go to **[https://dev.azure.com](https://dev.azure.com)** and sign in.
2. Click **New organization** (or it will prompt you automatically on first sign‑in).
3. Pick a **name** (e.g., `yourname-devops`) and a **region** → Create.

> You now have a personal Azure DevOps **organization**. Everything below happens inside it.

---



## Lab 01 — Prerequisites (Zero‑to‑Hero)

Install on your workstation:

* **Git** 2.39+
* **Docker** Desktop/Engine + Docker Compose
* **PowerShell 7+** or **Bash**
* (Optional) **VS Code** with YAML + Git extensions

Create/confirm an **Azure DevOps Organization** (free tier is fine).

### Create a Personal Access Token (PAT)

This token lets the self‑hosted agent register against your org.

1. In Azure DevOps: **User settings → Personal access tokens → + New Token**
2. Name: `devops-box-agent` (or similar), Expiration: 90 days.
3. Scopes (**Custom defined → Show all scopes**):

   * **Agent Pools (Read & manage)**
   * **Code (Read & write)**
   * **Project and Team (Read)**
4. **Create** → copy the PAT **immediately** and store securely.

> 🔐 Treat PATs like passwords. Do **not** commit them. We’ll keep them in a local `.env` file that is gitignored.

---

## Lab 02 — Create Project & Repos

1. **New project** → Name: `HDP-Labs`, **Private**, Version control: **Git**.
2. In **Repos**, create two **empty** repositories:

   * `Azure-1`
   * `Azure-2`
3. Protect `main` (both repos): **Project Settings → Repositories → (repo) → Policies → Branches → main**

   * Require **pull request** to update `main` (block direct pushes)
   * **Minimum reviewers**: 1–2
   * **Merge strategy**: **Squash**
   * **Build validation**: add later when pipelines exist

---

## Lab 03 — (Optional) Azure DevOps Server (On‑prem)

If you’re air‑gapped, you can run **Azure DevOps Server (Express)** with **SQL Server** and follow the same labs. The only difference is your agent URL (use your server URL instead of `dev.azure.com`). For this tutorial, **Azure DevOps Services (cloud)** is recommended.

---

## Lab 04 — (Optional) Self‑Hosted Agent on Your Machine

It’s good to know the non‑Docker route. In **Organization settings → Agent pools** → select a pool (e.g., `Default`) → **New agent**.

**Windows (PowerShell)**

```powershell
mkdir C:\azagent; cd C:\azagent
# Download agent from the UI (copy link), then:
Expand-Archive agent.zip .
./config.cmd --url https://dev.azure.com/<yourorg> --auth pat --token <PAT> --pool Default --agent "my-local-agent"
./run.cmd  # or ./svc.sh install && ./svc.sh start on Linux/macOS
```

**Linux/macOS (Bash)**

```bash
mkdir -p ~/azagent && cd ~/azagent
# curl -LsS -o agent.tar.gz <download-URL-from-UI>
tar zxvf agent.tar.gz
./config.sh --url https://dev.azure.com/<yourorg> --auth pat --token <PAT> --pool Default --agent "my-local-agent"
./run.sh
```

> We’ll now build a **Dockerized** agent so you get a clean, reproducible build host.

---

## Lab 05 — The DevOps Box (Agent + SSH in One Docker Container)

We’ll keep everything in a **single folder** and run via `docker-compose` and a **Makefile**. The container:

* Registers an **Azure Pipelines agent** using your PAT.
* Exposes **SSH** to log in as a non‑root user (`devops`).
* Ships **Azure CLI + Git** for convenience.

> **Tip**: put these files in a repo so you can share them with your team.

### 1) `.gitignore`

```gitignore
# Secrets
.env

# Python venv / MkDocs build
.venv/
site/

# IDE & OS
.vscode/
.DS_Store
Thumbs.db

# Build/output
node_modules/
bin/
obj/
dist/
_build/
_work/
_agent_work/
_agent_logs/
```

### 2) `.env.example` (copy to `.env` and edit)

```bash
# Azure DevOps agent configuration
AZP_URL=https://dev.azure.com/YourOrgName
AZP_TOKEN=REPLACE_ME     # PAT with Agent Pools (Read & manage), Code (Read & write), Project & Team (Read)
AZP_POOL=Default
AZP_AGENT_NAME=docker-agent-1
AZP_WORK_DIR=_work

# SSH settings
SSH_PASSWORD=changeMe123
# SSH_PUBLIC_KEY=ssh-ed25519 AAAAC3NzaC1... user@host
# SSH_DISABLE_PASSWORD=true
```

### 3) `docker-compose.yml`

```yaml
version: "3.9"
services:
  azdo-agent:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: azdo-agent
    restart: unless-stopped
    environment:
      AZP_URL: "${AZP_URL}"
      AZP_TOKEN: "${AZP_TOKEN}"
      AZP_POOL: "${AZP_POOL}"
      AZP_AGENT_NAME: "${AZP_AGENT_NAME}"
      AZP_WORK_DIR: "${AZP_WORK_DIR}"
      SSH_PASSWORD: "${SSH_PASSWORD}"
      # SSH_PUBLIC_KEY: "${SSH_PUBLIC_KEY}"
      # SSH_DISABLE_PASSWORD: "${SSH_DISABLE_PASSWORD}"
    ports:
      - "127.0.0.1:2222:22"
    volumes:
      - ./_agent_work:/azp/agent/_work
      - ./_agent_logs:/azp/agent/_diag
```

### 4) `Dockerfile`

```Dockerfile
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG USERNAME=devops
ARG USER_UID=1000
ARG USER_GID=1000

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates curl jq git apt-transport-https gnupg lsb-release \
      openssh-server sudo unzip supervisor iproute2 dnsutils vim wget && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd  --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN mkdir -p /var/run/sshd && \
    sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's@^#\?AuthorizedKeysFile.*@AuthorizedKeysFile %h/.ssh/authorized_keys@' /etc/ssh/sshd_config && \
    echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config && \
    echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config
EXPOSE 22

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libicu70 libkrb5-3 zlib1g libssl3 libcurl4 libunwind8 gettext && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /azp && chown ${USERNAME}:${USERNAME} /azp

COPY start.sh /start.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /start.sh && chown ${USERNAME}:${USERNAME} /start.sh

WORKDIR /azp
CMD ["/usr/bin/supervisord", "-n"]
```

### 5) `start.sh`

```bash
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

log() { echo -e "[init] $*"; }

configure_ssh_user() {
  log "Configuring SSH user ${SSH_USER}..."
  id -u "${SSH_USER}" >/dev/null 2>&1 || { echo "User ${SSH_USER} missing"; exit 1; }

  if [ "${SSH_DISABLE_PASSWORD}" != "true" ]; then
    echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd
  else
    sed -i 's/^PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
  fi

  if [ -n "${SSH_PUBLIC_KEY}" ]; then
    su - "${SSH_USER}" -c "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    echo "${SSH_PUBLIC_KEY}" >> "/home/${SSH_USER}/.ssh/authorized_keys"
    chown -R "${SSH_USER}:${SSH_USER}" "/home/${SSH_USER}/.ssh"
    chmod 600 "/home/${SSH_USER}/.ssh/authorized_keys"
  fi
}

install_agent() {
  if [ -d "${AGENT_DIR}" ] && [ -f "${AGENT_DIR}/config.sh" ]; then
    log "Agent already present."; return; fi

  log "Downloading latest Linux x64 Azure Pipelines agent..."
  mkdir -p "${AGENT_DIR}" && cd "${AGENT_DIR}"
  AGENT_URL=$(curl -LsS https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest \
    | jq -r '.assets[] | select(.name | test("linux-x64.*\\.tar\\.gz$")) | .browser_download_url')
  if [ -z "$AGENT_URL" ] || [ "$AGENT_URL" = "null" ]; then echo "Could not find agent URL" >&2; exit 1; fi
  curl -LsS "$AGENT_URL" -o agent.tar.gz
  tar -zxvf agent.tar.gz > /dev/null && rm agent.tar.gz
  chown -R ${SSH_USER}:${SSH_USER} "${AGENT_DIR}"
}

configure_agent() {
  if [ -z "${AZP_URL}" ] || [ -z "${AZP_TOKEN}" ]; then echo "AZP_URL and AZP_TOKEN required" >&2; exit 1; fi
  cd "${AGENT_DIR}"
  if [ -f ".agent" ]; then log "Agent already configured."; return; fi
  log "Configuring agent for ${AZP_URL} (pool=${AZP_POOL}, name=${AZP_AGENT_NAME})"
  sudo -u ${SSH_USER} ./config.sh \
    --unattended \
    --url "${AZP_URL}" \
    --auth pat --token "${AZP_TOKEN}" \
    --pool "${AZP_POOL}" \
    --agent "${AZP_AGENT_NAME}" \
    --work "${AZP_WORK_DIR}" \
    --replace \
    --acceptTeeEula
}

run_agent() { cd "${AGENT_DIR}"; log "Starting agent..."; exec sudo -u ${SSH_USER} ./run.sh; }

MODE="${1:-agent}"
case "$MODE" in
  agent) configure_ssh_user; install_agent; configure_agent; run_agent;;
  *) echo "Usage: $0 agent" >&2; exit 1;;
esac
```

### 6) `supervisord.conf`

```ini
[supervisord]
nodaemon=true
logfile=/var/log/supervisord.log
pidfile=/var/run/supervisord.pid
childlogdir=/var/log

[program:sshd]
command=/usr/sbin/sshd -D
autorestart=true
priority=10
stdout_logfile=/var/log/sshd_stdout.log
stderr_logfile=/var/log/sshd_stderr.log

[program:azp-agent]
command=/start.sh agent
autorestart=true
priority=20
stdout_logfile=/var/log/agent_stdout.log
stderr_logfile=/var/log/agent_stderr.log
```

### 7) `Makefile`

```make
DOCKER_COMPOSE := docker compose
SERVICE := azdo-agent
PYTHON := python3
VENV := .venv
MKDOCS := $(VENV)/bin/mkdocs

.PHONY: help build up down restart logs ps ssh rebuild clean fresh env \
        docs-install docs-serve docs-build docs-clean

help:
	@echo "Usage: make <target>"; \
	echo; \
	printf "%-16s %s\n" \
	  build        "Build image(s)" \
	  up           "Start container in background (build if needed)" \
	  down         "Stop and remove container(s)" \
	  restart      "Restart the container" \
	  logs         "Tail logs from the agent container" \
	  ps           "List containers" \
	  ssh          "SSH into devops@localhost -p 2222" \
	  rebuild      "Force a no-cache rebuild" \
	  clean        "Down + remove volumes" \
	  fresh        "Clean + delete _agent_* folders" \
	  env          "Create .env from .env.example if missing" \
	  docs-install "Create venv & install MkDocs (Material)" \
	  docs-serve   "Serve docs locally at http://127.0.0.1:8000" \
	  docs-build   "Build static docs into ./site" \
	  docs-clean   "Remove venv and site build"; \
	echo

env:
	@test -f .env || (cp .env.example .env && echo "Created .env from .env.example")

build: env
	$(DOCKER_COMPOSE) build

up: env
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down

restart: down up

logs:
	$(DOCKER_COMPOSE) logs -f $(SERVICE)

ps:
	$(DOCKER_COMPOSE) ps

ssh:
	ssh devops@localhost -p 2222

rebuild: env
	$(DOCKER_COMPOSE) build --no-cache

clean:
	$(DOCKER_COMPOSE) down -v || true

fresh: clean
	rm -rf _agent_work _agent_logs || true

# ---------- Docs (optional, if you want a local docs site) ----------
docs-install:
	@if [ ! -d $(VENV) ]; then $(PYTHON) -m venv $(VENV); fi
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install mkdocs mkdocs-material

docs-serve: docs-install
	$(MKDOCS) serve -a 127.0.0.1:8000

docs-build: docs-install
	$(MKDOCS) build

docs-clean:
	rm -rf $(VENV) site
```

### 8) Start it up

```bash
cp .env.example .env   # fill in AZP_URL, AZP_TOKEN, etc.
make up
make logs   # watch the agent register
make ssh    # connect as devops@localhost -p 2222
```

In Azure DevOps → **Organization settings → Agent pools** → your pool → the agent should be **Online**.

---

## Lab 06 — Split the Monorepo (HDP) into Two Repos

We’ll take source repo **HDP** with three folders: `Folder1/`, `Folder2/`, `Folder3/`.

* **Azure‑1** ← Folder1 + Folder2
* **Azure‑2** ← Folder3

You have two options: **preserve history** or **snapshot only**.

### Option A — Preserve history (recommended)

Requires `git-filter-repo` (install once: `pip install git-filter-repo`).

**Bash**

```bash
# Azure-1
git clone <HDP remote URL> hdp && cd hdp
git filter-repo --force --path Folder1 --path Folder2
git remote add azure1 <Azure DevOps Azure-1 URL>
git push azure1 HEAD:main

# Azure-2
cd ..
git clone <HDP remote URL> hdp-f3 && cd hdp-f3
git filter-repo --force --path Folder3
git remote add azure2 <Azure DevOps Azure-2 URL>
git push azure2 HEAD:main
```

**PowerShell**

```powershell
param([string]$HdpRemote,[string]$Azure1Remote,[string]$Azure2Remote)
Remove-Item -Recurse -Force hdp -ErrorAction SilentlyContinue
git clone $HdpRemote hdp; Set-Location hdp
git filter-repo --force --path Folder1 --path Folder2
git remote add azure1 $Azure1Remote
git push azure1 HEAD:main
Set-Location ..
Remove-Item -Recurse -Force hdp-f3 -ErrorAction SilentlyContinue
git clone $HdpRemote hdp-f3; Set-Location hdp-f3
git filter-repo --force --path Folder3
git remote add azure2 $Azure2Remote
git push azure2 HEAD:main
```

### Option B — Snapshot only (no history)

**Bash**

```bash
mkdir staging && cd staging
git clone <HDP remote URL> hdp

# Azure-1
mkdir azure1 && rsync -a hdp/Folder1/ azure1/Folder1/ && rsync -a hdp/Folder2/ azure1/Folder2/
cd azure1 && git init && git add . && git commit -m "Initial import: Folder1 + Folder2"
git remote add origin <Azure DevOps Azure-1 URL>
git branch -M main && git push -u origin main

# Azure-2
cd ..
mkdir azure2 && rsync -a hdp/Folder3/ azure2/Folder3/
cd azure2 && git init && git add . && git commit -m "Initial import: Folder3"
git remote add origin <Azure DevOps Azure-2 URL>
git branch -M main && git push -u origin main
```

**PowerShell**

```powershell
param([string]$HdpRemote,[string]$Azure1Remote,[string]$Azure2Remote)
Remove-Item -Recurse -Force staging -ErrorAction SilentlyContinue
New-Item -ItemType Directory staging | Out-Null
Set-Location staging

git clone $HdpRemote hdp

New-Item -ItemType Directory azure1 | Out-Null
Copy-Item -Recurse hdp\Folder1 azure1\Folder1
Copy-Item -Recurse hdp\Folder2 azure1\Folder2
Set-Location azure1
git init; git add .; git commit -m "Initial import: Folder1 + Folder2"
git remote add origin $Azure1Remote; git branch -M main; git push -u origin main
Set-Location ..

New-Item -ItemType Directory azure2 | Out-Null
Copy-Item -Recurse hdp\Folder3 azure2\Folder3
Set-Location azure2
git init; git add .; git commit -m "Initial import: Folder3"
git remote add origin $Azure2Remote; git branch -M main; git push -u origin main
```

**Validate**: In each Azure Repo, ensure the expected folders appear at the root. Use `git log -- Folder1` etc. to confirm history (if you preserved it).

---

## Lab 07 — Pipeline for Azure‑1

Create this in the **Azure‑1** repo (e.g., `.azure-pipelines/azure-1.yml`).

**Option 1 — Hosted agent, containerized job**

```yaml
trigger:
  branches: { include: [ main ] }
  paths:    { include: [ 'Folder1/*', 'Folder2/*' ] }

pool:
  vmImage: 'ubuntu-latest'

container: mcr.microsoft.com/dotnet/sdk:8.0

steps:
- script: dotnet --info
- script: echo "Azure-1: containerized job on hosted agent"
```

**Option 2 — Self‑hosted agent**

```yaml
trigger:
  branches: { include: [ main ] }
  paths:    { include: [ 'Folder1/*', 'Folder2/*' ] }

pool: { name: Default }   # or your pool (e.g., lab-pool)

steps:
- script: echo "Azure-1 build on self-hosted agent"
```

> Add this pipeline as **Build validation** on the `main` branch of **Azure‑1**.

---

## Lab 08 — Pipeline for Azure‑2

Create this in the **Azure‑2** repo (e.g., `.azure-pipelines/azure-2.yml`).

```yaml
trigger:
  branches: { include: [ main ] }
  paths:    { include: [ 'Folder3/*' ] }

pool:
  vmImage: 'ubuntu-latest'

steps:
- script: echo "Azure-2 pipeline triggered by Folder3 changes"
```

> You can switch to your self‑hosted pool with `pool: { name: <your-pool> }` and add this pipeline as **Build validation** for **Azure‑2**.

---

## Lab 09 — Best Practices (Microsoft + Industry)

**Repos & Branching**

* Protect `main`; require **PRs** and **build validation**.
* Prefer **Squash** merges; meaningful PR titles.
* Use **path filters** to minimize unnecessary runs.

**Pipelines**

* Pin container images; avoid `latest` in production.
* Extract common steps into **templates**; use **variable groups**.
* Cache dependencies carefully; publish deterministic artifacts.

**Security**

* Least‑privilege PATs; rotate frequently.
* Use **Key Vault** + variable groups for secrets.
* Keep SSH bound to `127.0.0.1` unless you intend remote access.

---

## Lab 10 — Troubleshooting

* **Agent shows Offline**: Check PAT scope/expiry, `AZP_URL`, outbound internet; `make logs`.
* **SSH login fails**: If `SSH_DISABLE_PASSWORD=true`, you **must** set `SSH_PUBLIC_KEY`. Check perms: `~/.ssh` (700), `authorized_keys` (600).
* **Duplicate agents after restart**: Run `make fresh` to clear `_work`/`_diag` and re‑register.
* **Push denied / 401**: Use **PAT** for Git over HTTPS; verify repo rights and branch policies.

---

## Quick Reference (Cheat Sheet)

**DevOps Box**

```bash
make up        # build & start
make logs      # stream logs
make ssh       # ssh devops@localhost -p 2222
make down      # stop
make fresh     # factory reset (volumes + work/diag)
```

**Split with history**

```bash
git filter-repo --force --path Folder1 --path Folder2   # Azure-1
git filter-repo --force --path Folder3                   # Azure-2
```

**Snapshot only**

```bash
rsync -a hdp/Folder1/ azure1/Folder1/ && rsync -a hdp/Folder2/ azure1/Folder2/
rsync -a hdp/Folder3/ azure2/Folder3/
```

---

## You’re done 🎉

You’ve built a reusable **DevOps sandbox**, split a monorepo into **two clean Azure Repos** (with history!), and wired **modern pipelines** with professional guardrails. From here, add real build/test steps, enable code coverage and quality gates, integrate Key Vault, and template your pipelines for scale.

Happy shipping! 🚀
