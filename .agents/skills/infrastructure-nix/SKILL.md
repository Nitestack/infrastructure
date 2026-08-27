---
name: infrastructure-nix
description: Use when editing this repo's Nix flake - hosts, modules, overlays, the homelab module, or sops secrets. Points to the authoritative rules in AGENTS.md instead of duplicating them.
---

# Infrastructure Nix

Read `AGENTS.md` first; it is the source of truth for repository-wide rules.
This skill adds only Nix-specific traps that are not obvious from the tree.

## Repository-specific traps

- `flake.nix` uses `nixos-unified.lib.mkFlake`; do not introduce generic
  `flake-utils` or manual `eachDefaultSystem` wiring.
- `modules/flake-parts/toplevel.nix` controls the top-level output shape; read
  it before changing flake outputs.
- Keep host choices in `configurations/*/<host>/` and reusable behavior in
  `modules/*`.
- Changes to `modules/nixos/homelab/` require matching updates to
  `docs/homelab-services.md`, including affected options, validation, and
  recipes.

## Nix-specific checks

For host-sensitive edits, evaluate the affected host in addition to the checks
listed in `AGENTS.md`. Do not update `flake.lock` unless intentionally
upgrading an input.
