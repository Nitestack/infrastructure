{
  config,
  ...
}:
let
  cfg = config.homelab;
  renderedMuseumConfigName = "ente-museum.yaml";
  renderedMuseumConfigPath = config.sops.templates.${renderedMuseumConfigName}.path;
  enteApiHost = "ente.${cfg.domain}";
in
{
  homestation.renderedFiles.${renderedMuseumConfigName} = {
    source = ./museum.yml;
    replacements = {
      "@JWT_SECRET@" = config.sops.placeholder."ente/jwt-secret";
      "@POSTGRES_PASSWORD@" = config.sops.placeholder."ente/db-password";
      "@SMTP_PASSWORD@" = config.sops.placeholder."smtp/password";
      "@SMTP_HOST@" = cfg.smtp.host;
      "@SMTP_PORT@" = toString cfg.smtp.port;
      "@SMTP_USERNAME@" = cfg.smtp.username;
      "@SMTP_EMAIL@" = cfg.smtp.from;
    };
  };

  homelab.caddy.extraHosts = ''
    @ente-museum host ${enteApiHost}
    handle @ente-museum {
      reverse_proxy ${cfg.lib.serviceUrl "ente" "museum"}
    }
  '';

  homelab.apps.ente = {
    expose = {
      mode = "public";
      host = "2fa";
      targetService = "web";
    };

    services.web = {
      enable = true;
      image = "ghcr.io/ente/web:latest@sha256:e96baa8f17cb6ba944e74ca0964ba6c1d754726fd45b970c81a4b86dd4a82981";
      containerName = "ente-web";
      port = 3003;

      environment = {
        ENTE_API_ORIGIN = "https://${enteApiHost}";
      };
    };

    services.museum = {
      enable = true;
      image = "ghcr.io/ente/server:171e334ee4bd9c0ac3d9515fe072f65ce9ca5013@sha256:5018ec3558acec229cc621799d61b91841f5f27f70c1d066dc7c5983c531cf90";
      containerName = "ente-museum";
      port = 8080;
      networks = [ cfg.ingressNetwork ];

      dependsOn.postgres.condition = "service_healthy";

      volumes = [
        {
          type = "bind";
          source = renderedMuseumConfigPath;
          target = "/museum.yaml";
          readOnly = true;
        }
      ];

      healthcheck = {
        test = [
          "CMD"
          "wget"
          "--quiet"
          "--tries=1"
          "--spider"
          "http://localhost:8080/ping"
        ];
        interval = "60s";
        timeout = "5s";
        retries = 3;
        startPeriod = "120s";
      };
    };

    services.postgres = {
      enable = true;
      image = "postgres:15@sha256:74e110c41804365e3915fcc09d5e7a1eff50161aaa94d5da0e58e0cd75ae509c";
      containerName = "ente-postgres";

      environment = {
        POSTGRES_USER = "pguser";
        POSTGRES_DB = "ente_db";
      };

      environmentFiles = [ config.sops.templates."ente.env".path ];

      volumes = [
        {
          type = "bind";
          source = "db";
          target = "/var/lib/postgresql/data";
        }
      ];

      healthcheck = {
        test = [
          "CMD-SHELL"
          "pg_isready -q -d ente_db -U pguser"
        ];
        startPeriod = "40s";
      };
    };
  };
}
