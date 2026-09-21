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
      image = "ghcr.io/dannyvfilms/floppy:26.8.27@sha256:790eeaea6d23caa91457cb73e675ab6bdb39e36f03a64beb80a04904543142e1";
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
      image = "redis:8-alpine@sha256:978f0e01593e65eed801f2402944efcd936d43b5027e4908a7897baf88ed6241";
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
