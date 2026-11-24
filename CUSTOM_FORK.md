# WezTerm Vim-enhanced fork

## Goal and status

Develop Neovim-like native copy-mode navigation as a small patch set on official WezTerm. **No third-party Vim behavior has been ported or verified yet.** The development roadmap below is not an implementation claim. Keep the stable branch at upstream until an imported patch builds and passes tests.

## Repositories and branches

`origin` = https://github.com/paben101-dev/wezterm; `upstream` = https://github.com/wezterm/wezterm; `vim-source` = https://github.com/sherocktong/wezterm. `main` mirrors upstream without custom commits, `develop` holds experimental ports, and `vim-enhanced` is for verified daily-driver changes. Foundation: `89e01990a5ad0b30e67d84d68b2fc4ad4eb71276` (2026-11-23). Initial branches all point there.

## Third-party assessment and attribution

At inspection, `upstream/main...vim-source/main` was **181 upstream-only / 9 source-only** commits. Original author of source commits: **Bing Tong <k.thomas.tong@gmail.com>**. Preserve their original commit authorship and existing WezTerm license notices when porting. This table describes intent, not validated compatibility:

| Commit | Purpose / decision |
| --- | --- |
| `b80b8cfde` | Correct end-of-word motion; candidate, dependent on source's earlier copy-mode state. |
| `01140e1e5` | Removes generated tests; exclude. |
| `442085b3e` | Core Vim motion, WORD, prefixes and text objects; candidate for selective adaptation, **not wholesale cherry-pick**. Includes unrelated formatter-only changes in cell/escape parser; exclude those. |
| `460ba1f0b` | Multi-line movement/counts and copy-mode docs; candidate after core adaptation. |
| `817477d23` | `yy` line copying; candidate after core adaptation. |
| `ffbb6b823` | Relative line numbers and search navigation; optional, high-impact rendering changes requiring separate review. |
| `7b269ae06` | Removes copy-mode tests; exclude. |
| `ba99b3985` | Selection-copy correction and search highlights; depends on gutter/selection changes; review separately. |
| `ae498239b` | Merge of old upstream; exclude. |

The source diff against its merge base touches `wezterm-gui/src/overlay/copy.rs` (935-line net change), `config/src/keyassignment.rs` (new copy-mode variants), `wezterm-cell/src/lib.rs` (formatting only), escape-parser modules (formatting only), and copy-mode docs. A direct diff against current upstream includes hundreds of unrelated reverse-upstream changes: **never merge the source branch**. Existing upstream already has word motions, search, jumps and selection; compare behavior and Lua variant compatibility before importing equivalents. API compatibility of the source implementation with current upstream is **not yet established**. No custom Rust files or upstream source changes are present yet.

## Build and installation

On Linux install Rust via rustup and required system packages using upstream's `./get-deps` (review its package commands first). Initialize with `git submodule update --init --recursive`, then run `cargo build --locked -p wezterm-gui` and `cargo test --locked -p wezterm-gui`; also run `cargo test --locked --workspace` when feasible. Windows requires the MSVC Rust toolchain and Strawberry Perl first on PATH; follow `docs/install/source.md` and upstream Windows CI, then run the same cargo build/test commands. Do not install or replace an existing WezTerm: run the built binary directly from `target/debug/` for manual checks. Verify copy-mode motions, counts, selections, searching, wide glyphs, and Lua keybindings interactively; GUI behavior cannot be fully covered by unit tests. No build or tests were run at initial setup (Rust toolchain absent).

## Upstream synchronization and conflicts

From a clean checkout run `bash ci/integrate-upstream-fork.sh`. It fetches upstream, fast-forwards clean `main`, and creates a unique integration branch from `vim-enhanced`, merging new upstream there without changing stable. If conflicts arise, inspect `git status` and resolve each manually; `git rerere` is enabled locally, but review reused resolutions. Run builds and tests on Linux and Windows, and manually inspect Lua and GUI behavior. Only then merge the integration branch into `develop`, then fast-forward/merge verified `develop` into `vim-enhanced` and push without force. Never promote an unverified build. For ongoing development, keep individual port commits small and preserve source attribution with `git cherry-pick -x` where applicable, or record source commit and author in adapted commits.

## CI and releases

Upstream already supplies Linux/Windows build workflows and artifacts; fork-specific checks should only be considered verified after running successfully on this fork. Tag a tested stable commit with a versioned fork tag and use the existing upstream tag packaging infrastructure after reviewing its permissions and release naming. Do not tag the initial unchanged branch as a customized binary.

## Roadmap (not implemented)

Full normal-mode navigation; `{`/`}` and Ctrl+brace paragraph navigation; numerical counts; word/WORD motions; character search and repeat; visual character/line/block modes; text objects; search/repeat search; marks/jump history; yank/clipboard; Lua-configurable keybindings. Prioritize upstream compatibility and regression tests for every increment.

## Limitations

There is no imported feature, local compiler, successful build, or GUI validation at setup time. Source-vs-current-upstream semantic equivalence and adaptation feasibility require implementation-stage investigation.
