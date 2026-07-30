{
  config,
  ...
}:
let
  cfg = config.homelab;
  inherit (cfg.lib) appUrl;
  smtpTls =
    if cfg.smtp.security == "force_tls" then
      "tls"
    else if cfg.smtp.security == "off" then
      "none"
    else
      cfg.smtp.security;
in
{
  homelab.apps.pocket-id = {
    expose = {
      mode = "public";
      host = "id";
    };

    services.web = {
      enable = true;
      image = "pocketid/pocket-id:v2.12.0@sha256:4a277d141d6069fd9a7b321a9aca80f4b9812b8fa122ee566d2f15900e3d8448";
      port = 1411;

      environment = {
        ANALYTICS_DISABLED = "true";
        APP_URL = appUrl cfg.apps.pocket-id;
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
