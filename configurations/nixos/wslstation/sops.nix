{
  config,
  flake,
  lib,
  ...
}:
let
  inherit (flake) inputs;

  profiles = [
    "p"
    "adp"
    "swtb"
    "p-t"
  ];

  cfg = config.wslstation.aihub;
  secretsFile = ./secrets/aihub.yaml;
  mkProfileSecrets = profile: [
    (lib.nameValuePair "aihub/${profile}" {
      owner = config.meta.username;
      mode = "0400";
      key = "aihub/${profile}/key";
    })
    (lib.nameValuePair "aihub/${profile}-label" {
      owner = config.meta.username;
      mode = "0400";
      key = "aihub/${profile}/label";
    })
  ];
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  options.wslstation.aihub = {
    profile = lib.mkOption {
      type = lib.types.enum profiles;
      default = "p";
      description = "Default ai hub profile for wrapper-driven launches on wslstation.";
    };

    profiles = lib.mkOption {
      type = lib.types.listOf (lib.types.enum profiles);
      readOnly = true;
      default = profiles;
      description = "Available ai hub profiles.";
    };

    secretName = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "aihub/${cfg.profile}";
      description = "Selected sops secret key for the default ai hub profile.";
    };

    baseUrlSecretName = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "aihub/base-url";
      description = "Selected sops secret key for the shared ai hub base URL.";
    };
  };

  config.sops = {
    defaultSopsFile = secretsFile;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/home/${config.meta.username}/.ssh/id_ed25519" ];

    secrets = builtins.listToAttrs (lib.concatMap mkProfileSecrets profiles) // {
      "${cfg.baseUrlSecretName}" = {
        owner = config.meta.username;
        mode = "0400";
        key = "aihub/base_url";
      };
    };
  };
}
