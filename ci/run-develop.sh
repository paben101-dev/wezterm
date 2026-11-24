#!/usr/bin/env bash
# Build and run the latest fork development branch without installing it.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
export PATH="$HOME/.cargo/bin:$PATH"

if [[ -n "$(git status --porcelain)" ]]; then
  echo 'Working tree is not clean. Commit or stash your changes before updating develop.' >&2
  exit 1
fi
if ! command -v cargo >/dev/null 2>&1; then
  echo 'Cargo is missing. Install Rust with rustup: https://rustup.rs/' >&2
  exit 1
fi
if ! command -v cc >/dev/null 2>&1; then
  echo 'A C compiler is missing. On Ubuntu, install build-essential and the dependencies described in docs/install/source.md.' >&2
  exit 1
fi

git fetch origin develop
git switch develop
git merge --ff-only origin/develop
git submodule update --init --recursive
cargo build --locked -p wezterm-gui

# -n ignores the user's personal Lua configuration.  Never install or replace
# the user's existing WezTerm; run only the executable produced by this build.
exec target/debug/wezterm-gui -n start --always-new-process "$@"
