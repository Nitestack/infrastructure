{ config, flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;

  infraSecretsFile = self + /secrets/hosts/homestation/infra.yaml;
  beetsSecretsFile = self + /secrets/hosts/homestation/beets.yaml;
  pocketIdSecretsFile = self + /secrets/hosts/homestation/pocket-id.yaml;
  glanceSecretsFile = self + /secrets/hosts/homestation/glance.yaml;
  beszelSecretsFile = self + /secrets/hosts/homestation/beszel.yaml;
  shelfmarkSecretsFile = self + /secrets/hosts/homestation/shelfmark.yaml;
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
    secrets."pocket-id/encryption-key" = {
      sopsFile = pocketIdSecretsFile;
      key = "encryption-key";
      mode = "0400";
    };
    secrets."beets/lastfm-key" = {
      sopsFile = beetsSecretsFile;
      key = "lastfm-key";
      mode = "0400";
    };
    secrets."pocket-id/maxmind-license-key" = {
      sopsFile = pocketIdSecretsFile;
      key = "maxmind-license-key";
      mode = "0400";
    };
    secrets."glance/github-api-token" = {
      sopsFile = infraSecretsFile;
      key = "github/api-token";
      mode = "0400";
    };
    secrets."glance/user" = {
      sopsFile = glanceSecretsFile;
      key = "user";
      mode = "0400";
    };
    secrets."glance/password-hash" = {
      sopsFile = glanceSecretsFile;
      key = "password-hash";
      mode = "0400";
    };
    secrets."glance/secret" = {
      sopsFile = glanceSecretsFile;
      key = "secret";
      mode = "0400";
    };
    secrets."beszel/email" = {
      sopsFile = beszelSecretsFile;
      key = "email";
      mode = "0400";
    };
    secrets."beszel/password" = {
      sopsFile = beszelSecretsFile;
      key = "password";
      mode = "0400";
    };
    secrets."beszel/agent-token" = {
      sopsFile = beszelSecretsFile;
      key = "agent-token";
      mode = "0400";
    };
    secrets."beszel/agent-key" = {
      sopsFile = beszelSecretsFile;
      key = "agent-key";
      mode = "0400";
    };
    secrets."navidrome/lastfm-key" = {
      sopsFile = infraSecretsFile;
      key = "lastfm/key";
      mode = "0400";
    };
    secrets."navidrome/lastfm-secret" = {
      sopsFile = infraSecretsFile;
      key = "lastfm/secret";
      mode = "0400";
    };
    secrets."hardcover/api-key" = {
      sopsFile = infraSecretsFile;
      key = "hardcover/api-key";
      mode = "0400";
    };
    secrets."shelfmark/prowlarr-api-key" = {
      sopsFile = shelfmarkSecretsFile;
      key = "prowlarr/api-key";
      mode = "0400";
    };
    templates."vaultwarden-smtp.env" = {
      content = ''
        SMTP_PASSWORD=${config.sops.placeholder."smtp/password"}
      '';
      mode = "0400";
    };
    templates."pocket-id.env" = {
      content = ''
        MAXMIND_LICENSE_KEY=${config.sops.placeholder."pocket-id/maxmind-license-key"}
        ENCRYPTION_KEY=${config.sops.placeholder."pocket-id/encryption-key"}
        SMTP_PASSWORD=${config.sops.placeholder."smtp/password"}
      '';
      mode = "0400";
    };
    templates."glance.env" = {
      content = ''
        GITHUB_API_TOKEN=${config.sops.placeholder."glance/github-api-token"}
        GLANCE_USER=${config.sops.placeholder."glance/user"}
        GLANCE_PASSWORD_HASH=${config.sops.placeholder."glance/password-hash"}
        GLANCE_SECRET=${config.sops.placeholder."glance/secret"}
      '';
      mode = "0400";
    };
    templates."beszel.env" = {
      content = ''
        USER_EMAIL=${config.sops.placeholder."beszel/email"}
        USER_PASSWORD=${config.sops.placeholder."beszel/password"}
        TOKEN=${config.sops.placeholder."beszel/agent-token"}
        KEY=${config.sops.placeholder."beszel/agent-key"}
      '';
      mode = "0400";
    };
    templates."navidrome.env" = {
      content = ''
        ND_LASTFM_APIKEY=${config.sops.placeholder."navidrome/lastfm-key"}
        ND_LASTFM_SECRET=${config.sops.placeholder."navidrome/lastfm-secret"}
      '';
      mode = "0400";
    };
    templates."calibre-web-automated.env" = {
      content = ''
        HARDCOVER_TOKEN=${config.sops.placeholder."hardcover/api-key"}
      '';
      mode = "0400";
    };
    templates."shelfmark.env" = {
      content = ''
        EMAIL_SMTP_PASSWORD=${config.sops.placeholder."smtp/password"}
        PROWLARR_API_KEY=${config.sops.placeholder."shelfmark/prowlarr-api-key"}
        HARDCOVER_API_KEY=${config.sops.placeholder."hardcover/api-key"}
      '';
      mode = "0400";
    };
  };
}
