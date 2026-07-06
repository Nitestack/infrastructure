{
  config,
  ...
}:
let
  username = config.meta.username;
  userUid = config.users.users.${username}.uid;
  userGid = config.ids.gids.users;
  renderedConfigName = "beets-config.yaml";
  renderedConfigPath = config.sops.templates.${renderedConfigName}.path;
in
{
  homestation.renderedFiles.${renderedConfigName} = {
    source = ./beets/config.yaml;
    replacements = {
      "@LASTFM_KEY@" = config.sops.placeholder."beets/lastfm-key";
    };
  };

  homestation.homelab.apps.beets.container = {
    enable = true;
    image = "linuxserver/beets:2.12.0@sha256:9d7953d6afc7469e6314c25d9952374338de792171857dc5ff6dc482d488c658";

    environment = {
      PUID = if userUid != null then toString userUid else "1000";
      PGID = toString userGid;
      TZ = config.time.timeZone;
    };

    volumes = [
      {
        source = "config";
        target = "/config";
        hostPath.user = username;
        hostPath.group = "users";
      }
      {
        library = "music";
        target = "/music";
      }
      {
        source = "/mnt/data/rdtclient/downloads";
        target = "/downloads";
      }
      {
        source = renderedConfigPath;
        target = "/config/config.yaml";
        readOnly = true;
      }
      {
        source = "${./beets/classical.yaml}";
        target = "/config/classical.yaml";
        readOnly = true;
      }
    ];
  };
}
