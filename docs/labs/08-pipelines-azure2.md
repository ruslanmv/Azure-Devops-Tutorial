# Lab 08 — Pipelines for Azure‑2

Create `.azure-pipelines/azure-2.yml` in the **Azure‑2** repo.

```yaml
trigger:
  branches: { include: [ main ] }
  paths:    { include: [ 'Folder3/*' ] }

pool:
  vmImage: 'ubuntu-latest'

steps:
- script: echo "Azure-2 pipeline triggered by Folder3 changes"
```

Switch to self‑hosted by setting `pool: { name: lab-pool }`.


Add as **Build validation** on `main` (as in Lab 07).

