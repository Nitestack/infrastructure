{
  config,
  ...
}:
{
  homestation.homelab.apps.freshrss.container = {
    enable = true;
    image = "freshrss/freshrss:1.29.1@sha256:ab6b363102ccdbc39f6a62db926f567c61a5289bf25ba460f1c34423d8cc1a4d";

    expose = {
      mode = "public";
      host = "feed";
      port = 80;
    };

    environment = {
      TZ = config.time.timeZone;
      CRON_MIN = "3,33";
    };

    volumes = [
      {
        source = "data";
        target = "/var/www/FreshRSS/data";
      }
      {
        source = "extensions";
        target = "/var/www/FreshRSS/extensions";
      }
    ];
  };
}
