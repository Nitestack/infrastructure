{
  config,
  ...
}:
let
  cfg = config.homelab;
  inherit (cfg.lib) appUrl;
in
{
  homelab.apps.pocket-id = {
    expose = {
      mode = "public";
      host = "id";
    };

    services.web = {
      enable = true;
      image = "pocketid/pocket-id:v2.13.0@sha256:c9c1d7b70006968d673a1073df048a3fdec73ccb54e182320b56bb911340f6f1";
      port = 1411;

      environment = {
        ANALYTICS_DISABLED = "true";
        APP_URL = appUrl cfg.apps.pocket-id;
        TRUST_PROXY = "true";
        UI_CONFIG_DISABLED = "true";
        EMAILS_VERIFIED = "true";
        ALLOW_USER_SIGNUPS = "disabled";
        HOME_PAGE_URL = "/settings/apps";
        EMAIL_API_KEY_EXPIRATION_ENABLED = "true";
      }
      // cfg.lib.smtpEnv {
        hostVar = "SMTP_HOST";
        portVar = "SMTP_PORT";
        fromVar = "SMTP_FROM";
        usernameVar = "SMTP_USER";
      }
      // {
        SMTP_TLS = cfg.lib.smtpSecurityMapped {
          starttls = "starttls";
          forceTls = "tls";
          off = "none";
        };
      };

      environmentFiles = [
        config.sops.templates."pocket-id.env".path
      ];

      volumes = [
        {
          type = "bind";
          source = "data";
          target = "/app/data";
        }
      ];

      healthcheck = {
        test = [
          "CMD"
          "/app/pocket-id"
          "healthcheck"
        ];
        interval = "1m30s";
        timeout = "5s";
        retries = 2;
        startPeriod = "10s";
      };
    };
  };
}
