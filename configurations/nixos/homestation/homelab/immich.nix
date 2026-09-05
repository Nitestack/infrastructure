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
      image = "ghcr.io/immich-app/immich-server:v3.1.0@sha256:079cc990b26a88d71f96027341c67329cb11829d4c341ce33b3718fe0f84cbfa";
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
      image = "ghcr.io/immich-app/immich-machine-learning:v3.1.0-openvino@sha256:627dfaf9339037be132209784883f7be13c1deb6be799454797bf6f231331f5b";
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
      image = "docker.io/valkey/valkey:9@sha256:475ee65cc75c327407458f5096cdd36954b3de3fc83f4c8ac31a4a8edecbf49e";
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
