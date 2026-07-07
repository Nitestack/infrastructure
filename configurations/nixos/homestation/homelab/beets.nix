{
  config,
  ...
}:
let
  username = config.meta.username;
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

  homestation.homelab.apps.beets.services.main = {
    enable = true;
    image = "linuxserver/beets:2.12.0@sha256:9d7953d6afc7469e6314c25d9952374338de792171857dc5ff6dc482d488c658";

    helpers.linuxserver = true;

    volumes = [
      {
        type = "bind";
        source = "config";
        target = "/config";
        hostPath.user = username;
        hostPath.group = "users";
      }
      {
        type = "library";
        name = "music";
        target = "/music";
      }
      {
        type = "bind";
        source = "/mnt/data/rdtclient/downloads";
        target = "/downloads";
      }
      {
        type = "bind";
        source = renderedConfigPath;
        target = "/config/config.yaml";
        readOnly = true;
      }
      {
        type = "bind";
        source = "${./beets/classical.yaml}";
        target = "/config/classical.yaml";
        readOnly = true;
      }
    ];
  };
}
