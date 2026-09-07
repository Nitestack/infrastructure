{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) escapeShellArg hasPrefix;
  dataDir = config.homelab.dataDir;
  musicLibrary = config.homelab.libraries.music.path;
  localResticRepository = "/mnt/backup/restic/homestation";
  nextcloudAioBackupDirectory = "/mnt/backup/nextcloud-borg";
  nextcloudAioRepository = "${nextcloudAioBackupDirectory}/borg";
  oneDriveRemote = "onedrive";
  oneDriveResticPath = "homestation/restic";
  oneDriveAioPath = "homestation/nextcloud-aio-borg";
  oneDriveResticRepository = "rclone:${oneDriveRemote}:${oneDriveResticPath}";
  oneDriveResticRclonePath = "${oneDriveRemote}:${oneDriveResticPath}";
  oneDriveAioRclonePath = "${oneDriveRemote}:${oneDriveAioPath}";
  oneDriveRcloneConfig = config.sops.secrets."backup/onedrive-rclone-config".path;
  offsiteResticPassword = config.sops.secrets."backup/offsite-restic-password".path;
  localResticRetention = {
    daily = 7;
    weekly = 4;
    monthly = 12;
  };
  offsiteResticRetention = localResticRetention;
  offsiteRetentionReviewed = false;
  offsiteResticPrune = true;
  offsiteRetentionValidated =
    offsiteResticRetention == localResticRetention || offsiteRetentionReviewed;
  nextcloudAioBackupScript = pkgs.writeShellApplication {
    name = "nextcloud-aio-backup";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.docker
    ];
    text = ''
      aio_master_container=nextcloud-aio-mastercontainer
      aio_borg_container=nextcloud-aio-borgbackup
      aio_repository=${escapeShellArg nextcloudAioRepository}

      die() {
        printf 'Nextcloud AIO backup: %s\n' "$*" >&2
        exit 1
      }

      # AIO's trigger does not propagate the Borg exit status. The child
      # container's start transition and final status are the result boundary.
      wait_for_aio_borg() {
        local previous_id="$1"
        local previous_started_at="$2"
        local operation="$3"
        local current_id=""
        local current_started_at=""
        local state=""
        local exit_code=""
        local attempt

        for ((attempt = 0; attempt < 60; attempt++)); do
          current_id="$(docker inspect --format '{{.Id}}' "$aio_borg_container" 2>/dev/null || true)"
          current_started_at="$(docker inspect --format '{{.State.StartedAt}}' "$aio_borg_container" 2>/dev/null || true)"
          if [[
            -n "$current_id"
            && (
              "$current_id" != "$previous_id"
              || "$current_started_at" != "$previous_started_at"
            )
          ]]; then
            break
          fi
          sleep 5
        done
        if [[
          -z "$current_id"
          || (
            "$current_id" == "$previous_id"
            && "$current_started_at" == "$previous_started_at"
          )
        ]]; then
          die "AIO $operation did not start a Borg operation"
        fi

        while :; do
          state="$(docker inspect --format '{{.State.Status}}' "$aio_borg_container" 2>/dev/null || true)"
          case "$state" in
            exited)
              exit_code="$(docker inspect --format '{{.State.ExitCode}}' "$aio_borg_container")"
              if [[ "$exit_code" != "0" ]]; then
                die "AIO $operation failed (Borg container exit code $exit_code)"
              fi
              return 0
              ;;
            created|running|restarting)
              sleep 30
              ;;
            *)
              die "AIO $operation ended in unexpected Borg container state: $state"
              ;;
          esac
        done
      }

      run_aio_operation() {
        local operation="$1"
        local previous_id
        local previous_started_at
        local -a trigger_environment

        if ! docker inspect "$aio_master_container" >/dev/null 2>&1; then
          die "AIO mastercontainer $aio_master_container is missing"
        fi
        if [[ "$(docker inspect --format '{{.State.Running}}' "$aio_master_container")" != "true" ]]; then
          die "AIO mastercontainer $aio_master_container is not running"
        fi
        if docker exec "$aio_master_container" test -e /mnt/docker-aio-config/data/daily_backup_running >/dev/null 2>&1; then
          die "another AIO backup operation is already running"
        fi
        previous_id="$(docker inspect --format '{{.Id}}' "$aio_borg_container" 2>/dev/null || true)"
        previous_started_at="$(docker inspect --format '{{.State.StartedAt}}' "$aio_borg_container" 2>/dev/null || true)"

        if [[ "$operation" == "backup" ]]; then
          trigger_environment=(--env DAILY_BACKUP=1 --env START_CONTAINERS=1)
        else
          trigger_environment=(--env CHECK_BACKUP=1)
        fi
        if ! docker exec "''${trigger_environment[@]}" "$aio_master_container" /daily-backup.sh; then
          die "AIO $operation trigger failed"
        fi

        wait_for_aio_borg "$previous_id" "$previous_started_at" "$operation"
      }

      printf 'starting Nextcloud AIO native Borg backup\n' >&2
      run_aio_operation backup
      if [[ ! -f "$aio_repository/config" ]]; then
        die "AIO Borg repository was not created at $aio_repository"
      fi
      printf 'AIO Borg backup, retention, and compaction completed\n' >&2

      printf 'starting Nextcloud AIO Borg integrity check\n' >&2
      run_aio_operation check
      printf 'AIO Borg integrity check completed\n' >&2
    '';
  };
  offsiteBackupScript =
    assert oneDriveResticPath != "";
    assert oneDriveAioPath != "";
    assert oneDriveResticPath != oneDriveAioPath;
    assert !(hasPrefix "${oneDriveResticPath}/" oneDriveAioPath);
    assert !(hasPrefix "${oneDriveAioPath}/" oneDriveResticPath);
    assert offsiteResticRetention.daily > 0;
    assert offsiteResticRetention.weekly > 0;
    assert offsiteResticRetention.monthly > 0;
    assert !offsiteResticPrune || offsiteRetentionValidated;
    pkgs.writeShellApplication {
      name = "offsite-backup";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.rclone
        pkgs.restic
      ];
      text = ''
        local_repository=${escapeShellArg localResticRepository}
        local_password_file=${escapeShellArg config.sops.secrets."backup/restic-password".path}
        remote_repository=${escapeShellArg oneDriveResticRepository}
        remote_restic_path=${escapeShellArg oneDriveResticRclonePath}
        remote_aio_path=${escapeShellArg oneDriveAioRclonePath}
        rclone_config=${escapeShellArg oneDriveRcloneConfig}
        remote_password_file=${escapeShellArg offsiteResticPassword}
        aio_repository=${escapeShellArg nextcloudAioRepository}
        remote_name=${escapeShellArg oneDriveRemote}
        tag=${escapeShellArg "local-application"}

        die() {
          printf 'offsite backup: %s\n' "$*" >&2
          exit 1
        }

        for required_file in \
          "$local_password_file" \
          "$remote_password_file" \
          "$rclone_config"; do
          if [[ ! -r "$required_file" ]]; then
            die "required offsite secret is unavailable: $required_file"
          fi
        done
        if [[ ! -f "$aio_repository/config" ]]; then
          die "AIO Borg repository is unavailable at $aio_repository"
        fi

        export RCLONE_CONFIG="$rclone_config"
        if ! rclone --config "$rclone_config" lsd "$remote_name:" >/dev/null; then
          die "OneDrive rclone remote $remote_name is unavailable"
        fi
        if ! restic --repo "$local_repository" --password-file "$local_password_file" cat config >/dev/null 2>&1; then
          die "local Restic repository is unavailable at $local_repository"
        fi

        if restic --repo "$remote_repository" --password-file "$remote_password_file" cat config >/dev/null 2>&1; then
          printf 'offsite backup: remote Restic repository is initialized\n' >&2
        else
          printf 'offsite backup: initializing independent remote Restic repository\n' >&2
          if ! restic --repo "$remote_repository" --password-file "$remote_password_file" init; then
            die "could not initialize the remote Restic repository"
          fi
        fi

        printf 'offsite backup: copying generic Restic snapshots\n' >&2
        if ! restic \
          --repo "$remote_repository" \
          --password-file "$remote_password_file" \
          --from-repo "$local_repository" \
          --from-password-file "$local_password_file" \
          copy; then
          die "generic Restic repository replication failed"
        fi

        printf 'offsite backup: OneDrive Restic size report\n' >&2
        if ! rclone --config "$rclone_config" size --human-readable "$remote_restic_path"; then
          die "remote Restic size report failed"
        fi

        printf 'offsite backup: remote Restic retention report\n' >&2
        if ! restic --repo "$remote_repository" --password-file "$remote_password_file" forget \
          --tag "$tag" \
          --keep-daily ${toString offsiteResticRetention.daily} \
          --keep-weekly ${toString offsiteResticRetention.weekly} \
          --keep-monthly ${toString offsiteResticRetention.monthly} \
          --dry-run; then
          die "remote Restic retention report failed"
        fi

        ${
          if offsiteResticPrune then
            ''
              printf 'offsite backup: pruning remote Restic snapshots after validated retention policy\n' >&2
              if ! restic --repo "$remote_repository" --password-file "$remote_password_file" forget \
                --tag "$tag" \
                --keep-daily ${toString offsiteResticRetention.daily} \
                --keep-weekly ${toString offsiteResticRetention.weekly} \
                --keep-monthly ${toString offsiteResticRetention.monthly} \
                --prune; then
                die "remote Restic retention and pruning failed"
              fi
            ''
          else
            ''
              printf 'offsite backup: remote Restic pruning is disabled until the first size report is reviewed\n' >&2
            ''
        }

        printf 'offsite backup: syncing completed AIO Borg repository\n' >&2
        if ! rclone --config "$rclone_config" sync "$aio_repository" "$remote_aio_path"; then
          die "AIO Borg repository replication failed"
        fi
        if ! rclone --config "$rclone_config" lsf "$remote_aio_path/config" >/dev/null; then
          die "remote AIO Borg repository is missing its config after sync"
        fi
        printf 'offsite backup: completed Restic and AIO Borg replication\n' >&2
      '';
    };
in
{
  services.localBackup = {
    enable = true;
    requiredMount = "/mnt/backup";
    repository = localResticRepository;
    stagingDirectory = "/mnt/backup/.local-backup-staging";
    passwordFile = config.sops.secrets."backup/restic-password".path;
    requiresSops = true;

    timer = {
      onCalendar = "*-*-* 03:30:00";
      randomizedDelaySec = "30m";
    };

    retention = {
      inherit (localResticRetention) daily weekly monthly;
    };

    managedRepositories = [ nextcloudAioRepository ];
    preResticScript = nextcloudAioBackupScript;
    postResticScript = offsiteBackupScript;

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
