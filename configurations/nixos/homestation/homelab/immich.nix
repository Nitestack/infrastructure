{
  config,
  ...
}:
let
  cfg = config.homestation.homelab;
in
{
  homestation.homelab.apps.immich = {
    expose = {
      mode = "public";
      host = "media";
      service = "web";
    };

    services.web = {
      enable = true;
      image = "ghcr.io/immich-app/immich-server:v2.7.5@sha256:c15bff75068effb03f4355997d03dc7e0fc58720c2b54ad6f7f10d1bc57efaa5";
      containerName = "immich_server";
      port = 2283;

      dependsOn = {
        redis.condition = "service_started";
        database.condition = "service_started";
      };

      environment = {
        TZ = config.time.timeZone;
      };

      environmentFiles = [ config.sops.templates."immich.env".path ];

      volumes = [
        {
          type = "bind";
          source = "upload";
          target = "/data";
        }
        {
          type = "bind";
          source = "/etc/localtime";
          target = "/etc/localtime";
          readOnly = true;
        }
      ];
    };

    services."machine-learning" = {
      enable = true;
      image = "ghcr.io/immich-app/immich-machine-learning:v2.7.5@sha256:a2501141440f10516d329fdfba2c68082e19eb9ba6016c061ac80d23beadf7f3";
      containerName = "immich_machine_learning";

      environment = {
        TZ = config.time.timeZone;
      };

      environmentFiles = [ config.sops.templates."immich.env".path ];

      volumes = [
        {
          type = "volume";
          name = "model-cache";
          target = "/cache";
        }
      ];
    };

    services.redis = {
      enable = true;
      image = "docker.io/valkey/valkey:9@sha256:4963247afc4cd33c7d3b2d2816b9f7f8eeebab148d29056c2ca4d7cbc966f2d9";
      containerName = "immich_redis";

      healthcheck = {
        test = [
          "CMD-SHELL"
          "redis-cli ping || exit 1"
        ];
      };
    };

    services.database = {
      enable = true;
      image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";
      containerName = "immich_postgres";

      environment = {
        POSTGRES_INITDB_ARGS = "--data-checksums";
      };

      environmentFiles = [ config.sops.templates."immich.env".path ];

      volumes = [
        {
          type = "bind";
          source = "db";
          target = "/var/lib/postgresql/data";
        }
      ];

      extraServiceConfig = {
        shm_size = "128mb";
      };
    };
  };
}
