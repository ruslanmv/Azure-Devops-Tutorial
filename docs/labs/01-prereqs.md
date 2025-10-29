# Lab 01 — Prerequisites

Install tooling and create the **Personal Access Token (PAT)** that the agent uses.

## Tools

### Git (2.39+)
- Windows: <https://git-scm.com/download/win>  
- macOS: `brew install git`  
- Ubuntu/Debian:
  ```bash
  sudo apt-get update && sudo apt-get install -y git
  ```
Verify:
```bash
git --version
```

### Docker + Compose
- Windows/macOS: Docker Desktop → <https://www.docker.com/products/docker-desktop>  
- Linux:
  ```bash
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo usermod -aG docker $USER
  ```
Verify:
```bash
docker --version
docker compose version
```

### Shell
- PowerShell 7+ (Windows): <https://github.com/PowerShell/PowerShell/releases>
- Bash (macOS/Linux): preinstalled

### VS Code (optional)
- <https://code.visualstudio.com/>
- Extensions: YAML, GitLens, Azure Pipelines, Docker

## Azure DevOps Organization
- Go to <https://dev.azure.com> → sign in → **+ New organization** (if needed).  
- Note your URL: `https://dev.azure.com/YOUR-ORG`.

## Create a PAT
1. Avatar (top-right) → **Personal access tokens** → **+ New Token**.  
2. Name: `devops-box-agent` → Expiration: 90 days.  
3. **Scopes** → *Show all scopes*:
   - Agent Pools → **Read & manage**
   - Code → **Read & write**
   - Project & Team → **Read**
4. Create and **copy token** once shown; store securely.

> ⚠️ Never commit tokens or `.env` files.
