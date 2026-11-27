{
  config,
  ...
}:
let
  cfg = config.homelab;
  inherit (cfg.lib) appUrl;
in
{
  homelab.apps.floppy = {
    expose = {
      mode = "public";
      host = "track";
      targetService = "web";
    };

    services.web = {
      enable = true;
      containerName = "floppy";
      image = "ghcr.io/dannyvfilms/floppy:26.11.12@sha256:f8ed2ad2ce767f3fb16663244206b586d92f21b88159253a015ff55d27fccb5e";
      port = 8000;
      dependsOn.redis.condition = "service_healthy";

      helpers.timezone = true;

      environment = {
        URLS = appUrl cfg.apps.floppy;
        DEBUG = "False";
        DEMO_ACCOUNT_ENABLED = "False";
        # Disable after the first Floppy account has been created.
        REGISTRATION = "True";
        SOCIAL_PROVIDERS = "allauth.socialaccount.providers.openid_connect";
        SOCIALACCOUNT_ONLY = "True";
        REDIRECT_LOGIN_TO_SSO = "True";
        REDIS_URL = "redis://redis:6379";
        USE_X_FORWARDED = "True";
        USE_X_FORWARDED_PROTO = "True";
      };

      environmentFiles = [ config.sops.templates."floppy.env".path ];

      volumes = [
        {
          type = "bind";
          source = "db";
          target = "/floppy/db";
        }
        {
          type = "bind";
          source = "backups";
          target = "/floppy/backups";
        }
      ];
    };

    services.redis = {
      enable = true;
      containerName = "floppy-redis";
      image = "redis:8-alpine@sha256:5af80107c1eeecb484a2269b80a26d12bfa6521787da4663bd9f19f60a163483";
      command = [
        "redis-server"
        "--appendonly"
        "yes"
        "--save"
        ""
        "--maxmemory"
        "256mb"
        "--maxmemory-policy"
        "volatile-lru"
      ];
      healthcheck = {
        test = [
          "CMD"
          "redis-cli"
          "ping"
        ];
        interval = "10s";
        timeout = "3s";
        retries = 10;
      };

      volumes = [
        {
          type = "volume";
          volume = "redis_data";
          target = "/data";
        }
      ];
    };
  };
}
