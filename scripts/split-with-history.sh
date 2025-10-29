#!/usr/bin/env bash
set -euo pipefail
HDP_REMOTE="${1:-}"; AZURE1_REMOTE="${2:-}"; AZURE2_REMOTE="${3:-}"
if [ -z "$HDP_REMOTE" ] || [ -z "$AZURE1_REMOTE" ] || [ -z "$AZURE2_REMOTE" ]; then
  echo "Usage: $0 <HDP_REMOTE> <AZURE1_REMOTE> <AZURE2_REMOTE>"; exit 1; fi
rm -rf hdp && git clone "$HDP_REMOTE" hdp && cd hdp
git filter-repo --force --path Folder1 --path Folder2
git remote add azure1 "$AZURE1_REMOTE"
git push azure1 HEAD:main
cd ..
rm -rf hdp-f3 && git clone "$HDP_REMOTE" hdp-f3 && cd hdp-f3
git filter-repo --force --path Folder3
git remote add azure2 "$AZURE2_REMOTE"
git push azure2 HEAD:main
echo "Split complete with history preserved."
