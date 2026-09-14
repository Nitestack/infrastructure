# OpenCode Home Module

This module renders the agent tooling installed by the Home Manager profiles.

- `default.nix` assembles the package and generated config files.
- `context.md` is the global instruction template. Keep exactly one
  `<!-- WSL_ONLY -->` marker; `default.nix` includes the text after it only on
  the WSL host.
- `shared.nix` is merged into both profiles.
- `private.nix` configures the local/private OpenCode profile.
- `work.nix` configures the optional `opencode-work` profile and reads
  `LITELLM_API_KEY` and `LITELLM_BASE_URL` from the environment at runtime.
- `quota.nix` is the generated quota-plugin settings source.

Keep private and work routing separate. Never hardcode API keys or other
credentials in these files or in generated Home Manager text. The private
package wrapper reads its NVIDIA key from the sops secret path supplied by the
host; preserve that boundary when changing the wrapper.

The `opencode-work` launcher sets `OPENCODE_CONFIG_DIR` to the work profile.
Preserve that isolation instead of replacing it with a global XDG or single
config-file override. Model-discovery filters are JavaScript regular
expressions: validate both include and exclude filters after edits, and keep
Anthropic discovery disabled unless that is an explicit change.

Model and plugin changes are configuration changes, not runtime experiments:
keep versions intentional, preserve the role/provider separation and profile
merge behaviour, and evaluate the host that imports the affected Home Manager
profile. No live provider call is required for the normal repository check.
