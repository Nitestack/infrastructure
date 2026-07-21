# Repository Guidelines

## Project Structure & Module Organization
This repository is a Nix flake for NixOS, NixOS WSL, macOS, and Home Manager.

- `flake.nix` defines inputs and wires outputs through `nixos-unified`.
- `configurations/nixos/`, `configurations/darwin/`, and `configurations/home/` contain host and user entry points.
- `modules/shared/` holds cross-platform system modules; `modules/nixos/`, `modules/darwin/`, and `modules/home/` hold platform-specific modules.
- `overlays/` contains package overlays.
- `images/` stores wallpapers and other binary assets tracked through Git LFS.
- `.github/workflows/` contains CI checks.

Keep host-specific choices in `configurations/*/<host>/`. Put reusable behavior in `modules/*`.

## Build, Test, and Development Commands
- `nix fmt`: format Nix files with the repository formatter.
- `nix fmt -- --check`: verify formatting without rewriting files.
- `nix flake check --no-build --no-write-lock-file`: evaluate flake checks without building full systems or changing `flake.lock`.
- `nix run .#check`: run the repository check app, currently formatting plus flake evaluation.
- `nix eval .#nixosConfigurations.nixstation.config.system.build.toplevel.drvPath --no-write-lock-file`: smoke-test the main NixOS host.
- `nix eval .#darwinConfigurations.macstation.system --apply 's: s.drvPath' --no-write-lock-file`: smoke-test the macOS host.

## Coding Style & Naming Conventions
Use Nix defaults enforced by `nixfmt`. Prefer 2-space indentation, small focused modules, and explicit imports. Name modules by purpose, for example `audio.nix`, `git.nix`, or `profiles/networking.nix`. Avoid mixing host-specific settings into shared modules unless they are guarded by platform checks.

## Testing Guidelines
There is no separate unit test suite. Treat evaluation as the test boundary. Before committing, run `nix run .#check`. For host-sensitive edits, also evaluate the affected host configuration. Do not update `flake.lock` unless the change intentionally upgrades inputs.

## Commit & Pull Request Guidelines
Work happens directly on `main`; this repo does not use a pull request workflow. Only branch or open a PR when explicitly asked to. Recent history uses Conventional Commit style, for example `feat(codex): add Codex Desktop` and `refactor: wire shared config and LFS assets`. Use concise subjects under 50 characters when practical. When a change does go through a PR, include the affected host or module, verification commands run, and screenshots only for visible desktop or wallpaper changes.

## Asset & Configuration Tips
Binary assets in `images/` are Git LFS tracked. Keep large personal or machine-local files out of the repo; use ignored paths such as `images/local/` when needed. Never commit unrelated local changes from another device or workflow. Never expose, print, commit, or copy secrets into the Nix store — reference them through sops (`config.sops.secrets.*.path` / `config.sops.placeholder.*`) instead.

## Agent skills

### Issue tracker

Issues live as GitHub Issues in `Nitestack/infrastructure`, managed via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five-role vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout — `CONTEXT.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Documentation Sync Rules

`docs/homelab-services.md` is the reference for the `homelab` NixOS module
(`modules/nixos/homelab/`). **Any time you modify the module API** — adding,
renaming, or removing options in `options.nix`, changing validation rules in
`validation.nix`, or altering networking/Caddy/DNS behaviour — update the corresponding
sections in `docs/homelab-services.md`:

- Option tables under the affected heading (global, app, container, caddy, dns, etc.)
- The Validation section if assertions change
- Any recipe that relied on removed or renamed options
