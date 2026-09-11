{
  homelab.apps.freshrss = {
    expose = {
      mode = "public";
      host = "feed";
    };

    services.web = {
      enable = true;
      image = "freshrss/freshrss:1.30.0@sha256:258b8edfc8a76a61f60d2d6a14d8f8d12495d78abf38646a2137612dfa264a21";
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
