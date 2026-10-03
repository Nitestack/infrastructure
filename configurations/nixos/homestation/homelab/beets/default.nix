{
  config,
  ...
}:
let
  cfg = config.homelab;
  username = config.meta.username;
  renderedConfigName = "beets-config.yaml";
  renderedConfigPath = config.sops.templates.${renderedConfigName}.path;
in
{
  homestation.renderedFiles.${renderedConfigName} = {
    source = ./config.yaml;
    replacements = {
      "@LASTFM_KEY@" = config.sops.placeholder."beets/lastfm-key";
    };
    owner = username;
    group = "users";
  };

  homelab.apps.beets.services.main = {
    enable = true;
    image = "linuxserver/beets:2.14.1@sha256:e5a4b1292c58bf67fc941002dff363254426e846af7fa9d875789310c0a2c5ce";

    volumes = [
      {
        type = "bind";
        source = "config";
        target = "/config";
        owner = username;
        group = "users";
      }
      {
        type = "library";
        library = "music";
        target = "/music";
      }
      {
        type = "bind";
        source = "${cfg.dataDir}/rdtclient/downloads";
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
        source = "${./classical.yaml}";
        target = "/config/classical.yaml";
        readOnly = true;
      }
    ];
  };
}
