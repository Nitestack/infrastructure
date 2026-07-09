{
  config,
  ...
}:
let
  cfg = config.homestation.homelab;
  username = config.meta.username;
in
{
  homestation.homelab.apps.wealthfolio = {
    expose = {
      mode = "public";
      host = "wealth";
    };

    services.web = {
      enable = true;
      image = "wealthfolio/wealthfolio:3.6.1@sha256:2819715df7057a46a29f30cd3c3e713df3bbe424b3a1bf7f2c92dc1dea1f84a6";
      port = 8088;

      environment = {
        WF_LISTEN_ADDR = "0.0.0.0:8088";
        WF_DB_PATH = "/data/wealthfolio.db";
        WF_CORS_ALLOW_ORIGINS = "https://wealth.${cfg.domain}";
        WF_AUTH_TOKEN_TTL_MINUTES = "60";
        WF_REQUEST_TIMEOUT_MS = "30000";
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
