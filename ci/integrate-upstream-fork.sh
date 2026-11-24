#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
if [[ -n "$(git status --porcelain)" ]]; then
  echo 'Working tree is not clean; refusing integration.' >&2
  exit 1
fi
if [[ "$(git branch --show-current)" == main ]]; then
  echo 'Switch to develop or vim-enhanced before running this script.' >&2
  exit 1
fi
git fetch upstream main
git merge-base --is-ancestor main upstream/main || {
  echo 'main diverged from upstream/main; manual investigation required.' >&2
  exit 1
}
git branch -f main upstream/main
branch="integration/upstream-$(date -u +%Y%m%dT%H%M%SZ)"
git switch -c "$branch" vim-enhanced
echo "Integration branch: $branch"
if ! git merge --no-ff --no-edit main; then
  echo 'Merge conflicts: resolve manually and run build/tests; stable is untouched.' >&2
  exit 1
fi
echo 'Merge complete. Build and test on Linux and Windows before manual promotion.'
