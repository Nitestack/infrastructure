{
  config,
  ...
}:
let
  cfg = config.homelab;
  smtp = cfg.smtp;
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
        VIKUNJA_DATABASE_PATH = "/db/vikunja.db";
        VIKUNJA_MAILER_ENABLED = "true";
        VIKUNJA_MAILER_HOST = smtp.host;
        VIKUNJA_MAILER_PORT = toString smtp.port;
        VIKUNJA_MAILER_USERNAME = smtp.username;
        VIKUNJA_MAILER_FROMEMAIL = smtp.from;
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
