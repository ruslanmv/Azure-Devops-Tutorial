# Lab 04 — Self‑Hosted Agent (Local Machine)

Register your workstation as an agent.

## Pool
**Org settings → Pipelines → Agent pools → + Add pool** (e.g., `lab-pool`).

## Install agent

=== "Windows"
    ```powershell
    mkdir C:\azagent; cd C:\azagent
    # Download zip from Azure DevOps UI
    Expand-Archive -Path vsts-agent-win-x64-*.zip -DestinationPath .
    .\config.cmd --url https://dev.azure.com/<org> --auth pat --token <PAT> --pool lab-pool --agent my-local-agent
    .\svc install
    .\svc start
    ```

=== "Linux/macOS"
    ```bash
    mkdir ~/azagent && cd ~/azagent
    curl -LsS -o agent.tar.gz <DOWNLOAD_URL_FROM_UI>
    tar zxvf agent.tar.gz
    ./config.sh --url https://dev.azure.com/<org> --auth pat --token <PAT> --pool lab-pool --agent my-local-agent
    sudo ./svc.sh install
    sudo ./svc.sh start
    ```

## Verify
Org settings → Agent pools → your pool → Agent shows **Online** and lists **Capabilities**.
