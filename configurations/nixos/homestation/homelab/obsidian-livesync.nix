{ config, ... }:
{
  homelab.apps.obsidian-livesync = {
    expose = {
      mode = "public";
      host = "obsidian";
      targetService = "couchdb";
    };

    services.couchdb = {
      enable = true;
      image = "couchdb:3.5.2";
      containerName = "obsidian-livesync";
      port = 5984;

      runtime.user = "5984:5984";

      environment = {
        COUCHDB_USER = "obsidian";
      };

      environmentFiles = [
        config.sops.templates."obsidian-livesync.env".path
      ];

      volumes = [
        {
          type = "bind";
          source = "data";
          target = "/opt/couchdb/data";
          owner = "5984";
          group = "5984";
          mode = "0750";
        }
        {
          type = "bind";
          source = "etc";
          target = "/opt/couchdb/etc/local.d";
          owner = "5984";
          group = "5984";
          mode = "0750";
        }
      ];
    };
  };
}
