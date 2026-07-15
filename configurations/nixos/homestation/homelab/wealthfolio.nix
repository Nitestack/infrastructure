{
  config,
  ...
}:
let
  cfg = config.homelab;
  username = config.meta.username;
  inherit (cfg.lib) appUrl;
in
{
  homelab.apps.wealthfolio = {
    expose = {
      mode = "public";
      host = "wealth";
    };

    services.web = {
      enable = true;
      image = "wealthfolio/wealthfolio:3.6.2@sha256:f24c607692c1b494a477382aa3dfedc11ede1b433768b66546940c8f6b8a474f";
      port = 8088;

      environment = {
        WF_LISTEN_ADDR = "0.0.0.0:8088";
        WF_DB_PATH = "/data/wealthfolio.db";
        WF_CORS_ALLOW_ORIGINS = appUrl cfg.apps.wealthfolio;
        WF_AUTH_TOKEN_TTL_MINUTES = "60";
        WF_REQUEST_TIMEOUT_MS = "30000";

        WF_OIDC_ISSUER_URL = appUrl cfg.apps.pocket-id;
        WF_OIDC_REDIRECT_URL = "${appUrl cfg.apps.wealthfolio}/api/v1/auth/oidc/callback";
        WF_OIDC_ALLOW_ANY = "true";
      };

      environmentFiles = [ config.sops.templates."wealthfolio.env".path ];

      volumes = [
        {
          type = "bind";
          source = "data";
          target = "/data";
          owner = username;
          group = "users";
        }
      ];

      healthcheck = {
        test = [
          "CMD"
          "wget"
          "--quiet"
          "--tries=1"
          "--spider"
          "http://127.0.0.1:8088/api/v1/healthz"
        ];
        interval = "30s";
        timeout = "10s";
        retries = 3;
        startPeriod = "15s";
      };

      extraServiceConfig = {
        read_only = true;
        tmpfs = [ "/tmp:size=64M" ];
        security_opt = [ "no-new-privileges:true" ];
      };
    };
  };
}
