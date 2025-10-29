# Lab 08 — Pipeline for Azure‑2

`.azure-pipelines/azure-2.yml`
```yaml
name: 'Azure-2-$(Date:yyyyMMdd)$(Rev:.r)'
trigger:
  branches: { include: [ main, develop, 'feature/*' ] }
  paths:    { include: [ 'Folder3/**' ] }
pool: { vmImage: 'ubuntu-latest' }
variables:
  folder3Path: 'Folder3'
stages:
  - stage: Build
    jobs:
      - job: Build
        steps:
          - checkout: self
            fetchDepth: 1
          - script: ls -la $(folder3Path)
            displayName: Validate structure
          - bash: |
              mkdir -p $(Build.ArtifactStagingDirectory)/dist
              echo "artifact" > $(Build.ArtifactStagingDirectory)/dist/hello.txt
            displayName: Stage artifacts
          - task: PublishBuildArtifacts@1
            inputs:
              pathToPublish: '$(Build.ArtifactStagingDirectory)/dist'
              artifactName: 'folder3-artifacts'
```

Add **Build validation** on `main`. Only Folder3 changes trigger this pipeline.
