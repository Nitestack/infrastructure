# Repository Guidelines

## Layout

Nix flake for NixOS, NixOS WSL, macOS, and Home Manager.

- `flake.nix`: inputs and `nixos-unified` outputs.
- `configurations/{nixos,darwin,home}/`: host/user entry points.
- `modules/{shared,nixos,darwin,home}/`: reusable cross-platform/platform modules.
- `overlays/`, `images/` (tracked wallpaper), `.github/workflows/`: overlays, assets, CI.

Keep host choices in `configurations/*/<host>/`; put reusable behaviour in `modules/*`.

## Commands

- `nix fmt` / `nix fmt -- --check`: format / check formatting.
- `nix flake check --no-build --no-write-lock-file`: evaluate checks without builds or lockfile writes.
- `nix run .#check`: formatting plus flake evaluation.
- `nix eval .#nixosConfigurations.nixstation.config.system.build.toplevel.drvPath --no-write-lock-file`: NixOS smoke test.
- `nix eval .#darwinConfigurations.macstation.system --apply 's: s.drvPath' --no-write-lock-file`: macOS smoke test.

## Code, Tests, Git

Use `nixfmt` conventions: 2 spaces, focused modules, explicit imports, and purpose-based names (for example `audio.nix`). Do not place host settings in shared modules without platform guards.

There is no separate unit-test suite; evaluation is the test boundary. Run `nix run .#check` before committing and evaluate the affected host for host-sensitive changes. Do not change `flake.lock` unless upgrading inputs intentionally.

Work on `main`; branch or open a PR only when asked. Use concise Conventional Commit subjects (ideally under 50 characters). PRs must state affected hosts/modules and verification; add screenshots only for visible desktop/wallpaper changes.

## Assets and secrets

Keep personal or machine-local assets out of Git (for example `images/local/`) and never commit unrelated local changes. Never expose, print, commit, copy, or put secrets in the Nix store; use `config.sops.secrets.*.path` or `config.sops.placeholder.*`.

## Agent references

- Issues: GitHub Issues in `Nitestack/infrastructure` via `gh`; see `docs/agents/issue-tracker.md`.
- Triage labels: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`; see `docs/agents/triage-labels.md`.
- Domain context: `CONTEXT.md` and `docs/adr/`; see `docs/agents/domain.md`.

## Documentation

Treat documentation outside `docs/agents/` as maintained operator documentation, not agent memory. When a change affects durable user knowledge (setup, host/service behaviour or exposure, commands, integrations, secrets/state, backup/recovery, or limitations), update or add focused `docs/` documentation in the same change; link broadly useful docs from the README.

Keep it concise, actionable, and safe to share: omit secrets, local credentials, and transient details; document operational gaps accurately.

`docs/homelab-services.md` is authoritative for `modules/nixos/homelab/`. When changing its API (options or validation) or networking/Caddy/DNS behaviour, update affected option tables, validation notes, and recipes.
