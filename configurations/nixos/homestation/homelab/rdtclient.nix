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
      image = "rogerfar/rdtclient:2.0.143@sha256:68523637d09ec8a120bd272756d58b393448a656b5967bd45622c4891c65ff36";
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
