{
  config,
  ...
}:
{
  homelab.apps.immich = {
    expose = {
      mode = "public";
      host = "media";
      targetService = "web";
    };

    services.web = {
      enable = true;
      image = "ghcr.io/immich-app/immich-server:v3.2.4@sha256:04225d8995a221de3b73a6131fe25eed14448830e54998f30877a70f48c6ac13";
      containerName = "immich_server";
      port = 2283;

      dependsOn = {
        redis.condition = "service_started";
        database.condition = "service_started";
      };

      helpers.timezone = true;

      environment = {
        DB_USERNAME = "postgres";
        DB_DATABASE_NAME = "immich";
      };

      environmentFiles = [ config.sops.templates."immich.env".path ];

      # Intel UHD 630 acceleration for Quick Sync video transcoding.
      privileges.devices = [ "/dev/dri:/dev/dri" ];
      extraServiceConfig.group_add = [ (toString config.ids.gids.render) ];

      volumes = [
        {
          type = "bind";
          source = "library";
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
      image = "ghcr.io/immich-app/immich-machine-learning:v3.2.4-openvino@sha256:9249078942f49455c0b8ed9d2d986a6e754b9401d966ba93e32f8a2c4946dd0c";
      containerName = "immich_machine_learning";

      # Intel UHD 630 acceleration for Smart Search / Facial Recognition.
      privileges.devices = [ "/dev/dri:/dev/dri" ];
      extraServiceConfig.group_add = [ (toString config.ids.gids.render) ];

      volumes = [
        {
          type = "volume";
          volume = "model-cache";
          target = "/cache";
        }
      ];
    };

    services.redis = {
      enable = true;
      image = "docker.io/valkey/valkey:9@sha256:418652cfb58ef879d4978c33553735d7147016032d5aefaa14c828e611eb9dfd";
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
        DB_USERNAME = "postgres";
        DB_DATABASE_NAME = "immich";
      };

      environmentFiles = [ config.sops.templates."immich.env".path ];

      volumes = [
        {
          type = "bind";
          source = "postgres";
          target = "/var/lib/postgresql/data";
        }
      ];

      extraServiceConfig = {
        shm_size = "128mb";
      };
    };
  };
}
