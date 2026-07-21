# Decision record (issue #19)

In-module notes, not a repo-wide ADR (`docs/adr/` is referenced in this
repo's `AGENTS.md` but has never actually been used here — starting that
convention was out of scope for this change). Captures settled decisions and
things discovered while implementing that the issue's own spec got wrong or
left open, so a later session doesn't re-litigate or re-discover them.

## Base module correction

The issue's "Base module" decision names `programs.pi-coding-agent` as an
upstream module living in `llm-agents-nix`. It doesn't: that flake only
exports packages (`pi` is a bare `buildNpmPackage` wrapper around
`@earendil-works/pi-coding-agent`), no Home Manager module at all. The real
module lives in `home-manager` itself
(`modules/programs/pi-coding-agent.nix`), already a flake input here. This
module layers on top of that, overriding `package` to
`llm-agents-nix`'s `pi` (same trust decision as the old omp module).

## Extension-schema corrections vs. the issue

- `pi-provider-fallback` config
  (`~/.pi/agent/extensions/provider-fallback.json`) is keyed by **provider**,
  not by role — `{ providers: { <provider>: { fallbacks: [{model,
  priority}] } } }`. It protects whichever model is currently active in the
  main session (story 13), not a separate chain per named role — the
  per-role fallback chains live in the subagent/prompt-template frontmatter
  instead, which pi's own subagent/template machinery already resolves per
  invocation.
- `@narumitw/pi-statusline`'s `palette` field is a **fixed enum**
  (`tokyo-night`, `ocean`, `sunset`, `forest`, `candy`, `neon`, `mono`) — no
  Catppuccin option. Exact-Catppuccin theming is delivered by
  `pi-catppuccin-tui` (sets `settings.theme` to
  `catppuccin-tui-mocha`/`-latte`/`-macchiato`/`-frappe`, confirmed from the
  package's actual `themes/*.json`); the statusline footer's own palette
  stays on a built-in option (not switched from its default) since there's
  nothing closer to Catppuccin to switch it to.
- `pi-subagents` has no documented global concurrency setting (its
  `concurrency` knob is per `/parallel` invocation, not a settings.json or
  extension-config ceiling). Story 12's "cap subagent concurrency low"
  couldn't be enforced declaratively as a standing default — worth
  rechecking against a newer version of the extension.
- Slash command `/plan` is already owned by the `pi-plan-mode` extension
  (read-only exploration toggle, story 22). The `plan` role's
  strongest-model-at-high-thinking command (story 6) is exposed as `/think`
  instead to avoid the collision.

## Prior art discovered mid-implementation: an abandoned pi-coding-agent module

Before writing NIM/FHS handling from scratch, `git log` turned up a real,
previously-shipped attempt at exactly this — `modules/home/pi-coding-agent/`
(commits `95bd9f86`..`b1aeaf29`, 2026-06-27 to 2026-07-11), replaced by
oh-my-pi in `ec881746`. I missed this on the first pass (didn't check
`secrets/` or `git log` for prior pi work before designing), which produced
two wrong turns that a round of `/code-review` caught and this section
corrects. Two things from that prior attempt are proven-real and reused
here:

- **`secrets/shared/nim.yaml` already exists** (added in `95bd9f86`, moved
  from `modules/secrets/nim.yaml` to its current path in a later secrets
  reorg). Top-level key `nim-api-key`, encrypted with the admin's PGP key
  only (`secrets/shared/.*`'s `creation_rules` entry — no age keys, by
  design). There was never a need to create a new secrets file or a new
  per-host secret for this — I initially missed the existing file, then
  (still wrongly) tried to invent a new host-scoped one.
- **pi's extension installer needs a real FHS layout.** `npm install`-based
  extensions with native addons need `make`/`gcc`/`python` on a real
  filesystem, which a plain Nix closure doesn't provide — the prior
  attempt's commit history is a trail of one-package-at-a-time fixes
  (`gnumake`+`gcc`, `jq`, `python3+pyyaml`, ...) before landing on wrapping
  `pi` in `pkgs.buildFHSEnv` (Linux only; Darwin has no `buildFHSEnv`, falls
  back to the unwrapped package). `default.nix` now does the same, wrapping
  whichever binary `llm-agents-nix` provides instead of `pkgs.pi-coding-agent`
  (this repo's nixpkgs pin may or may not have that attribute; unverified,
  moot since the issue explicitly chose the `llm-agents-nix` package).

## NIM secret delivery (Home Manager + GPG, not NixOS + age)

`nim-api-key` is decrypted **at the Home Manager level**, not through
`osConfig`/per-host age keys: `default.nix` imports
`sops-nix.homeManagerModules.sops`, points `sops.gnupg.home` at the user's
own `~/.gnupg`, and declares `sops.secrets.nim-api-key.sopsFile =
secrets/shared/nim.yaml`. `models.json`'s NIM provider then sets `apiKey =
"!cat ${config.sops.secrets.nim-api-key.path}"` (pi's `!command` syntax),
matching the prior attempt's exact approach. This works identically on
**every** host running this module (wslstation, nixstation, macstation) as
long as the user's GPG key is present there — no per-host NixOS age key or
new encrypted file needed at all, unlike the `pi-work` profile's
NixOS-level, host-gated secrets.

An earlier draft of this change tried to solve this the NixOS-`osConfig`
way instead (a `nim/api-key` NixOS secret, gated per host, with new
`sops.nix` scaffolding added for nixstation/macstation and placeholder age
keys in `.sops.yaml`) before this prior art was found. That was reverted —
wrong mechanism for a personal credential like this, and speculative
scaffolding for hosts that didn't need it for this secret. If nixstation or
macstation ever need a genuine host-level NixOS secret for something else,
that's a fresh, separate decision, not a byproduct of this change.

## Historical compatibility note

The abandoned prior attempt dropped `pi-web-access` and `pi-lean-ctx` in
commit `40d6a0f1` (2026-06-27) as "incompatible with 0.79.1". `pi-lean-ctx`
is out of scope here anyway (context-compression, see below). `pi-web-access`
is back in this roster per the issue — the incompatibility was against a pi
version from over three weeks before the `llm-agents-nix` pin this module
uses (2026-07-18), so it's likely resolved, but worth a first-use check
given it's the one roster entry with known history of breaking.

## Extensions installed with upstream defaults (not custom-Nix-configured)

Beyond the settings/models/prompt-template/subagent/provider-fallback/
statusline/theme files this module renders, the remaining roster entries are
declared in `settings.json`'s `packages` array only — `cc-safety-net`,
`pi-plan-mode`, `pi-web-access`, `pi-notify`, `pi-btw`, `@ayulab/pi-rewind`,
`@juicesharp/rpiv-ask-user-question`, `@narumitw/pi-codex-usage`,
`pi-hermes-memory`, `pi-agent-browser-native`, `pi-lens`, `pi-vim`. Each
ships sensible defaults on install; none needed a Nix-rendered config file
to satisfy its user story. Tune post-install if upstream defaults don't
match (e.g. `pi-web-access`'s search-provider order).

The issue's other open pre-implementation check — whether `cc-safety-net`
persists its config in `settings.json` — is resolved too, same answer as
`pi-provider-fallback`: no. It keeps its own state under `~/.cc-safety-net/`
(audit logs, a rulebook directory) and explicitly stopped loading legacy
inline config (`.safety-net.json` / `~/.cc-safety-net/config.json`) at
runtime. This module doesn't render that rulebook — installed with upstream
defaults, per above.

## Out of scope (unchanged from the issue)

Autonomy machinery, MCP adapter, cross-device memory, context-compression
extensions, signed-in-browser automation, todo tracking, `pi-cache-optimizer`
(native cache-hit-rate footer covers it), a standalone distribution repo, a
`pi doctor` equivalent, giant-context fallback models, and any edit to
encrypted secrets files.
