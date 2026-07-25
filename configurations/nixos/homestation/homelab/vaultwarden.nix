{
  config,
  ...
}:
let
  cfg = config.homelab;
  smtp = cfg.smtp;
  inherit (cfg.lib) appUrl;
in
{
  homelab.apps.vaultwarden = {
    expose = {
      mode = "public";
      host = "vault";
    };

    services.web = {
      enable = true;
      image = "vaultwarden/server:1.37.0@sha256:e6443e3d5ed8fcee2204b89ec778d7f24d0173bcc42d1ea34f990304f5f63f51";
      port = 80;

      environment = {
        DOMAIN = appUrl cfg.apps.vaultwarden;
        SIGNUPS_ALLOWED = "false";
        SMTP_HOST = smtp.host;
        SMTP_PORT = toString smtp.port;
        SMTP_SECURITY = smtp.security;
        SMTP_FROM = smtp.from;
        SMTP_USERNAME = smtp.username;
      };

      environmentFiles = [
        config.sops.templates."vaultwarden-smtp.env".path
      ];

      volumes = [
        {
          type = "bind";
          source = "data";
          target = "/data";
        }
      ];
    };
  };
}
