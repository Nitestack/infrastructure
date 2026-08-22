{
  config,
  ...
}:
let
  cfg = config.homelab;
  inherit (cfg.lib) appUrl;

  domain = cfg.domain;
  mkUrl = host: "https://${host}.${domain}";
  adguardHomeUrl = "https://dns.${domain}";
in
{
  homelab.apps.glance = {
    expose = {
      mode = "public";
      host = "dash";
    };

    services.web = {
      enable = true;
      image = "glanceapp/glance:v0.8.5@sha256:32ab73d80f2b8b5fb0735b0431deb36b93fbb6b2fb43592449b0178c8b83e350";
      port = 8080;

      environment = {
        AUDIOMUSE_AI_URL = appUrl cfg.apps.audiomuse-ai;
        ADGUARD_HOME_URL = adguardHomeUrl;
        ADVENTURE_LOG_URL = appUrl cfg.apps.adventure-log;
        BESZEL_URL = appUrl cfg.apps.beszel;
        CALIBRE_WEB_AUTOMATED_URL = appUrl cfg.apps.calibre-web-automated;
        ENTE_AUTH_URL = appUrl cfg.apps.ente;
        FRESHRSS_URL = appUrl cfg.apps.freshrss;
        GLANCE_URL = appUrl cfg.apps.glance;
        # IMMICH_URL = appUrl cfg.apps.immich;
        IMMICH_URL = "https://media.npham.de";
        IT_TOOLS_URL = appUrl cfg.apps.it-tools;
        NAVIDROME_URL = appUrl cfg.apps.navidrome;
        # NEXTCLOUD_URL = appUrl cfg.apps.nextcloud;
        NEXTCLOUD_URL = "https://cloud.npham.de";
        POCKET_ID_URL = appUrl cfg.apps.pocket-id;
        PROWLARR_URL = appUrl cfg.apps.prowlarr;
        RDTCLIENT_URL = appUrl cfg.apps.rdtclient;
        SHELFMARK_URL = appUrl cfg.apps.shelfmark;
        VAULTWARDEN_URL = appUrl cfg.apps.vaultwarden;
        WEALTHFOLIO_URL = appUrl cfg.apps.wealthfolio;
        YAMTRACK_URL = appUrl cfg.apps.yamtrack;
        # No backing homelab.apps entry exists for this service; keep the manual host.
        ZEROBYTE_URL = mkUrl "backup";
      };

      volumes = [
        {
          type = "bind";
          source = "${./.}";
          target = "/app/config";
          readOnly = true;
        }
        {
          type = "bind";
          source = "/var/run/docker.sock";
          target = "/var/run/docker.sock";
          readOnly = true;
        }
        {
          type = "bind";
          source = config.sops.templates."glance-user".path;
          target = "/run/secrets/glance_user";
          readOnly = true;
        }
        {
          type = "bind";
          source = config.sops.templates."glance-password-hash".path;
          target = "/run/secrets/glance_password_hash";
          readOnly = true;
        }
        {
          type = "bind";
          source = config.sops.templates."glance-secret".path;
          target = "/run/secrets/glance_secret";
          readOnly = true;
        }
        {
          type = "bind";
          source = config.sops.templates."glance-github-api-token".path;
          target = "/run/secrets/glance_github_api_token";
          readOnly = true;
        }
      ];
    };
  };
}
