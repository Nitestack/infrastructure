{
  config,
  ...
}:
let
  dataDir = config.homelab.dataDir;
  musicLibrary = config.homelab.libraries.music.path;
in
{
  services.localBackup = {
    enable = true;
    requiredMount = "/mnt/backup";
    repository = "/mnt/backup/restic/homestation";
    stagingDirectory = "/mnt/backup/.local-backup-staging";
    passwordFile = config.sops.secrets."backup/restic-password".path;
    requiresSops = true;

    timer = {
      onCalendar = "*-*-* 03:30:00";
      randomizedDelaySec = "30m";
    };

    retention = {
      daily = 7;
      weekly = 4;
      monthly = 12;
    };

    managedRepositories = [
      "/mnt/backup/nextcloud-borg"
    ];

    sources = [
      {
        label = "Caddy data";
        path = "${dataDir}/caddy/data";
        purpose = "ACME certificates and Caddy runtime state";
        stoppedService = "docker-caddy.service";
      }
      {
        label = "Caddy configuration state";
        path = "${dataDir}/caddy/config";
        purpose = "Caddy configuration state";
        stoppedService = "docker-caddy.service";
      }
      {
        label = "AdventureLog media and attachments";
        path = "${dataDir}/adventure-log/data";
        purpose = "user-uploaded travel media";
      }
      {
        label = "Immich library";
        path = "${dataDir}/immich/library";
        purpose = "complete Immich application data and media";
      }
      {
        label = "Music library";
        path = musicLibrary;
        purpose = "shared source for Navidrome and Beets";
        shared = true;
      }
      {
        label = "Calibre books library";
        path = "${dataDir}/calibre-web-automated/library";
        purpose = "shared book library for Calibre-Web Automated and Shelfmark";
        shared = true;
      }
      {
        label = "Calibre book ingest uploads";
        path = "${dataDir}/calibre-web-automated/upload";
        purpose = "pending book uploads";
        shared = true;
      }
      {
        label = "Completed downloads";
        path = "${dataDir}/rdtclient/downloads";
        purpose = "shared download source for RdtClient, Beets, and Shelfmark";
        shared = true;
      }
      {
        label = "Calibre-Web Automated configuration";
        path = "${dataDir}/calibre-web-automated/config";
        purpose = "application configuration, plugins, and SQLite metadata";
        stoppedService = "arion-calibre-web-automated.service";
      }
      {
        label = "Calibre-Web Automated plugins";
        path = "${dataDir}/calibre-web-automated/plugins";
        purpose = "installed Calibre-Web Automated plugins";
        stoppedService = "arion-calibre-web-automated.service";
      }
      {
        label = "Beets configuration";
        path = "${dataDir}/beets/config";
        purpose = "music-management configuration and library database";
        stoppedService = "arion-beets.service";
      }
      {
        label = "FreshRSS data";
        path = "${dataDir}/freshrss/data";
        purpose = "feed subscriptions, application state, and SQLite data";
        stoppedService = "arion-freshrss.service";
      }
      {
        label = "FreshRSS extensions";
        path = "${dataDir}/freshrss/extensions";
        purpose = "installed FreshRSS extensions";
        stoppedService = "arion-freshrss.service";
      }
      {
        label = "Navidrome data";
        path = "${dataDir}/navidrome/data";
        purpose = "application state and SQLite database";
        stoppedService = "arion-navidrome.service";
      }
      {
        label = "Pocket ID data";
        path = "${dataDir}/pocket-id/data";
        purpose = "identity-provider state and SQLite database";
        stoppedService = "arion-pocket-id.service";
      }
      {
        label = "Prowlarr data";
        path = "${dataDir}/prowlarr/data";
        purpose = "indexer configuration and SQLite database";
        stoppedService = "arion-prowlarr.service";
      }
      {
        label = "RdtClient database";
        path = "${dataDir}/rdtclient/db";
        purpose = "download-client state";
        stoppedService = "arion-rdtclient.service";
      }
      {
        label = "Shelfmark configuration";
        path = "${dataDir}/shelfmark/config";
        purpose = "book-workflow configuration and state";
        stoppedService = "arion-shelfmark.service";
      }
      {
        label = "Vaultwarden data";
        path = "${dataDir}/vaultwarden/data";
        purpose = "password-manager data and SQLite database";
        stoppedService = "arion-vaultwarden.service";
      }
      {
        label = "Vikunja files";
        path = "${dataDir}/vikunja/files";
        purpose = "task attachments";
      }
      {
        label = "Vikunja database";
        path = "${dataDir}/vikunja/db";
        purpose = "task state and SQLite database";
        stoppedService = "arion-vikunja.service";
      }
      {
        label = "Wealthfolio data";
        path = "${dataDir}/wealthfolio/data";
        purpose = "portfolio state and SQLite database";
        stoppedService = "arion-wealthfolio.service";
      }
      {
        label = "Yamtrack database";
        path = "${dataDir}/yamtrack/db";
        purpose = "media-tracking SQLite database";
        stoppedService = "arion-yamtrack.service";
      }
    ];

    postgresDumps = [
      {
        label = "AdventureLog PostgreSQL";
        container = "adventurelog-db";
        database = "database";
        user = "adventure";
        passwordFile = config.sops.secrets."adventure-log/db-password".path;
        outputName = "postgres/adventure-log.sql.gz";
      }
      {
        label = "AudioMuse PostgreSQL";
        container = "audiomuse-postgres";
        database = "audiomusedb";
        user = "audiomuse";
        passwordFile = config.sops.secrets."audiomuse-ai/db-password".path;
        outputName = "postgres/audiomuse.sql.gz";
      }
      {
        label = "Ente PostgreSQL";
        container = "ente-postgres";
        database = "ente_db";
        user = "pguser";
        passwordFile = config.sops.secrets."ente/db-password".path;
        outputName = "postgres/ente.sql.gz";
      }
      {
        label = "Immich PostgreSQL";
        container = "immich_postgres";
        database = "immich";
        user = "postgres";
        passwordFile = config.sops.secrets."immich/db-password".path;
        outputName = "postgres/immich.sql.gz";
      }
    ];

    runtimeVolumes = [
      {
        label = "AudioMuse Flask plugins";
        volume = "audiomuse-ai_plugins-flask";
        destination = "audiomuse/plugins-flask";
        stoppedService = "arion-audiomuse-ai.service";
      }
      {
        label = "AudioMuse worker plugins";
        volume = "audiomuse-ai_plugins-worker";
        destination = "audiomuse/plugins-worker";
        stoppedService = "arion-audiomuse-ai.service";
      }
    ];

    exclusions = [
      {
        label = "PostgreSQL data directories";
        reason = "the four PostgreSQL databases are represented by logical dumps instead of live directory copies";
      }
      {
        label = "Rebuildable images and generated Compose state";
        reason = "images and Arion output are reproducible from this repository";
      }
      {
        label = "Logs";
        reason = "journald and container logs are operational noise, not application state";
      }
      {
        label = "Redis, temporary audio, and model caches";
        reason = "caches are rebuildable and would duplicate transient data";
      }
      {
        label = "Beszel state";
        reason = "monitoring history is deliberately outside this application-data backup";
      }
      {
        label = "AdGuard Home state";
        reason = "settings and filters are declarative in Nix";
      }
      {
        label = "Nextcloud AIO";
        reason = "Nextcloud remains covered by its separate native Borg backup";
      }
      {
        label = "Obsidian LiveSync";
        reason = "explicit coverage gap; its CouchDB state is not included here";
      }
      {
        label = "Services without persistent local data";
        reason = "Glance, IT-Tools, and helper containers have no declared application-data source";
      }
    ];
  };
}
