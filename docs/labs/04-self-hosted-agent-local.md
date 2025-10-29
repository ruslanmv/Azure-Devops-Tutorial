# Lab 04 — Self‑Hosted Agent on Your Machine (Optional)

You can register your **workstation** as an agent.

## 1) Create/choose an Agent Pool
Org Settings → **Agent pools** → **New pool** (e.g., `lab-pool`) or use `Default`.

## 2) Windows (PowerShell)
```powershell
mkdir C:\azagent; cd C:\azagent
# Download agent zip from the Azure DevOps UI (Agent pools → New agent)
Expand-Archive agent.zip .
./config.cmd --url https://dev.azure.com/<yourorg> --auth pat --token <PAT> --pool lab-pool --runAsService
Start-Service vstsagent*
```

## 3) Linux/macOS (Bash)
```bash
mkdir -p ~/azagent && cd ~/azagent
# curl -L -o agent.tar.gz <download-URL-from-UI>
tar zxvf agent.tar.gz
./config.sh --url https://dev.azure.com/<yourorg> --auth pat --token <PAT> --pool lab-pool
./svc.sh install && ./svc.sh start
```

Verify: Org Settings → **Agent pools** → your pool → agent is **Online**.
