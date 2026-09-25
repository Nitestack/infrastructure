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
      image = "pocketid/pocket-id:v2.16.0@sha256:9366436f3fd21619ed7e5709fa0acac88130f73414ec8ee1caf768fc487111ea";
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
