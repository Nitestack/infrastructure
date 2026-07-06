{
  homestation.homelab.apps.adguard-home.container = {
    enable = true;
    image = "adguard/adguardhome:v0.107.77@sha256:e6f2b8bcda06064ab055b44933a4f0e983c35558b9cdb8d2e7ab1efcee36d890";

    expose = {
      mode = "private";
      host = "dns";
      port = 80;
    };

    listeners = [
      {
        containerPort = 53;
        hostPort = 53;
      }
      {
        protocol = "udp";
        containerPort = 53;
        hostPort = 53;
      }
    ];

    volumes = [
      {
        source = "data";
        target = "/opt/adguardhome/work";
      }
      {
        source = "config";
        target = "/opt/adguardhome/conf";
      }
    ];

  };
}
