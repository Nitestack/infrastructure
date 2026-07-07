{
  config,
  ...
}:
let
  cfg = config.homestation.homelab;
  smtpTls =
    if cfg.smtp.security == "force_tls" then
      "tls"
    else if cfg.smtp.security == "off" then
      "none"
    else
      cfg.smtp.security;
in
{
  homestation.homelab.apps.pocket-id = {
    expose = {
      mode = "public";
      host = "id";
      service = "web";
    };

    services.web = {
      enable = true;
      image = "ghcr.io/pocket-id/pocket-id:v2.9.0@sha256:db1ff4e328c96900f249b7a45970f537e8549f632d7a0556d2f6a0fc932551f9";
      port = 1411;

      environment = {
        ANALYTICS_DISABLED = "true";
        APP_URL = "https://id.${cfg.domain}";
        TRUST_PROXY = "true";
        UI_CONFIG_DISABLED = "true";
        EMAILS_VERIFIED = "true";
        ALLOW_USER_SIGNUPS = "disabled";
        HOME_PAGE_URL = "/settings/apps";
        SMTP_HOST = cfg.smtp.host;
        SMTP_PORT = toString cfg.smtp.port;
        SMTP_FROM = cfg.smtp.from;
        SMTP_USER = cfg.smtp.username;
        SMTP_TLS = smtpTls;
        EMAIL_API_KEY_EXPIRATION_ENABLED = "true";
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
