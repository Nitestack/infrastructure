{
  homelab.apps.freshrss = {
    expose = {
      mode = "public";
      host = "feed";
    };

    services.web = {
      enable = true;
      image = "freshrss/freshrss:1.30.1@sha256:48b63b9bc3d042a1301c32971b01af8841c7f059b452589c5bf77f475ba44c61";
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
