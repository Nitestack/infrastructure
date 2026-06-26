{
  config,
  flake,
  lib,
  ...
}:
let
  inherit (flake) inputs;

  cfg = config.wslstation.anthropic;
  secretsFile = ./secrets/anthropic.yaml;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  options.wslstation.anthropic = {
    profile = lib.mkOption {
      type = lib.types.enum [
        "p"
        "adp"
        "swtb"
      ];
      default = "p";
      description = "Active Anthropic license for wslstation.";
    };

    secretName = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "anthropic/${cfg.profile}";
      description = "Selected sops secret key for the active Anthropic profile.";
    };
  };

  config.sops = {
    defaultSopsFile = secretsFile;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/home/${config.meta.username}/.ssh/id_ed25519" ];
    secrets."${cfg.secretName}" = {
      owner = config.meta.username;
      mode = "0400";
    };
    secrets.anthropic-base-url = {
      owner = config.meta.username;
      mode = "0400";
      key = "anthropic/base_url";
    };
  };
}
