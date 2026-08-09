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
      image = "ghcr.io/fuzzygrim/yamtrack:0.26.1@sha256:d99f600b95b6a7d3fa03701f43a57a21540a815c5bfe1d0448104da4058dcfae";
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
      image = "redis:8-alpine@sha256:978f0e01593e65eed801f2402944efcd936d43b5027e4908a7897baf88ed6241";

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
