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
  config.sops = {
    defaultSopsFile = secretsFile;

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
