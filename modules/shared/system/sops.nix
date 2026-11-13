# ╭──────────────────────────────────────────────────────────╮
# │ Shared Secrets (sops)                                    │
# ╰──────────────────────────────────────────────────────────╯
{
  config,
  flake,
  lib,
  ...
}:
let
  inherit (flake.inputs) self;
  inherit (config) meta;
  homeDirectory = "/home/${meta.username}";

  aixProfiles = [
    "p"
    "ae"
    "nim"
    "adp"
    "ac"
    "acs"
    "nim4"
    "ae2"
  ];
  aixSecretsFile = self + /secrets/shared/aix.yaml;
  mkAixSecret =
    name: key:
    lib.nameValuePair name {
      inherit key;
      sopsFile = aixSecretsFile;
      owner = meta.username;
      mode = "0400";
    };
in
{
  sops = {
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "${homeDirectory}/.ssh/id_ed25519" ];

    secrets = {
      "nim-api-key" = {
        sopsFile = self + /secrets/shared/nim.yaml;
        owner = meta.username;
        mode = "0400";
      };
    }
    // builtins.listToAttrs (
      (map (profile: mkAixSecret "aix/${profile}" "aix/${profile}/key") aixProfiles)
      ++ (map (profile: mkAixSecret "aix/${profile}-label" "aix/${profile}/label") aixProfiles)
      ++ [ (mkAixSecret "aix/base-url" "aix/base_url") ]
    );
  };
}
