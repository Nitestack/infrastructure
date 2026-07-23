# ╭──────────────────────────────────────────────────────────╮
# │ Shared Secrets (sops)                                    │
# ╰──────────────────────────────────────────────────────────╯
{
  config,
  pkgs,
  flake,
  ...
}:
let
  inherit (flake.inputs) self;
  inherit (config) meta;
  homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${meta.username}";
in
{
  sops = {
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "${homeDirectory}/.ssh/id_ed25519" ];

    secrets."nim-api-key" = {
      sopsFile = self + /secrets/shared/nim.yaml;
      owner = meta.username;
      mode = "0400";
    };
  };
}
