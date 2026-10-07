# ╭──────────────────────────────────────────────────────────╮
# │ Shared Secrets (sops)                                    │
# ╰──────────────────────────────────────────────────────────╯
{
  config,
  flake,
  ...
}:
let
  inherit (flake.inputs) self;
  inherit (config) meta;
  homeDirectory = "/home/${meta.username}";
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
