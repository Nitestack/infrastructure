{
  config,
  ...
}:
let
  username = config.meta.username;
  userUid = config.users.users.${username}.uid;
  userGid = config.ids.gids.users;
in
{
  homestation.homelab.apps.calibre-web-automated = {
    expose = {
      mode = "public";
      host = "lib";
      service = "web";
    };

    services.web = {
      enable = true;
      image = "crocodilestick/calibre-web-automated:v4.0.6@sha256:c31a738b6d5ec6982c050063dd3f063b6943eb1051fc81144789f840d9093a8d";
      port = 8083;

      environment = {
        PUID = if userUid != null then toString userUid else "1000";
        PGID = toString userGid;
        TZ = config.time.timeZone;
        TRUSTED_PROXY_COUNT = "2";
      };

      environmentFiles = [ config.sops.templates."calibre-web-automated.env".path ];

      volumes = [
        {
          type = "bind";
          source = "config";
          target = "/config";
          hostPath.user = username;
          hostPath.group = "users";
        }
        {
          type = "bind";
          source = "upload";
          target = "/cwa-book-ingest";
          hostPath.user = username;
          hostPath.group = "users";
        }
        {
          type = "bind";
          source = "library";
          target = "/calibre-library";
          hostPath.user = username;
          hostPath.group = "users";
        }
        {
          type = "bind";
          source = "plugins";
          target = "/config/.config/calibre/plugins";
          hostPath.user = username;
          hostPath.group = "users";
        }
      ];
    };
  };
}
