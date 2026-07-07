{
  homestation.homelab.apps.adguard-home = {
    expose = {
      mode = "private";
      host = "dns";
      service = "web";
    };

    services.web = {
      enable = true;
      image = "adguard/adguardhome:v0.107.77@sha256:e6f2b8bcda06064ab055b44933a4f0e983c35558b9cdb8d2e7ab1efcee36d890";
      port = 80;
      ports = [
        "53:53"
        "53:53/udp"
      ];
      volumes = [
        {
          type = "bind";
          source = "data";
          target = "/opt/adguardhome/work";
        }
        {
          type = "bind";
          source = "config";
          target = "/opt/adguardhome/conf";
        }
      ];
    };
  };
}
