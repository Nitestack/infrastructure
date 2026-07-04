{
  config,
  flake,
  ...
}:
let
  inherit (flake) inputs;
  secretsFile = ./secrets/cloudflared.yaml;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  config.sops = {
    defaultSopsFile = secretsFile;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/home/${config.meta.username}/.ssh/id_ed25519" ];

    secrets."cloudflared/credentials" = {
      key = "cloudflared/credentials";
      mode = "0400";
    };
    secrets."cloudflared/certificate" = {
      key = "cloudflared/certificate";
      mode = "0400";
    };
  };
}
