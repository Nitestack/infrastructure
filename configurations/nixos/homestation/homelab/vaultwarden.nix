{
  config,
  ...
}:
let
  cfg = config.homelab;
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
      image = "vaultwarden/server:1.37.5@sha256:4fe17f415f90087377d37c755e0ea3cf189dcc6794e49cdd2a9adbb4937d9e1f";
      port = 80;

      environment = {
        DOMAIN = appUrl cfg.apps.vaultwarden;
        SIGNUPS_ALLOWED = "false";
      }
      // cfg.lib.smtpEnv {
        hostVar = "SMTP_HOST";
        portVar = "SMTP_PORT";
        securityVar = "SMTP_SECURITY";
        fromVar = "SMTP_FROM";
        usernameVar = "SMTP_USERNAME";
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
