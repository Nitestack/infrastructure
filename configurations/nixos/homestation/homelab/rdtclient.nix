{
  ...
}:
{
  homestation.homelab.apps.rdtclient = {
    expose = {
      mode = "public";
      host = "magnets";
    };

    services.web = {
      enable = true;
      image = "rogerfar/rdtclient:2.0.136@sha256:a05f0427946a4c3c64dc9d556c017f9a181acec320ecf218b6334a1066c11d1f";
      port = 6500;

      helpers.identity = true;
      helpers.timezone = true;

      volumes = [
        {
          type = "bind";
          source = "db";
          target = "/data/db";
        }
        {
          type = "bind";
          source = "downloads";
          target = "/data/downloads";
        }
      ];
    };
  };
}
