{
  config,
  ...
}:
let
  cfg = config.homestation.homelab;
in
{
  homestation.homelab.apps.yamtrack = {
    expose = {
      mode = "public";
      host = "track";
      service = "web";
    };

    services.web = {
      enable = true;
      image = "ghcr.io/fuzzygrim/yamtrack:0.25.3@sha256:25be9b9db46b4095275b186ab56ce8582134ce8daa7e4da216233b38374e38c3";
      port = 8000;
      restart = "always";
      dependsOn.redis.condition = "service_started";

      helpers.timezone = true;

      environment = {
        URLS = "https://track.${cfg.domain}";
        REGISTRATION = "False";
        TMDB_NSFW = "True";
        SOCIAL_PROVIDERS = "allauth.socialaccount.providers.openid_connect";
        SOCIALACCOUNT_ONLY = "True";
        REDIRECT_LOGIN_TO_SSO = "True";
        REDIS_URL = "redis://redis:6379";
      };

      environmentFiles = [ config.sops.templates."yamtrack.env".path ];

      volumes = [
        {
          type = "bind";
          source = "db";
          target = "/yamtrack/db";
        }
      ];
    };

    services.redis = {
      enable = true;
      image = "redis:8-alpine@sha256:9d317178eceac8454a2284a9e6df2466b93c745529947f0cd42a0fa9609d7005";
      restart = "always";

      volumes = [
        {
          type = "bind";
          source = "redis";
          target = "/data";
        }
      ];
    };
  };
}
