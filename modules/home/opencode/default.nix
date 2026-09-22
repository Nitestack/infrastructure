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

  opencode2ConfigDir = "${config.home.homeDirectory}/.config/opencode2";
  workConfigDir = "${config.home.homeDirectory}/.config/opencode-work";

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
  privateSettings = import ./private.nix;

  mkSettings =
    cfg:
    (
      removeAttrs sharedSettings [
        "tui"
        "permissions"
      ]
      // removeAttrs cfg [ "tui" ]
    )
    // {
      plugin = (sharedSettings.plugin or [ ]) ++ (cfg.plugin or [ ]);
    };

  mkTui =
    cfg:
    (sharedSettings.tui // (cfg.tui or { }))
    // {
      plugin = (sharedSettings.tui.plugin or [ ]) ++ ((cfg.tui or { }).plugin or [ ]);
    };

  opencode2Settings = {
    permissions = sharedSettings.permissions;
  }
  // privateSettings;

  opencodePrivatePackage = pkgs.symlinkJoin {
    name = "opencode2";
    paths = [ opencode2Package ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/opencode2 \
        --set OPENCODE_CONFIG_DIR ${lib.escapeShellArg opencode2ConfigDir} \
        --run 'export NVIDIA_API_KEY="$(cat ${osConfig.sops.secrets.nim-api-key.path})"'
    '';
    passthru = {
      inherit (opencode2Package) version;
    };
  };
in
{
  home.file = {
    "${opencode2ConfigDir}/AGENTS.md".text = context;
    "${opencode2ConfigDir}/opencode.json".text = builtins.toJSON (
      { "$schema" = "https://opencode.ai/config.json"; } // opencode2Settings
    );
  }
  // lib.optionalAttrs hasWorkProfile {
    "${workConfigDir}/AGENTS.md".text = context;
    "${workConfigDir}/opencode.json".text = builtins.toJSON (mkSettings (import ./work.nix));
    "${workConfigDir}/tui.json".text = builtins.toJSON (mkTui (import ./work.nix));
  };

  home.packages = [
    opencodePrivatePackage
  ]
  ++ lib.optionals hasWorkProfile [
    (pkgs.writeShellApplication {
      name = "opencode";
      text = ''
        if [ -z "''${LITELLM_API_KEY:-}" ]; then
          echo "LITELLM_API_KEY is required for the work profile" >&2
          exit 1
        fi
        if [ -z "''${LITELLM_BASE_URL:-}" ]; then
          echo "LITELLM_BASE_URL is required for the work profile" >&2
          exit 1
        fi
        export OPENCODE_CONFIG_DIR=${workConfigDir}
        exec ${lib.getExe pkgs.opencode} "$@"
      '';
    })
  ];
}
