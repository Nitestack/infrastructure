{
  homelab.apps.freshrss = {
    expose = {
      mode = "public";
      host = "feed";
    };

    services.web = {
      enable = true;
      image = "freshrss/freshrss:1.30.4@sha256:af44385229541bee24aa9148d0ff8f3b40e095373c63a2c0f74e09a27d3c59df";
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
