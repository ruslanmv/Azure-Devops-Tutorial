#!/usr/bin/env bash
set -euo pipefail
HDP_REMOTE="${1:-}"; AZURE1_REMOTE="${2:-}"; AZURE2_REMOTE="${3:-}"
if [ -z "$HDP_REMOTE" ] || [ -z "$AZURE1_REMOTE" ] || [ -z "$AZURE2_REMOTE" ]; then
  echo "Usage: $0 <HDP_REMOTE> <AZURE1_REMOTE> <AZURE2_REMOTE>"; exit 1; fi
rm -rf staging && mkdir staging && cd staging
git clone "$HDP_REMOTE" hdp
mkdir azure1 && rsync -a hdp/Folder1/ azure1/Folder1/ && rsync -a hdp/Folder2/ azure1/Folder2/
cd azure1 && git init && git add . && git commit -m "Initial import: Folder1 + Folder2"
git remote add origin "$AZURE1_REMOTE"; git branch -M main; git push -u origin main
cd ..
mkdir azure2 && rsync -a hdp/Folder3/ azure2/Folder3/
cd azure2 && git init && git add . && git commit -m "Initial import: Folder3"
git remote add origin "$AZURE2_REMOTE"; git branch -M main; git push -u origin main
echo "Snapshot split complete (no history preserved)."
