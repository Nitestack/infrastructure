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

## NIM secret rollout (not wired on any host yet — corrected after review)

`nim/api-key` is **not** declared on any host in this change, wslstation
included. Earlier drafts of this module assumed it would be wired on
wslstation (which already has real sops + an age key), but doing that
requires a `sops.secrets."nim/api-key".sopsFile` pointing at a real,
existing encrypted file: `self + /secrets/hosts/wslstation/pi.yaml` (or
similar) would need to physically exist for the flake to evaluate at all
(the same way `secrets/hosts/wslstation/aix.yaml` already must exist for the
`aix` secrets today) — and creating that file means running `sops` against a
brand-new secret value, which is exactly the "edit to encrypted secrets
files" the issue puts out of scope and hands to the human. So this change
adds no `nim/api-key` secret anywhere; `hasNimKey` in `default.nix`
evaluates `false` on all three hosts today. The private profile still
renders and works fully — NIM-routed roles (`commit`, `scout`, `vision`)
just have no key until the user, on wslstation, creates
`secrets/hosts/wslstation/pi.yaml` (`sops secrets/hosts/wslstation/pi.yaml`
with a `nim/api-key: <value>` entry) and adds the matching
`sops.secrets."nim/api-key"` declaration to
`configurations/nixos/wslstation/sops.nix`. `nixstation` and `macstation`
got `sops.nix` scaffolding and `.sops.yaml` key-group entries in this same
change (module import + `age.sshKeyPaths`, no secrets declared yet) so that
follow-up is a small diff once real age keys exist for those hosts too —
see the TODOs in `.sops.yaml` and those two `sops.nix` files. No encrypted
file was created or edited by this change.

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
