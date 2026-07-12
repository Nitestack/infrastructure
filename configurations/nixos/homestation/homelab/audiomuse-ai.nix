{ config, ... }: {
  homelab.apps.audiomuse-ai = {
    expose = {
      mode = "private";
      host = "muse";
      targetService = "audiomuse-ai-flask";
    };

    services.redis = {
      enable = true;
      image = "redis:7-alpine";
      containerName = "audiomuse-redis";
      helpers.timezone = true;
      volumes = [
        {
          type = "volume";
          volume = "redis_data";
          target = "/data";
        }
      ];
    };

    services.postgres = {
      enable = true;
      image = "postgres:15-alpine";
      containerName = "audiomuse-postgres";
      helpers.timezone = true;
      environmentFiles = [ config.sops.templates."audiomuse-ai.env".path ];
      environment = {
        POSTGRES_USER = "audiomuse";
        POSTGRES_DB = "audiomusedb";
      };
      volumes = [
        {
          type = "bind";
          source = "db";
          target = "/var/lib/postgresql/data";
        }
      ];
    };

    services.audiomuse-ai-flask = {
      enable = true;
      image = "ghcr.io/neptunehub/audiomuse-ai:latest";
      containerName = "audiomuse-ai-flask-app";
      port = 8000;
      helpers.timezone = true;
      environmentFiles = [ config.sops.templates."audiomuse-ai.env".path ];
      environment = {
        SERVICE_TYPE = "flask"; # Tells the container to run the Flask app
        # DATABASE_URL is now constructed by config.py from the following:
        POSTGRES_USER = "audiomuse";
        POSTGRES_DB = "audiomusedb";
        POSTGRES_HOST = "postgres"; # Service name of the postgres container
        POSTGRES_PORT = "5432"; # Internal port - always 5432 inside the Docker network
        REDIS_URL = "redis://redis:6379/0"; # Connects to the 'redis' service
        TEMP_DIR = "/app/temp_audio";
      };
      volumes = [
        {
          type = "volume";
          volume = "temp-audio-flask";
          target = "/app/temp_audio";
        }
        {
          type = "volume";
          volume = "plugins-flask";
          target = "/app/plugin/installed";
        }
      ];
      dependsOn = {
        redis.condition = "service_started";
        postgres.condition = "service_started";
      };
    };

    services.audiomuse-ai-worker = {
      enable = true;
      image = "ghcr.io/neptunehub/audiomuse-ai:latest";
      containerName = "audiomuse-ai-worker-instance";
      helpers.timezone = true;
      environmentFiles = [ config.sops.templates."audiomuse-ai.env".path ];
      environment = {
        SERVICE_TYPE = "worker"; # Tells the container to run the RQ worker
        # DATABASE_URL is now constructed by config.py from the following:
        POSTGRES_USER = "audiomuse";
        POSTGRES_DB = "audiomusedb";
        POSTGRES_HOST = "postgres"; # Service name of the postgres container
        POSTGRES_PORT = "5432"; # Internal port - always 5432 inside the Docker network
        REDIS_URL = "redis://redis:6379/0"; # Connects to the 'redis' service
        TEMP_DIR = "/app/temp_audio";
      };
      volumes = [
        {
          type = "volume";
          volume = "temp-audio-worker";
          target = "/app/temp_audio";
        }
        {
          type = "volume";
          volume = "plugins-worker";
          target = "/app/plugin/installed";
        }
      ];
      dependsOn = {
        redis.condition = "service_started";
        postgres.condition = "service_started";
      };
    };
  };
}
