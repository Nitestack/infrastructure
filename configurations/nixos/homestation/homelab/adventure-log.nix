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
      image = "ghcr.io/seanmorley15/adventurelog-frontend:v0.13.0@sha256:db459d08b5f3b900e9a646920e58c1087497a9f070f9142ed8f0fca8e81b1350";
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
      image = "postgis/postgis:16-3.5@sha256:94146ac37bc61e2322f88016056c5920729cb8c64c8542ed590af8fc2abdac07";
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
      image = "ghcr.io/seanmorley15/adventurelog-backend:v0.13.0@sha256:00724fc1f511635e3675538a326915474d486fcc9409a8b0f574da543e5980a1";
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
      }
      // cfg.lib.smtpEnv {
        hostVar = "EMAIL_HOST";
        portVar = "EMAIL_PORT";
        usernameVar = "EMAIL_HOST_USER";
        fromVar = "DEFAULT_FROM_EMAIL";
      }
      // {
        EMAIL_USE_TLS = cfg.lib.smtpSecurityMapped {
          starttls = "True";
          forceTls = "False";
          off = "False";
        };
        EMAIL_USE_SSL = cfg.lib.smtpSecurityMapped {
          starttls = "False";
          forceTls = "True";
          off = "False";
        };
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
