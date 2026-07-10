{
  ...
}:
{
  homelab.apps.rdtclient = {
    expose = {
      mode = "public";
      host = "magnets";
    };

    services.web = {
      enable = true;
      image = "rogerfar/rdtclient:2.0.140@sha256:3f5f37783da704d50bcc6773ffa22eaed86fd4bfbd225a7929e181c6774ead29";
      port = 6500;

      helpers.userIds = true;
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
