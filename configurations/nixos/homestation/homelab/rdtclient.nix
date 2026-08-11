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
      image = "rogerfar/rdtclient:2.0.142@sha256:647db1c0040b1b28bb0e874fd2b58e315c52004c0c27d24e0e0b9be7f6d92469";
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
