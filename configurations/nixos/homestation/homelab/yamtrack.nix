{
  config,
  ...
}:
let
  cfg = config.homelab;
  inherit (cfg.lib) appUrl;
in
{
  homelab.apps.yamtrack = {
    expose = {
      mode = "public";
      host = "track";
      targetService = "web";
    };

    services.web = {
      enable = true;
      image = "ghcr.io/fuzzygrim/yamtrack:0.25.3@sha256:742faeac188635289afbe74eaaf5a355270d44c246a39098249e5c62eb63468a";
      port = 8000;
      dependsOn.redis.condition = "service_started";

      helpers.timezone = true;

      environment = {
        URLS = appUrl cfg.apps.yamtrack;
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
