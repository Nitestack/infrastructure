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
      image = "deluan/navidrome:0.62.0@sha256:c4b5cb36a790b3eb63ca6a68bbe2fe149c2d7fa2e586f7a480e61db630e6664b";
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
