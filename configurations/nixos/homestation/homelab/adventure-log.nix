{
  config,
  ...
}:
let
  cfg = config.homestation.homelab;
in
{
  homestation.homelab.apps."adventure-log" = {
    expose = {
      mode = "public";
      host = "travel";
      service = "web";
    };

    services.web = {
      enable = true;
      image = "ghcr.io/seanmorley15/adventurelog-frontend:v0.12.1@sha256:b9c492d93927825b0f7187ac4614cebd748ce712947d5283c16888956460fc8a";
      containerName = "adventurelog-frontend";
      port = 3000;
      dependsOn.server.condition = "service_started";

      environment = {
        PUBLIC_SERVER_URL = "http://server:8000";
        ORIGIN = "https://travel.${cfg.domain}";
        BODY_SIZE_LIMIT = "Infinity";
      };
    };

    services.db = {
      enable = true;
      image = "postgis/postgis:16-3.5@sha256:1d95a92144c40198b46908fd92ac365e85d35eaf31bfc36f06c2c09a090c0538";
      containerName = "adventurelog-db";

      environment = {
        POSTGRES_DB = "database";
        POSTGRES_USER = "adventure";
      };

      environmentFiles = [ config.sops.templates."adventure-log.env".path ];

      volumes = [
        {
          type = "bind";
          source = "db";
          target = "/var/lib/postgresql/data";
        }
      ];
    };

    services.server = {
      enable = true;
      image = "ghcr.io/seanmorley15/adventurelog-backend:v0.12.1@sha256:30e0db65690df137ed6017a62b5cbd64aad229c512e92b2b1be402277db5b109";
      containerName = "adventurelog-backend";
      port = 80;
      dependsOn.db.condition = "service_started";

      environment = {
        PGHOST = "db";
        POSTGRES_DB = "database";
        POSTGRES_USER = "adventure";
        DJANGO_ADMIN_USERNAME = "admin";
        DJANGO_ADMIN_EMAIL = cfg.smtp.from;
        PUBLIC_URL = "https://travel.${cfg.domain}";
        CSRF_TRUSTED_ORIGINS = "https://travel.${cfg.domain}";
        DEBUG = "False";
        FRONTEND_URL = "https://travel.${cfg.domain}";
        DISABLE_REGISTRATION = "True";
        SOCIALACCOUNT_ALLOW_SIGNUP = "True";
        EMAIL_BACKEND = "email";
        EMAIL_HOST = cfg.smtp.host;
        EMAIL_USE_TLS = if cfg.smtp.security == "starttls" then "True" else "False";
        EMAIL_PORT = toString cfg.smtp.port;
        EMAIL_USE_SSL = if cfg.smtp.security == "force_tls" then "True" else "False";
        EMAIL_HOST_USER = cfg.smtp.username;
        DEFAULT_FROM_EMAIL = cfg.smtp.from;
      };

      environmentFiles = [ config.sops.templates."adventure-log.env".path ];

      volumes = [
        {
          type = "bind";
          source = "data";
          target = "/code/media";
        }
      ];
    };
  };
}
