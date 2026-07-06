{
  config,
  ...
}:
{
  homestation.homelab.apps.navidrome.container = {
    enable = true;
    image = "deluan/navidrome:0.62.0@sha256:c4b5cb36a790b3eb63ca6a68bbe2fe149c2d7fa2e586f7a480e61db630e6664b";

    expose = {
      mode = "public";
      host = "music";
      port = 4533;
    };

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
        source = "data";
        target = "/data";
      }
      {
        library = "music";
        target = "/music";
        readOnly = true;
      }
    ];
  };
}
