# Lab 06 — Split HDP into Azure‑1 & Azure‑2

Goal:
- **Azure‑1** gets `Folder1` + `Folder2`
- **Azure‑2** gets `Folder3`

## Preserve history (recommended)

Install once:
```bash
pip install git-filter-repo
```

**Azure‑1:**
```bash
git clone <HDP_REMOTE> azure-1-temp && cd azure-1-temp
git filter-repo --force --path Folder1 --path Folder2
git remote add azure1 <AZURE-1-URL>
git push azure1 HEAD:main
cd ..
```

**Azure‑2:**
```bash
git clone <HDP_REMOTE> azure-2-temp && cd azure-2-temp
git filter-repo --force --path Folder3
git remote add azure2 <AZURE-2-URL>
git push azure2 HEAD:main
```

## Snapshot only

**Bash**
```bash
mkdir staging && cd staging
git clone <HDP_REMOTE> hdp

mkdir azure1 && rsync -a hdp/Folder1/ azure1/Folder1/ && rsync -a hdp/Folder2/ azure1/Folder2/
cd azure1 && git init && git add . && git commit -m "Initial import: F1+F2"
git remote add origin <AZURE-1-URL>; git branch -M main; git push -u origin main
cd ..

mkdir azure2 && rsync -a hdp/Folder3/ azure2/Folder3/
cd azure2 && git init && git add . && git commit -m "Initial import: F3"
git remote add origin <AZURE-2-URL>; git branch -M main; git push -u origin main
```

**PowerShell**
```powershell
New-Item -ItemType Directory staging | Out-Null
Set-Location staging
git clone <HDP_REMOTE> hdp

New-Item -ItemType Directory azure1 | Out-Null
Copy-Item -Recurse hdp\Folder1 azure1\Folder1
Copy-Item -Recurse hdp\Folder2 azure1\Folder2
Set-Location azure1
git init; git add .; git commit -m "Initial import: Folder1 + Folder2"
git remote add origin <AZURE-1-URL>; git branch -M main; git push -u origin main
Set-Location ..

New-Item -ItemType Directory azure2 | Out-Null
Copy-Item -Recurse hdp\Folder3 azure2\Folder3
Set-Location azure2
git init; git add .; git commit -m "Initial import: Folder3"
git remote add origin <AZURE-2-URL>; git branch -M main; git push -u origin main
```
