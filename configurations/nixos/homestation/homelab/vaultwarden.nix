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
      image = "vaultwarden/server:1.37.2@sha256:094b5689ed81549bd293418395c7cf495ae9d960fc2d4928cef2083ef913d912";
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
