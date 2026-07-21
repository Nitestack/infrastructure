# Frozen roster, npm-version-pinned. Bump deliberately; versions verified
# against the npm registry when this list was written.
#
# Split by profile: nim/litellm are provider extensions, and private and
# work never share a provider (see roles/private.nix, roles/work.nix) — so
# each is only installed into the profile that actually talks to it.
#
# Probation: independently removable without redesign if one misbehaves.
{
  common = [
    "pi-subagents@0.35.1"
    "pi-prompt-template-model@0.10.0"
    "pi-provider-fallback@1.0.4"
    "pi-web-access@0.13.0"
    "cc-safety-net@1.0.6"
    "pi-plan-mode@0.4.8"
    "@ayulab/pi-rewind@0.4.6"
    "@juicesharp/rpiv-ask-user-question@1.20.0"
    "pi-notify@1.4.0"
    "@narumitw/pi-codex-usage@0.20.0"
    "pi-btw@0.4.1"
    "@narumitw/pi-statusline@0.23.0"
    "pi-catppuccin-tui@0.1.3"
    # Probation
    "pi-hermes-memory@0.8.1"
    "pi-agent-browser-native@0.2.71"
    "pi-lens@3.8.71"
    # pi-vim@0.12.1 removed: fails to load at runtime ("Cannot find module
    # '@earendil-works/pi-coding-agent'" from its own node_modules). Probation
    # extension misbehaving — per the issue's own policy, removal is the
    # remedy, not redesign. See NOTES.md.
  ];

  # Registers the "nvidia-nim" provider; only roles/private.nix references it.
  private = [ "@diegovisk/pi-nvidia-nim@1.1.0" ];

  # Registers the "litellm" provider; only roles/work.nix references it.
  work = [ "pi-provider-litellm@1.3.0" ];
}
