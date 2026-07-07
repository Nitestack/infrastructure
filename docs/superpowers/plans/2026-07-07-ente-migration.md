# Ente Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate the Raspberry Pi Ente stack to `homestation.homelab.apps.ente` while preserving `2fa.npham.de` and `ente.npham.de`.

**Architecture:** Define one homelab app with `web`, `museum`, and `postgres` services. Use the existing rendered-files and sops template patterns to provide `museum.yml`, and add a manual Caddy site block plus LAN DNS record for the second hostname because the current homelab API exposes one hostname per app.

**Tech Stack:** NixOS modules, `homestation-homelab`, Arion, sops-nix

## Global Constraints

- Keep host-specific behavior in `configurations/nixos/homestation/`.
- Do not change `flake.lock`.
- Treat evaluation as the test boundary.
- Update `docs/raspberry-pi-5-migration-checklist.md` when the migration is complete.

---

### Task 1: Add Ente homelab app and secrets wiring

**Files:**
- Create: `configurations/nixos/homestation/homelab/ente.nix`
- Create: `configurations/nixos/homestation/homelab/ente/museum.yml`
- Modify: `configurations/nixos/homestation/sops.nix`
- Modify: `configurations/nixos/homestation/default.nix`
- Modify: `docs/raspberry-pi-5-migration-checklist.md`

**Interfaces:**
- Consumes: `config.homestation.homelab`, `config.sops.placeholder`, `config.sops.templates`, `homestation.renderedFiles`
- Produces: `homestation.homelab.apps.ente`, `config.sops.templates."ente.env"`, `config.sops.templates."ente-museum.yaml"`

- [ ] Fail an eval for the missing `ente` app.
- [ ] Add rendered `museum.yml`, secrets, and the homelab app definition.
- [ ] Import the module and update the migration checklist.
- [ ] Re-run homestation evaluation and repo checks.
