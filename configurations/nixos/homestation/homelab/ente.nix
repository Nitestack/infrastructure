{
  config,
  ...
}:
let
  cfg = config.homestation.homelab;
  renderedMuseumConfigName = "ente-museum.yaml";
  renderedMuseumConfigPath = config.sops.templates.${renderedMuseumConfigName}.path;
  enteApiHost = "ente.${cfg.domain}";
in
{
  homestation.renderedFiles.${renderedMuseumConfigName} = {
    source = ./ente/museum.yml;
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

  homestation.homelab.caddy.extraHosts = ''
    @ente-museum host ${enteApiHost}
    handle @ente-museum {
      reverse_proxy ente-museum:8080
    }
  '';

  homestation.homelab.apps.ente = {
    expose = {
      mode = "public";
      host = "2fa";
      targetService = "web";
    };

    services.web = {
      enable = true;
      image = "ghcr.io/ente/web:latest@sha256:a0bc969c02cc563037a7e3ac1b0ad6def906164674b332380324d35a3d9bc853";
      containerName = "ente-web";
      port = 3003;

      environment = {
        ENTE_API_ORIGIN = "https://${enteApiHost}";
      };
    };

    services.museum = {
      enable = true;
      image = "ghcr.io/ente/server:latest@sha256:4dd5747b3322e81edfe2b482443b444068f2033ab488bf4566bbe00fa3c685e7";
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
        {
          type = "bind";
          source = "data";
          target = "/data";
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
      image = "postgres:15@sha256:3b0d656f5fff31c7d8a64f500a703dcf3f35e98ce78f602831a73059a5e6a012";
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
