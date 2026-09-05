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
      image = "ghcr.io/fuzzygrim/yamtrack:0.26.3@sha256:186754674a14c1c3ab094f59c1906a6256f09ab7a27665491a83be982fcc4d18";
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
      image = "redis:8-alpine@sha256:becdda6c7f4b3fb42e42fd7f120bbf5c54c4caaaf16f26da24e4563d2c1f0576";

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
