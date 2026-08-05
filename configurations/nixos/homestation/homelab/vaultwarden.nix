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
      image = "vaultwarden/server:1.37.1@sha256:ebdfe70701c60ac0c28c697e787cea767d7972940b786037b29fe0d507f821e8";
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
