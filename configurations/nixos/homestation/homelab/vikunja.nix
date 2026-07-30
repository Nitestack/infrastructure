{
  config,
  ...
}:
let
  cfg = config.homelab;
  username = config.meta.username;
  inherit (cfg.lib) appUrl;
in
{
  homelab.apps.vikunja = {
    expose = {
      mode = "public";
      host = "tasks";
    };

    services.web = {
      enable = true;
      image = "vikunja/vikunja:2.4.0";
      port = 3456;

      environment = {
        VIKUNJA_SERVICE_PUBLICURL = appUrl cfg.apps.vikunja;
        VIKUNJA_SERVICE_ENABLEREGISTRATION = "false";
        VIKUNJA_DATABASE_PATH = "/db/vikunja.db";
        VIKUNJA_MAILER_ENABLED = "true";
      }
      // cfg.lib.smtpEnv {
        hostVar = "VIKUNJA_MAILER_HOST";
        portVar = "VIKUNJA_MAILER_PORT";
        usernameVar = "VIKUNJA_MAILER_USERNAME";
        fromVar = "VIKUNJA_MAILER_FROMEMAIL";
      };

      environmentFiles = [ config.sops.templates."vikunja.env".path ];

      volumes = [
        {
          type = "bind";
          source = "files";
          target = "/app/vikunja/files";
          owner = username;
          group = "users";
        }
        {
          type = "bind";
          source = "db";
          target = "/db";
          owner = username;
          group = "users";
        }
      ];
    };
  };
}
