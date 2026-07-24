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
      image = "ghcr.io/immich-app/immich-server:v3.0.3@sha256:118946756b2274f741be9d301428401be8716024c407b019cd424fa1e6f518e6";
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
      image = "ghcr.io/immich-app/immich-machine-learning:v3.0.3-openvino@sha256:d46dfbc0e190d22c6d8faa18ae2e51f2aa5e8ead942ea76f1bb0b420af9504fe";
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
      image = "docker.io/valkey/valkey:9@sha256:8e8d64b405ce18f41b8e5ee20aa4687a8ed0022d1298f2ce31cdcf3a76e09411";
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
