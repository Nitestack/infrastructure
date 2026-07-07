{
  config,
  ...
}:
let
  cfg = config.homestation.homelab;
  smtp = cfg.smtp;
in
{
  homestation.homelab.apps.vaultwarden = {
    expose = {
      mode = "public";
      host = "vault";
      service = "web";
    };

    services.web = {
      enable = true;
      image = "vaultwarden/server:latest@sha256:d626d04934cd1192ad8ced1adb975099fca78cec33ab467d2d3c923cde7f3b0c";
      port = 80;

      environment = {
        DOMAIN = "https://vault.${cfg.domain}";
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
