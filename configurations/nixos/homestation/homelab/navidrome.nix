{
  config,
  pkgs,
  ...
}:
let
  username = config.meta.username;
  userUid = config.users.users.${username}.uid;
  userGid = config.ids.gids.users;
  effectiveUid = if userUid != null then toString userUid else "1000";

  audiomusePlugin = pkgs.fetchurl {
    url = "https://github.com/NeptuneHub/AudioMuse-AI-NV-plugin/releases/latest/download/audiomuseai.ndp";
    hash = "sha256-wTjprxbwl9jNB6yVf7iknZGn2gZuW0oUV8rb1HmqEKc=";
  };
  navidromePlugins = pkgs.runCommand "navidrome-plugins" { } ''
    mkdir -p "$out"
    install -m 0444 \
      ${audiomusePlugin} \
      "$out/audiomuseai.ndp"
  '';
in
{
  homelab.apps.navidrome = {
    expose = {
      mode = "public";
      host = "music";
    };

    services.web = {
      enable = true;
      image = "deluan/navidrome:0.64.0@sha256:a384948b81bd1529986c5960169e7fc4fa00f46bde6bd517971a4c36671db2af";
      port = 4533;
      runtime.user = "${effectiveUid}:${toString userGid}";

      environment = {
        ND_DEEZER_LANGUAGE = "en,de";
        ND_LASTFM_LANGUAGE = "en,de";
        ND_ENABLEINSIGHTSCOLLECTOR = "false";
        ND_SCANNER_PURGEMISSING = "always";
        ND_MUSICFOLDER = "/music/mainstream";
        ND_DEFAULTTHEME = "Spotify-ish";
        ND_ENABLESHARING = "true";
        ND_ENABLESTARRATING = "false";
        ND_PLUGINS_ENABLED = "true";
        ND_AGENTS = "audiomuseai,deezer,lastfm,listenbrainz";
      };

      environmentFiles = [ config.sops.templates."navidrome.env".path ];

      volumes = [
        {
          type = "bind";
          source = "data";
          target = "/data";
          owner = username;
          group = "users";
        }
        {
          type = "library";
          library = "music";
          target = "/music";
          readOnly = true;
        }
        {
          type = "bind";
          source = "${navidromePlugins}";
          target = "/data/plugins";
          readOnly = true;
        }
      ];
    };
  };
}
