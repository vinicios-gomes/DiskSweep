# Contributing to DiskSweep

Thanks for helping! Issues and pull requests are welcome (English or Portuguese).

## Ground rules
1. **Safety first.** A cleaner must never delete anything without the UI/terminal confirmation, must keep
   `plan` read-only, and must validate every path/id it receives in `apply`. Use `fs_safe_rm`, never raw `rm -rf` on user input.
2. **Follow the contract** in `shell/lib/contract.sh` (`name`, `kind`, `kb`, `plan`, `apply`, `run`).
3. Keep the layers separate (see `Docs/ARCHITECTURE.md`): Views → ViewModels → Domain protocols ← Infrastructure.

## Adding a cleaner
Create `shell/cleaners/NN-name.sh`, `chmod +x`, and reuse a strategy from `shell/lib/`
(`path`, `cmd`, `explore`, `nodemodules`, `items`). No Swift changes are needed.
Check it with `./shell/cleaners/NN-name.sh size` and `plan` before sending the PR.

## Development
```bash
./scripts/run-app.sh        # build + open (uses ./shell so script edits apply without rebuilding)
for f in shell/lib/*.sh shell/cleaners/*.sh shell/limpar-disco.sh; do bash -n "$f"; done
swift test                  # requires Xcode (XCTest)
```
Shell code must run on macOS's bash 3.2 (no associative arrays, no `mapfile`).

## Pull requests
Describe what changes and how you tested it. For anything that deletes data, list the exact paths affected.
