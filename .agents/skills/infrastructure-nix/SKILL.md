---
name: infrastructure-nix
description: Use when editing this repo's Nix flake - hosts, modules, overlays, the homelab module, or sops secrets. Points to the authoritative rules in AGENTS.md instead of duplicating them.
---

# Infrastructure Nix

AGENTS.md is the source of truth for this repo. This skill exists so you
don't have to re-derive the architecture from scratch each time - it does
not replace AGENTS.md, and the referenced sections there win on conflict.

## Architecture at a glance

- Flake wiring: `flake.nix` uses `outputs = inputs: inputs.nixos-unified.lib.mkFlake { inherit inputs; systems = [...]; root = ./.; }`.
  No `flake-utils`, no manual `eachDefaultSystem`, no need to list every
  input in the outputs signature - generic flake-utils patterns don't apply
  here.
- Entry points: `configurations/nixos/<host>/`, `configurations/darwin/<host>/`,
  `configurations/home/<user>/`.
- Reusable modules: `modules/shared/` (cross-platform), `modules/nixos/`,
  `modules/darwin/`, `modules/home/` (platform-specific). Host-specific
  choices go in `configurations/*/<host>/`; reusable behavior goes in
  `modules/*`.
- Overlays live in `overlays/`.
- `modules/flake-parts/toplevel.nix` wires the flake-parts glue for
  `nixos-unified` - read it before changing top-level output shape.

## Before committing

See AGENTS.md "Build, Test, and Development Commands":
- `nix fmt -- --check`
- `nix flake check --no-build --no-write-lock-file`
- `nix run .#check`
- For host-sensitive edits, also smoke-test the affected host via
  `nix eval .#nixosConfigurations.<host>...drvPath` or
  `.#darwinConfigurations.<host>.system`.

Don't touch `flake.lock` unless the change intentionally upgrades an input.

## Secrets

Never print, commit, or copy secrets into the Nix store. Reference them via
sops: `config.sops.secrets.*.path` / `config.sops.placeholder.*`. See
AGENTS.md "Asset & Configuration Tips".

## homelab module

Editing `modules/nixos/homelab/` (options, validation, networking/Caddy/DNS
behavior) requires updating `docs/homelab-services.md` in the same change -
option tables, the Validation section, and any recipe that relied on
changed options. See AGENTS.md "Documentation Sync Rules".

## Workflow

Work happens directly on `main`. Don't branch or open a PR unless
explicitly asked. Conventional Commits, subject under 50 characters when
practical. See AGENTS.md "Commit & Pull Request Guidelines".

## Issue tracker, triage, domain docs

See AGENTS.md "Agent skills" for pointers to `docs/agents/issue-tracker.md`,
`docs/agents/triage-labels.md`, and `docs/agents/domain.md`.
