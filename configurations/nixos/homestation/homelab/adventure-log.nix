{
  config,
  ...
}:
let
  cfg = config.homelab;
  inherit (cfg.lib) appUrl;
in
{
  homelab.apps."adventure-log" = {
    expose = {
      mode = "public";
      host = "travel";
      targetService = "web";
    };

    services.web = {
      enable = true;
      image = "ghcr.io/seanmorley15/adventurelog-frontend:v0.12.1@sha256:bdc5a81bd6e35f7a22d5c26b6b57870f08d4141749f5510a6f2cd1fbb7d4f9d7";
      containerName = "adventurelog-frontend";
      port = 3000;
      dependsOn.server.condition = "service_started";

      environment = {
        # Upstream explicitly sets port 8000 (gunicorn direct) for SSR server-to-server calls,
        # bypassing nginx. Per .env.example: "PLEASE DON'T CHANGE :)"
        PUBLIC_SERVER_URL = "http://server:8000";
        ORIGIN = appUrl cfg.apps.adventure-log;
        BODY_SIZE_LIMIT = "Infinity";
      };
    };

    services.db = {
      enable = true;
      image = "postgis/postgis:16-3.5@sha256:e547a8319d5b134527c6d1e0307acde1311aa57f8eb7fbf78810dafc6a6b41fe";
      containerName = "adventurelog-db";

      environment = {
        POSTGRES_DB = "database";
        POSTGRES_USER = "adventure";
      };

      environmentFiles = [ config.sops.templates."adventure-log-db.env".path ];

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
      image = "ghcr.io/seanmorley15/adventurelog-backend:v0.12.1@sha256:c0f622e4e0dd98a1cd3e401fd11461bf87808d5e4c821efd0b7b3c8de43c6065";
      containerName = "adventurelog-backend";
      port = 80;
      dependsOn.db.condition = "service_started";

      environment = {
        PGHOST = "db";
        POSTGRES_DB = "database";
        POSTGRES_USER = "adventure";
        DJANGO_ADMIN_USERNAME = "admin";
        DJANGO_ADMIN_EMAIL = cfg.smtp.from;
        PUBLIC_URL = appUrl cfg.apps.adventure-log;
        CSRF_TRUSTED_ORIGINS = appUrl cfg.apps.adventure-log;
        DEBUG = "False";
        FRONTEND_URL = appUrl cfg.apps.adventure-log;
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

      environmentFiles = [ config.sops.templates."adventure-log-server.env".path ];

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
