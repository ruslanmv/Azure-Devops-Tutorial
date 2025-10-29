param([string]$HdpRemote,[string]$Azure1Remote,[string]$Azure2Remote)
$ErrorActionPreference = "Stop"
if (-not (Get-Command git-filter-repo -ErrorAction SilentlyContinue)) { throw "Install git-filter-repo (pip install git-filter-repo)" }
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
