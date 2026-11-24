# Fork development rules

- Keep `main` an exact, clean fast-forward mirror of `upstream/main`; put fork changes only on `develop` and promote verified changes to `vim-enhanced`.
- Treat upstream WezTerm behavior and Lua configuration compatibility as invariants. Prefer small, reviewable patches and dedicated modules over editing unrelated upstream code.
- Preserve original authors and licenses. Cherry-pick only applicable source commits; never import the whole third-party fork or its formatter-only escape-parser changes.
- Add regression coverage for each imported behavior. Build and test on Linux and Windows before calling a change stable. Never claim an unperformed test passed.
- Integrate upstream into a temporary branch first. Never force-push, silently resolve conflicts, discard changes, replace an installed binary, or change personal configuration.
