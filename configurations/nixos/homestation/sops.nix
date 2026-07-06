{
  config,
  flake,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  infraSecretsFile = self + /secrets/hosts/homestation/infra.yaml;
  glanceSecretsFile = self + /secrets/hosts/homestation/glance.yaml;
  beszelSecretsFile = self + /secrets/hosts/homestation/beszel.yaml;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  config.sops = {
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/home/${config.meta.username}/.ssh/id_ed25519" ];

    secrets."cloudflared/credentials" = {
      sopsFile = infraSecretsFile;
      key = "cloudflared/credentials";
      mode = "0400";
    };
    secrets."cloudflared/certificate" = {
      sopsFile = infraSecretsFile;
      key = "cloudflared/certificate";
      mode = "0400";
    };
    secrets."smtp/password" = {
      sopsFile = infraSecretsFile;
      key = "smtp/password";
      mode = "0400";
    };
    secrets."glance/env" = {
      sopsFile = glanceSecretsFile;
      key = "glance/env";
      mode = "0400";
    };
    secrets."beszel/env" = {
      sopsFile = beszelSecretsFile;
      key = "beszel/env";
      mode = "0400";
    };
    templates."vaultwarden-smtp.env" = {
      content = ''
        SMTP_PASSWORD=${config.sops.placeholder."smtp/password"}
      '';
      mode = "0400";
    };
  };
}
