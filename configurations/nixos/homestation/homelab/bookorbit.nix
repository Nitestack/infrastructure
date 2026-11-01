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
  homelab.apps.bookorbit = {
    expose = {
      mode = "public";
      host = "lib";
      targetService = "app";
    };

    services.app = {
      enable = true;
      containerName = "bookorbit-app";
      image = "ghcr.io/bookorbit/bookorbit:3.6.0@sha256:bbb5da52e96dbbff1dd36f55454f9845e6cde264b4b3428a3ea783124a4ca62e";
      port = 3000;
      dependsOn.db.condition = "service_healthy";

      helpers.userIds = true;
      helpers.timezone = true;

      privileges.capabilities = {
        add = [
          "CHOWN"
          "DAC_OVERRIDE"
          "FOWNER"
          "SETGID"
          "SETUID"
        ];
        drop = [ "ALL" ];
      };

      extraServiceConfig = {
        init = true;
        read_only = true;
        tmpfs = [ "/tmp" ];
        security_opt = [ "no-new-privileges:true" ];
        stop_grace_period = "30s";
      };

      environment = {
        NODE_ENV = "production";
        PORT = "3000";
        APP_URL = appUrl cfg.apps.bookorbit;
        DATABASE_URL = "";
        POSTGRES_HOST = "db";
        POSTGRES_PORT = "5432";
        POSTGRES_USER = "bookorbit";
        POSTGRES_DB = "bookorbit";
        BOOK_DOCK_PATH = "/book-dock";
        LIBRARY_BROWSE_ROOT = "/books";
      };

      environmentFiles = [ config.sops.templates."bookorbit-app.env".path ];

      volumes = [
        {
          type = "bind";
          source = "data";
          target = "/data";
          owner = username;
          group = "users";
        }
        {
          type = "bind";
          source = "books";
          target = "/books";
          owner = username;
          group = "users";
        }
        {
          type = "bind";
          source = "book-dock";
          target = "/book-dock";
          owner = username;
          group = "users";
        }
      ];
    };

    services.db = {
      enable = true;
      containerName = "bookorbit-db";
      image = "pgvector/pgvector:pg18@sha256:c29f30688a9ad961691bdf0ec1650717cc132a5814619d80f80463d6e4c42e47";

      environment = {
        PGDATA = "/var/lib/postgresql/data/pgdata";
        POSTGRES_DB = "bookorbit";
        POSTGRES_USER = "bookorbit";
      };

      environmentFiles = [ config.sops.templates."bookorbit-db.env".path ];

      volumes = [
        {
          type = "bind";
          source = "db";
          target = "/var/lib/postgresql/data";
        }
      ];

      healthcheck = {
        test = [
          "CMD"
          "pg_isready"
          "-U"
          "bookorbit"
          "-d"
          "bookorbit"
        ];
        interval = "10s";
        timeout = "5s";
        retries = 10;
        startPeriod = "20s";
      };
    };
  };
}
