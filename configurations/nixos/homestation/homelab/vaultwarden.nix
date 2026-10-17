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
      image = "vaultwarden/server:1.37.4@sha256:efb3cde962015fcc036b2ea625242248611943b27212ebf4392841fb30fad055";
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
