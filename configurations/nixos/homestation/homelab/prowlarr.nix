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
      image = "linuxserver/prowlarr:2.6.5@sha256:b3b00047ed20f6ce2b16780145cb6a0acb51c9e28ea6aa6f5dcd33c7034f1797";
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
      image = "flaresolverr/flaresolverr:v3.5.2@sha256:c80ae007ce2ccdcd217a12426e4f039ef763ff90738c808d38810c3e59323767";

      helpers.timezone = true;
    };
  };
}
