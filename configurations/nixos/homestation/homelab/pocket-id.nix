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
      image = "pocketid/pocket-id:v2.10.0@sha256:183f1ae8426f3af0b65878fae9ddbe9a0515f6548c04d8ebb640ad1abd9c8fce";
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
