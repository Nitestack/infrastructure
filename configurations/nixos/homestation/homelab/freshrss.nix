{
  config,
  ...
}:
{
  homestation.homelab.apps.freshrss = {
    expose = {
      mode = "public";
      host = "feed";
      service = "web";
    };

    services.web = {
      enable = true;
      image = "freshrss/freshrss:1.29.1@sha256:ab6b363102ccdbc39f6a62db926f567c61a5289bf25ba460f1c34423d8cc1a4d";
      port = 80;

      helpers.timezone = true;

      environment = {
        CRON_MIN = "3,33";
      };

      volumes = [
        {
          type = "bind";
          source = "data";
          target = "/var/www/FreshRSS/data";
        }
        {
          type = "bind";
          source = "extensions";
          target = "/var/www/FreshRSS/extensions";
        }
      ];
    };
  };
}
