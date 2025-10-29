param([string]$HdpRemote,[string]$Azure1Remote,[string]$Azure2Remote)
if(!$HdpRemote -or !$Azure1Remote -or !$Azure2Remote){ Write-Host "Usage: .\split-snapshot-only.ps1 <HDP> <AZURE1> <AZURE2>"; exit 1 }
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
Write-Host "Snapshot split complete (no history)."
