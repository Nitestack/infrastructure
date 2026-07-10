{
  config,
  ...
}:
let
  username = config.meta.username;
in
{
  homelab.apps.prowlarr = {
    expose = {
      mode = "public";
      host = "index";
      targetService = "web";
    };

    services.web = {
      enable = true;
      image = "linuxserver/prowlarr:2.4.0@sha256:536036aeb2c740d1a660ccf143b58a8bd6222f09010258fdfc10a538af7bec78";
      port = 9696;

      volumes = [
        {
          type = "bind";
          source = "data";
          target = "/config";
          owner = username;
          group = "users";
        }
      ];
    };

    services.flaresolverr = {
      enable = true;
      image = "flaresolverr/flaresolverr:v3.5.0@sha256:139dfee1c6f89249c8d665d1333a42e8ec74ec0a86bc6bb1c8461e10d3a66a47";

      helpers.timezone = true;

      volumes = [
        {
          type = "bind";
          source = "flaresolverr/data";
          target = "/config";
          owner = username;
          group = "users";
        }
      ];
    };
  };
}
