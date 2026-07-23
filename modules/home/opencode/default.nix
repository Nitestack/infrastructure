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

  opencodePackage = inputs.opencode-vim.packages.${pkgs.stdenv.hostPlatform.system}.opencode;

  hasWorkProfile = config.programs.aix.enable or false;

  workConfigDir = "${config.home.homeDirectory}/.config/opencode-work";

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
in
{
  programs.opencode = {
    enable = true;
    package = opencodePrivatePackage;
    settings = import ./private.nix;
  };

  home.file = lib.optionalAttrs hasWorkProfile {
    "${workConfigDir}/opencode.json".text = builtins.toJSON (import ./work.nix);
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
        export OPENCODE_CONFIG_DIR=${workConfigDir}
        exec ${lib.getExe opencodePackage} "$@"
      '';
    })
  ];
}
