# Lab 06 — Split the Monorepo (HDP) into Azure‑1 and Azure‑2

**Source:** one Git repo **HDP** with: `Folder1/`, `Folder2/`, `Folder3/`

**Targets:**

- **Azure‑1** ⟵ *Folder1 + Folder2*

- **Azure‑2** ⟵ *Folder3*


You can preserve history or do a snapshot.

## Option A — Preserve history (recommended)
Install `git-filter-repo` once:

```bash
pip install git-filter-repo
```


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

**Validation**
- Browse each Azure Repo → confirm root contains expected folders only.

- Use `git log -- Folder1` in Azure‑1 to confirm history is intact.


## Option B — Snapshot only (no history)
**Bash**
```bash
mkdir staging && cd staging
git clone <HDP remote URL> hdp

# Azure-1
mkdir azure1 && rsync -a hdp/Folder1/ azure1/Folder1/ && rsync -a hdp/Folder2/ azure1/Folder2/
cd azure1 && git init && git add . && git commit -m "Initial import: Folder1 + Folder2"
git remote add origin <Azure DevOps Azure-1 repo URL>
git branch -M main && git push -u origin main

# Azure-2
cd ..
mkdir azure2 && rsync -a hdp/Folder3/ azure2/Folder3/
cd azure2 && git init && git add . && git commit -m "Initial import: Folder3"
git remote add origin <Azure DevOps Azure-2 repo URL>
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

**Why preserve history?**
- Auditable changes, blame, and bisects stay meaningful.

- Accurate throughput metrics by component.

