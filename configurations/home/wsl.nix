# ╭──────────────────────────────────────────────────────────╮
# │ NixOS WSL Home Manager Configuration                     │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  lib,
  osConfig,
  ...
}:
let
  inherit (flake.inputs) self;

  secretName = osConfig.wslstation.anthropic.secretName;
  secretPath = lib.attrByPath [
    secretName
    "path"
  ] null osConfig.sops.secrets;
  baseUrlPath = lib.attrByPath [
    "anthropic-base-url"
    "path"
  ] null osConfig.sops.secrets;
in
{
  # ── Imports ───────────────────────────────────────────────────────────
  imports = [
    self.homeModules.base
    self.homeModules.interactive-only
  ];

  programs.nushell.extraConfig = lib.mkAfter (
    lib.optionalString (secretPath != null || baseUrlPath != null) ''
      let anthropic_key_path = "${if secretPath != null then secretPath else ""}"
      let anthropic_base_url_path = "${if baseUrlPath != null then baseUrlPath else ""}"
      if ($anthropic_key_path | is-not-empty) and ($anthropic_key_path | path exists) {
        load-env {
          ANTHROPIC_API_KEY: (open --raw $anthropic_key_path | str trim)
        }
      }
      if ($anthropic_base_url_path | is-not-empty) and ($anthropic_base_url_path | path exists) {
        load-env {
          ANTHROPIC_BASE_URL: (open --raw $anthropic_base_url_path | str trim)
        }
      }
    ''
  );
}
