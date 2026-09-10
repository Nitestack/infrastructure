# Repository Guidelines

## Scope and Layout

This file applies to the whole repository. A deeper `AGENTS.md` adds rules for
that subtree; read it before editing there.

Nix flake for NixOS, NixOS WSL, macOS, and Home Manager.

- `flake.nix`: inputs and `nixos-unified` outputs.
- `configurations/`: host and Home Manager entry points; see its `AGENTS.md`.
- `modules/`: reusable cross-platform and platform-specific behaviour; see its
  `AGENTS.md`.
- `checks/`: evaluation-time regression checks.
- `opentofu/cloudflare/`: Cloudflare edge state managed separately from NixOS.
- `docs/`: maintained operator documentation; `docs/agents/` contains agent
  workflow references.
- `secrets/`: sops-encrypted values only.
- `CLAUDE.md`: compatibility pointer to this file; keep agent rules here rather
  than duplicating them.
- `overlays/`, `images/`, `.github/workflows/`: overlays, assets, and CI.

Keep host choices in `configurations/*/<host>/`; put reusable behaviour in
`modules/*`.

## Workflow

- Start with `git status --short --branch` and preserve unrelated changes,
  including staged changes.
- Trace a change to its owning host and module before editing. Keep the patch at
  the narrowest responsible layer.
- Use current source and documentation as the interface; consult history for
  intent and regressions, not as a reason to restore obsolete paths or APIs.
- Run `git diff --check` and `nix run .#check` after Nix changes. There is no
  separate unit-test suite; evaluation is the test boundary.
- For a host-sensitive change, evaluate the exact target with
  `nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath --no-write-lock-file`
  or
  `nix eval .#darwinConfigurations.<host>.system --apply 's: s.drvPath' --no-write-lock-file`.
- Use `switch` for ordinary NixOS changes. Reserve `boot` for first-install
  flows or changes that must be selected at the next boot; the WSL exception is
  documented in `configurations/nixos/wslstation/AGENTS.md`.
- When the current machine is `wslstation`, sudo is passwordless. Read the WSL
  guide, verify it with `sudo -n true`, and use its `nix-switch` workflow so the
  configured `nh` wrapper selects `wslstation` and `~/infrastructure` without
  waiting for a prompt.

## Git and CI

- `nix develop` configures `core.hooksPath` to `.githooks`. Its pre-commit hook
  formats staged Nix blobs and preserves unstaged hunks; do not replace that
  partial-staging-safe flow with whole-worktree formatting followed by `git add`.
- CI always checks formatting. Changes to `*.nix` or `flake.lock` also evaluate
  all four host outputs; run the affected-host evaluation locally before
  relying on CI.
- Do not stage or commit unless the user asks for it. Never include unrelated
  staged or unstaged work in a task patch.
- Treat routine container image and dependency bumps as Renovate work; make a
  manual update only when it is the explicit task.

## Commands

- `nix fmt`: format Nix files.
- `nix fmt -- --check`: verify formatting without rewriting files.
- `nix flake check --no-build --no-write-lock-file`: evaluate checks without
  builds or lockfile writes.
- `nix run .#check`: run formatting and flake evaluation together.

## Code, Tests, Git

Use `nixfmt` conventions: 2 spaces, focused modules, explicit imports, and
purpose-based names (for example `audio.nix`). Do not place host settings in
shared modules without platform guards.

Do not change `flake.lock` unless upgrading inputs intentionally. Work on
`main`; branch or open a PR only when asked. Use concise Conventional Commit
subjects, ideally under 50 characters. PRs must state affected hosts/modules
and verification; add screenshots only for visible desktop or wallpaper
changes.

## Assets and Secrets

Keep personal or machine-local assets out of Git (for example `images/local/`)
and never commit unrelated local changes. Never expose, print, commit, copy, or
put secrets in the Nix store. Reference them through sops paths or placeholders:
`config.sops.secrets.*.path` and `config.sops.placeholder.*`.

## Agent References

- Issues and PRDs: GitHub Issues in `Nitestack/infrastructure` via `gh`; see
  `docs/agents/issue-tracker.md`.
- Triage workflow and labels: `docs/agents/triage-labels.md`.
- Domain sources and the current absence of repo-wide context/ADR files:
  `docs/agents/domain.md`.

## Documentation

Treat documentation outside `docs/agents/` as maintained operator documentation,
not agent memory. When a change affects durable user knowledge (setup,
host/service behaviour or exposure, commands, integrations, secrets/state,
backup/recovery, or limitations), update or add focused `docs/` documentation
in the same change and link broadly useful docs from the README.

Keep it concise, actionable, and safe to share: omit secrets, local
credentials, and transient details; document operational gaps accurately.

`docs/homelab-services.md` is authoritative for `modules/nixos/homelab/`. When
changing its API (options or validation) or networking/Caddy/DNS behaviour,
update affected option tables, validation notes, and recipes.
