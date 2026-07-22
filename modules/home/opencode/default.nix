# ╭──────────────────────────────────────────────────────────╮
# │ OpenCode                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  flake,
  config,
  lib,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;

  opencodePackage = inputs.llm-agents-nix.packages.${pkgs.stdenv.hostPlatform.system}.opencode;

  hasWorkProfile = config.programs.aix.enable or false;

  workConfigFile = "${config.home.homeDirectory}/.config/opencode-work/opencode.json";

  opencodePrivatePackage = pkgs.symlinkJoin {
    name = "opencode-private";
    paths = [ opencodePackage ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/opencode \
        --run 'export NVIDIA_NIM_API_KEY="$(cat ${config.sops.secrets.nim-api-key.path})"'
    '';
    passthru = {
      inherit (opencodePackage) version;
    };
  };
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops.secrets.nim-api-key.sopsFile = self + /secrets/shared/nim.yaml;

  programs.opencode = {
    enable = true;
    package = opencodePrivatePackage;
    settings = import ./private.nix;
  };

  home.file = lib.optionalAttrs hasWorkProfile {
    "${workConfigFile}".text = builtins.toJSON (import ./work.nix);
  };

  home.packages = lib.optionals hasWorkProfile [
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
        export LITELLM_ROOT_BASE_URL="''${LITELLM_BASE_URL%/v1}"
        export OPENCODE_CONFIG=${workConfigFile}
        exec ${lib.getExe opencodePackage} "$@"
      '';
    })
  ];
}
