{
  config,
  flake,
  lib,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;

  aixProfiles = [
    "p"
    "adp"
    "swtb"
    "p-t"
  ];
  secretsFile = self + /secrets/hosts/wslstation/aix.yaml;
  mkProfileSecret =
    profile:
    lib.nameValuePair "aix/${profile}" {
      owner = config.meta.username;
      mode = "0400";
      key = "aix/${profile}/key";
    };
  mkLabelSecret =
    profile:
    lib.nameValuePair "aix/${profile}-label" {
      owner = config.meta.username;
      mode = "0400";
      key = "aix/${profile}/label";
    };
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  config.sops = {
    defaultSopsFile = secretsFile;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/home/${config.meta.username}/.ssh/id_ed25519" ];

    secrets =
      builtins.listToAttrs ((map mkProfileSecret aixProfiles) ++ (map mkLabelSecret aixProfiles))
      // {
        "aix/base-url" = {
          owner = config.meta.username;
          mode = "0400";
          key = "aix/base_url";
        };
      };
  };
}
