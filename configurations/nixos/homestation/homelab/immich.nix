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
      image = "ghcr.io/immich-app/immich-server:v3.0.2@sha256:e027fa892e4c20ea8cba262e0d98dbaba14af873903408928e252596608a3a47";
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
      image = "ghcr.io/immich-app/immich-machine-learning:v3.0.2-openvino@sha256:b817bc467a8f28a2b2150ae2f09845e80b5c9b59ea8832cef8f775c9ff77173c";
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
      image = "docker.io/valkey/valkey:9@sha256:3acc0687f2a2e1091fae6450d7842dd658c941338cf0a873ddd9e14b9e4ea4dd";
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
