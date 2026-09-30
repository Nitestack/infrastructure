# ╭──────────────────────────────────────────────────────────╮
# │ OpenCode                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  flake,
  config,
  osConfig,
  lib,
  ...
}:
let
  inherit (flake) inputs;

  opencode2Package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode2;

  hasWorkProfile = config.programs.aix.enable or false;
  isWsl = osConfig.wsl.enable or false;

  workConfigDir = "${config.xdg.configHome}/opencode-work";

  platformDescription =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "This is a Nix-managed macOS environment (`${pkgs.stdenv.hostPlatform.system}`)."
    else if isWsl then
      "This is a NixOS environment running under WSL2 (`${pkgs.stdenv.hostPlatform.system}`)."
    else
      "This is a NixOS environment (`${pkgs.stdenv.hostPlatform.system}`).";

  contextSections = lib.splitString "<!-- WSL_ONLY -->" (builtins.readFile ./context.md);
  context =
    assert lib.assertMsg (
      builtins.length contextSections == 2
    ) "context.md must contain one WSL marker";
    lib.replaceStrings [ "@platformDescription@" ] [ platformDescription ] (
      builtins.elemAt contextSections 0 + lib.optionalString isWsl (builtins.elemAt contextSections 1)
    );
  sharedSettings = import ./shared.nix;

  mkSettings =
    cfg:
    let
      plugins = (sharedSettings.plugins or [ ]) ++ (cfg.plugins or [ ]);
    in
    (removeAttrs sharedSettings [
      "cli"
      "plugins"
    ])
    // removeAttrs cfg [
      "cli"
      "plugins"
    ]
    // lib.optionalAttrs (plugins != [ ]) { inherit plugins; };

  workLaunch =
    if hasWorkProfile then
      ''
        if [ -n "''${AIX_PROFILE:-}" ]; then
          if [ -z "''${LITELLM_API_KEY:-}" ]; then
            echo "AIX_PROFILE is set, but LITELLM_API_KEY is missing" >&2
            exit 1
          fi
          if [ -z "''${LITELLM_BASE_URL:-}" ]; then
            echo "AIX_PROFILE is set, but LITELLM_BASE_URL is missing" >&2
            exit 1
          fi
          export OPENCODE_CONFIG_DIR=${lib.escapeShellArg workConfigDir}
          if [ "$#" -eq 0 ] || [[ "$1" == -* ]] || [ -d "$1" ]; then
            set -- --standalone "$@"
          fi
          exec ${lib.escapeShellArg "${opencode2Package}/bin/opencode2"} "$@"
        fi
      ''
    else
      "";

  opencodeLauncher = pkgs.writeShellApplication {
    name = "opencode";
    text = workLaunch + ''
      NVIDIA_API_KEY="$(cat ${lib.escapeShellArg osConfig.sops.secrets.nim-api-key.path})"
      export NVIDIA_API_KEY
      exec ${lib.escapeShellArg "${opencode2Package}/bin/opencode2"} "$@"
    '';
  };
in
{
  programs.opencode = {
    enable = true;
    package = null;
    inherit context;
    settings = mkSettings (import ./private.nix);
  };

  xdg.configFile = {
    "opencode/cli.json".text = builtins.toJSON sharedSettings.cli;
    "opencode/opencode-quota/quota-toast.json".text = builtins.toJSON (import ./quota.nix);
  }
  // lib.optionalAttrs hasWorkProfile {
    "opencode-work/AGENTS.md".text = context;
    "opencode-work/opencode.json".text = builtins.toJSON (mkSettings (import ./work.nix));
  };

  home.packages = [ opencodeLauncher ];
}
