# Lab 07 — Pipelines for Azure‑1

Create `.azure-pipelines/azure-1.yml` in the **Azure‑1** repo.

## Option 1 — Hosted agent (inside a container)
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

## Option 2 — Self‑hosted agent
```yaml
trigger:
  branches: { include: [ main ] }
  paths:    { include: [ 'Folder1/*', 'Folder2/*' ] }

pool: { name: lab-pool }

steps:
- script: echo "Azure-1 build on self-hosted agent"
```

## Add as Build Validation
Project Settings → Repositories → **Azure‑1** → Branches → `main` → **+ Build validation** → select pipeline → Policy requirement: **Required**.

