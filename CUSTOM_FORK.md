# WezTerm Vim-enhanced fork

## Goal and status

Develop Neovim-like native copy-mode navigation as a small patch set on official WezTerm. `develop` contains a port of motions, counts, `yy`, relative line numbers, search highlights and selection fixes, plus fork-local `{`/`}` paragraph motions. Linux and Windows CI built and tested the earlier port on [run 45509956205](https://github.com/paben101-dev/wezterm/actions/runs/45509956205); paragraph motions require their own CI run before promotion. `vim-enhanced` holds the earlier CI-verified patch set.

## Repositories and branches

`origin` = https://github.com/paben101-dev/wezterm; `upstream` = https://github.com/wezterm/wezterm; `vim-source` = https://github.com/sherocktong/wezterm. `main` mirrors upstream without custom commits, `develop` holds experimental ports, and `vim-enhanced` is for verified daily-driver changes. Foundation: `89e01990a5ad0b30e67d84d68b2fc4ad4eb71276` (2026-11-23). Initial branches all point there.

## Third-party assessment and attribution

At inspection, `upstream/main...vim-source/main` was **181 upstream-only / 9 source-only** commits. Original author of source commits: **Bing Tong <k.thomas.tong@gmail.com>**. Preserve their original commit authorship and existing WezTerm license notices when porting. This table describes intent, not validated compatibility:

| Commit | Purpose / decision |
| --- | --- |
| `b80b8cfde` | Correct end-of-word motion; candidate, dependent on source's earlier copy-mode state. |
| `01140e1e5` | Removes generated tests; exclude. |
| `442085b3e` | Core Vim motion, WORD, prefixes and text objects; selectively adapted, excluding formatter-only cell/escape-parser changes. |
| `460ba1f0b` | Multi-line movement/counts and copy-mode docs; cherry-picked. |
| `817477d23` | `yy` line copying; cherry-picked. |
| `ffbb6b823` | Relative line numbers and search navigation; cherry-picked; rendering needs manual review. |
| `7b269ae06` | Removes copy-mode tests; exclude. |
| `ba99b3985` | Selection-copy correction and search highlights; cherry-picked after gutter change. |
| `ae498239b` | Merge of old upstream; exclude. |

The source diff against its merge base touches `wezterm-gui/src/overlay/copy.rs` (935-line net change), `config/src/keyassignment.rs` (new copy-mode variants), `wezterm-cell/src/lib.rs` (formatting only), escape-parser modules (formatting only), and copy-mode docs. A direct diff against current upstream includes hundreds of unrelated reverse-upstream changes: **never merge the source branch**. Existing upstream already has word motions, search, jumps and selection; compare behavior and Lua variant compatibility before promotion. Fork source changes are limited to `wezterm-gui/src/overlay/copy.rs` and `config/src/keyassignment.rs`; closely coupled overlay state was not extracted into another module. API and GUI compatibility still require validation.

## Build and installation

To test the latest `origin/develop` on Linux **without building locally**, run `bash ci/run-develop.sh` (or `./ci/run-develop.sh`) with `gh` authenticated. This fetches `origin/develop` without switching your branch, waits for its successful `Fork verification` CI run, downloads the Linux `wezterm-gui` artifact into `target/ci-develop/<commit>/`, and launches it with `-n start --always-new-process`. It refuses to use an older CI run or a failed build. It neither installs the binary nor reads your personal Lua config by default. To explicitly test the private config repo, use `./ci/run-develop.sh --config-file "$HOME/Projects/dotfiles/wezterm/wezterm.lua"`. A graphical desktop and compatible runtime libraries are required. Windows users can download the Windows artifact from the corresponding run manually.

On Linux install Rust via rustup and required system packages using upstream's `./get-deps` (review its package commands first). Initialize with `git submodule update --init --recursive`, then run `cargo build --locked -p wezterm-gui` and `cargo test --locked -p wezterm-gui`; also run `cargo test --locked --workspace` when feasible. Windows requires the MSVC Rust toolchain and Strawberry Perl first on PATH; follow `docs/install/source.md` and upstream Windows CI, then run the same cargo build/test commands. Do not install or replace an existing WezTerm: run the built binary directly from `target/debug/` for manual checks. Verify copy-mode motions, counts, selections, searching, wide glyphs, and Lua keybindings interactively; GUI behavior cannot be fully covered by unit tests. Local Rust was installed, but this host lacks a C compiler and installing system dependencies requires sudo. The initial upstream-only Windows CI succeeded; Linux CI failed on stale Ubuntu package indices and now runs `apt-get update` first.

## Upstream synchronization and conflicts

From a clean checkout run `bash ci/integrate-upstream-fork.sh`. It fetches upstream, fast-forwards clean `main`, and creates a unique integration branch from `vim-enhanced`, merging new upstream there without changing stable. If conflicts arise, inspect `git status` and resolve each manually; `git rerere` is enabled locally, but review reused resolutions. Run builds and tests on Linux and Windows, and manually inspect Lua and GUI behavior. Only then merge the integration branch into `develop`, then fast-forward/merge verified `develop` into `vim-enhanced` and push without force. Never promote an unverified build. For ongoing development, keep individual port commits small and preserve source attribution with `git cherry-pick -x` where applicable, or record source commit and author in adapted commits.

## CI and releases

Upstream already supplies Linux/Windows build infrastructure; the fork runs its own build/test checks. To publish a **portable preview**, first ensure `vim-enhanced` passed CI and was manually tested, then create a *new* annotated tag `fork-vYYYY.MM.DD-preview.N` on `vim-enhanced` and push that tag (never retag a published version). The tag push triggers `Fork preview release` from the tagged commit; it builds release-mode Linux (Ubuntu 24.04) and Windows binaries, runs GUI unit tests on both, and only after both succeed creates the versioned GitHub prerelease with archives and SHA256SUMS. The publishing job checks that the tagged commit still matches the stable branch. Tags matching upstream's `20*` release workflows are intentionally avoided. Neither archive is signed or a system installer.

Download an archive from GitHub Releases and verify it with `sha256sum -c SHA256SUMS` (Windows: compare `Get-FileHash <archive> -Algorithm SHA256`). Extract into a separate folder. On Linux run the extracted `wezterm-gui -n start --always-new-process` from a desktop session; on Windows run `wezterm-gui.exe -n start --always-new-process` from the extracted folder. Use `--config-file <path>` instead of `-n` if you explicitly want your Lua config. **Do not replace the installed WezTerm or run the upstream-named installer** until you choose to migrate. Keep the previous archive for rollback. Linux requires compatible system libraries; Windows archive includes the bundled DLLs.

## Roadmap (not implemented)

Full normal-mode navigation; Ctrl+brace paragraph bindings (plain `{`/`}` paragraph motions are implemented); expanded numerical counts; word/WORD motions; character search and repeat; visual character/line/block modes; text objects; search/repeat search; marks/jump history; yank/clipboard; Lua-configurable keybindings. Prioritize upstream compatibility and regression tests for every increment.

## Limitations

Linux/Windows GUI package build and package-level unit tests succeeded in CI, including added word/count, paragraph, and imported gutter tests. The user manually confirmed everyday Vim navigation and paragraph motions on Linux. Copy/selection on wrapped and wide glyph lines, Windows GUI behavior, Lua compatibility and full-workspace tests remain unverified. Source-vs-current-upstream semantic equivalence still needs manual review.
