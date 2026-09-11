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

  opencodePackage = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
  opencode2Package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode2;

  hasWorkProfile = config.programs.aix.enable or false;

  opencode2ConfigDir = "${config.home.homeDirectory}/.config/opencode2";
  workConfigDir = "${config.home.homeDirectory}/.config/opencode-work";

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
      plugin = sharedSettings.plugin ++ (cfg.plugin or [ ]);
    };

  mkTui =
    cfg:
    (sharedSettings.tui // (cfg.tui or { }))
    // {
      plugin = (sharedSettings.tui.plugin or [ ]) ++ ((cfg.tui or { }).plugin or [ ]);
    };

  mkOpenCode2Agent = agent: {
    model = agent.model;
    request.body = lib.intersectAttrs {
      reasoningEffort = null;
      textVerbosity = null;
    } agent;
  };

  opencode2Settings = {
    "$schema" = "https://opencode.ai/config.json";
    permissions = sharedSettings.permissions;
    providers = privateSettings.provider or { };
    agents = lib.mapAttrs (_: mkOpenCode2Agent) (privateSettings.agent or { });
  };

  opencodePrivatePackage = pkgs.symlinkJoin {
    name = "opencode-private";
    paths = [ opencodePackage ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/opencode \
        --run 'export NVIDIA_API_KEY="$(cat ${osConfig.sops.secrets.nim-api-key.path})"'
    '';
    passthru = {
      inherit (opencodePackage) version;
    };
  };

  opencode2Launcher = pkgs.writeShellApplication {
    name = "opencode2";
    text = ''
      export OPENCODE_CONFIG_DIR="${opencode2ConfigDir}"
      exec ${lib.getExe opencode2Package} "$@"
    '';
  };
in
{
  programs.opencode = {
    enable = true;
    package = opencodePrivatePackage;
    settings = mkSettings privateSettings;
    tui = mkTui privateSettings;
  };

  xdg.configFile."opencode/opencode-quota/quota-toast.jsonc".text = builtins.toJSON (
    import ./quota.nix
  );

  home.file = {
    "${opencode2ConfigDir}/opencode.json".text = builtins.toJSON opencode2Settings;
  }
  // lib.optionalAttrs hasWorkProfile {
    "${workConfigDir}/opencode.json".text = builtins.toJSON (
      { "$schema" = "https://opencode.ai/config.json"; } // mkSettings (import ./work.nix)
    );
    "${workConfigDir}/tui.json".text = builtins.toJSON (
      { "$schema" = "https://opencode.ai/tui.json"; } // mkTui (import ./work.nix)
    );
  };

  home.packages = [
    opencode2Launcher
  ]
  ++ lib.optionals hasWorkProfile [
    (pkgs.writeShellApplication {
      name = "opencode-work";
      text = ''
        if [ -z "''${LITELLM_API_KEY:-}" ]; then
          echo "LITELLM_API_KEY is required for opencode-work" >&2
          exit 1
        fi
        if [ -z "''${LITELLM_BASE_URL:-}" ]; then
          echo "LITELLM_BASE_URL is required for opencode-work" >&2
          exit 1
        fi
        export OPENCODE_CONFIG_DIR=${workConfigDir}
        exec ${lib.getExe opencodePackage} "$@"
      '';
    })
  ];
}
