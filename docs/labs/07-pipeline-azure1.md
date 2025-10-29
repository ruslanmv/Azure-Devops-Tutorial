# Lab 07 — Pipeline for Azure‑1

## Hosted variant
`.azure-pipelines/azure-1-hosted.yml`
```yaml
name: 'Azure-1-$(Date:yyyyMMdd)$(Rev:.r)'
trigger:
  branches: { include: [ main, develop ] }
  paths:    { include: [ 'Folder1/**', 'Folder2/**' ] }
pool: { vmImage: 'ubuntu-latest' }
container: mcr.microsoft.com/dotnet/sdk:8.0
steps:
- checkout: self
  fetchDepth: 1
- script: dotnet --info
  displayName: Env info
- script: echo "Build Folder1" && ls -la Folder1
  displayName: Build F1
- script: echo "Build Folder2" && ls -la Folder2
  displayName: Build F2
```

## Self‑hosted variant
```yaml
name: 'Azure-1-SelfHosted-$(Date:yyyyMMdd)$(Rev:.r)'
trigger:
  branches: { include: [ main, develop ] }
  paths:    { include: [ 'Folder1/**', 'Folder2/**' ] }
pool: { name: Default }
steps:
- checkout: self
  clean: true
- script: |
    echo "Agent: $(Agent.Name) on $(Agent.OS)"
    git --version
    az --version || true
  displayName: Agent info
- script: ls -la Folder1
  displayName: Build F1
- script: ls -la Folder2
  displayName: Build F2
```

## Build validation
Add this pipeline as **Required** build validation on branch `main`.
