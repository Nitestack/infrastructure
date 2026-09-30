{
  config,
  ...
}:
let
  username = config.meta.username;
in
{
  homelab.apps.calibre-web-automated = {
    expose = {
      mode = "public";
      host = "lib";
    };

    services.web = {
      enable = true;
      image = "crocodilestick/calibre-web-automated:v4.0.8@sha256:5e00373854247750cc3e4479b492ae09293ff5e06ed10177f226634d97888679";
      port = 8083;

      environment = {
        TRUSTED_PROXY_COUNT = "2";
      };

      environmentFiles = [ config.sops.templates."calibre-web-automated.env".path ];

      volumes = [
        {
          type = "bind";
          source = "config";
          target = "/config";
          owner = username;
          group = "users";
        }
        {
          type = "bind";
          source = "upload";
          target = "/cwa-book-ingest";
          owner = username;
          group = "users";
        }
        {
          type = "bind";
          source = "library";
          target = "/calibre-library";
          owner = username;
          group = "users";
        }
        {
          type = "bind";
          source = "plugins";
          target = "/config/.config/calibre/plugins";
          owner = username;
          group = "users";
        }
      ];
    };
  };
}
