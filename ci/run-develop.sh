#!/usr/bin/env bash
# Run the CI-built GUI for the latest origin/develop commit; never build locally.
set -euo pipefail

config_args=(-n)
if [[ "${1:-}" == --config-file ]]; then
  if [[ $# -lt 2 || ! -f "$2" ]]; then
    echo 'Usage: run-develop.sh [--config-file PATH] [wezterm start arguments...]' >&2
    exit 1
  fi
  config_args=(--config-file "$(realpath "$2")")
  shift 2
fi

cd "$(dirname "${BASH_SOURCE[0]}")/.."
if ! command -v gh >/dev/null 2>&1; then
  echo 'GitHub CLI (gh) is required: https://cli.github.com/' >&2
  exit 1
fi

repo='paben101-dev/wezterm'
git fetch origin develop
sha=$(git rev-parse origin/develop)
run=$(gh run list --repo "$repo" --workflow 'Fork verification' --branch develop \
  --commit "$sha" --limit 10 \
  --json databaseId,status,conclusion,url,headBranch \
  --jq '.[] | select(.headBranch == "develop") | [.databaseId, .status, (if .conclusion == "" then "pending" else .conclusion end), .url] | @tsv' | head -n 1)
if [[ -z "$run" ]]; then
  echo "No CI run found for develop commit $sha. Wait for the Fork verification workflow." >&2
  exit 1
fi
IFS=$'\t' read -r run_id status conclusion url <<< "$run"
if [[ "$status" != completed ]]; then
  echo "Waiting for CI on develop commit $sha: $url"
  gh run watch "$run_id" --repo "$repo" --exit-status --interval 30
elif [[ "$conclusion" != success ]]; then
  echo "CI did not pass for develop commit $sha: $url ($conclusion)" >&2
  exit 1
fi

artifact_dir="target/ci-develop/$sha"
binary="$artifact_dir/wezterm-gui"
if [[ ! -f "$binary" ]]; then
  mkdir -p "$artifact_dir"
  gh run download "$run_id" --repo "$repo" \
    --name wezterm-gui-linux-unverified --dir "$artifact_dir"
fi
chmod u+x "$binary"
echo "Running CI build for develop commit $sha (run $run_id)."
# Do not install anything; personal Lua config is loaded only when explicitly requested.
exec "$binary" "${config_args[@]}" start --always-new-process "$@"
