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
      image = "linuxserver/prowlarr:2.5.2@sha256:aaa16ba7d66e413db6d0358d3b6c68d833578ba7f176f24a51807181e7637fce";
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
