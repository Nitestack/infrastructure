{
  config,
  ...
}:
let
  username = config.meta.username;
in
{
  homestation.homelab.apps.prowlarr = {
    expose = {
      mode = "public";
      host = "index";
      service = "web";
    };

    services.web = {
      enable = true;
      image = "linuxserver/prowlarr:2.4.0@sha256:3e9bd62ca90c97c5df75b7012e10a29f6926e62807deeddc1dc89e6e2fd141e1";
      port = 9696;
      restart = "always";

      helpers.linuxserver = true;

      volumes = [
        {
          type = "bind";
          source = "data";
          target = "/config";
          hostPath.user = username;
          hostPath.group = "users";
        }
      ];
    };

    services.flaresolverr = {
      enable = true;
      image = "flaresolverr/flaresolverr:v3.5.0@sha256:139dfee1c6f89249c8d665d1333a42e8ec74ec0a86bc6bb1c8461e10d3a66a47";
      restart = "always";

      helpers.timezone = true;

      volumes = [
        {
          type = "bind";
          source = "flaresolverr/data";
          target = "/config";
          hostPath.user = username;
          hostPath.group = "users";
        }
      ];
    };
  };
}
