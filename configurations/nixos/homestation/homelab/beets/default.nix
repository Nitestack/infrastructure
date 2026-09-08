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
    image = "linuxserver/beets:2.13.1@sha256:152308f033bf16fefb6c339c3313fb29b8a9ac2efe694c0390cbcba339b93670";

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
