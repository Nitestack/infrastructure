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
    settings = lib.mkForce (commonSettings // {
      defaultProvider = "work-hub";
    });

    models = {
      providers = {
        "work-hub" = {
          api = "anthropic-messages";
          baseUrl = "!cat /run/secrets/anthropic-base-url";
          apiKey = "!cat /run/secrets/anthropic/swtb";
          models = [ ];
        };
      };
    };
  };
}
