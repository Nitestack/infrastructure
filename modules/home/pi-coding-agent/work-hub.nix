# ╭──────────────────────────────────────────────────────────╮
# │ Pi Coding Agent — Work Hub Provider (wslstation only)    │
# ╰──────────────────────────────────────────────────────────╯
{ lib, ... }:
let
  commonSettings = import ./_settings.nix;
in
{
  programs.pi-coding-agent = {
    # lib.mkForce wins over default.nix's normal-priority settings,
    # replacing defaultProvider = "codex" with "work-hub" while
    # preserving all common settings via the shared helper.
    settings = lib.mkForce (
      commonSettings
      // {
        defaultProvider = "work-hub";
      }
    );

    models = {
      providers = {
        "work-hub" = {
          api = "anthropic-messages";
          baseUrl = "!sh -lc 'base_url=\"\${AIHUB_BASE_URL:-}\"; test -n \"$base_url\" || { echo \"AIHUB_BASE_URL is required; use aihub pi <profile> (recommended), aihub shell <profile>, eval \\\"\\$(aihub env --format sh <profile>)\\\" in sh/zsh, or aihub env --format json <profile> | from json | load-env in nu.\" >&2; exit 1; }; printf %s \"$base_url\"'";
          apiKey = "!sh -lc 'api_key=\"\${AIHUB_API_KEY:-}\"; test -n \"$api_key\" || { echo \"AIHUB_API_KEY is required; use aihub pi <profile> (recommended), aihub shell <profile>, eval \\\"\\$(aihub env --format sh <profile>)\\\" in sh/zsh, or aihub env --format json <profile> | from json | load-env in nu.\" >&2; exit 1; }; printf %s \"$api_key\"'";
          models = [ ];
        };
      };
    };
  };
}
