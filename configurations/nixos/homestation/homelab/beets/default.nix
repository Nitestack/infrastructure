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
    image = "linuxserver/beets:2.14.1@sha256:acef8a6ea96a0e2a391504aaae361f27fe77eac8e448cf14b675b3b64c50465a";

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
