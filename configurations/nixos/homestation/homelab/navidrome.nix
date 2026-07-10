{
  config,
  ...
}:
let
  username = config.meta.username;
  userUid = config.users.users.${username}.uid;
  userGid = config.ids.gids.users;
  effectiveUid = if userUid != null then toString userUid else "1000";
in
{
  homelab.apps.navidrome = {
    expose = {
      mode = "public";
      host = "music";
    };

    services.web = {
      enable = true;
      image = "deluan/navidrome:0.63.1@sha256:7c43af9f651654e97278be871705aae85a4ee0fa4b310337989699a8ada9b3ed";
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
      };

      environmentFiles = [ config.sops.templates."navidrome.env".path ];

      volumes = [
        {
          type = "bind";
          source = "data";
          target = "/data";
        }
        {
          type = "library";
          library = "music";
          target = "/music";
          readOnly = true;
        }
      ];
    };
  };
}
