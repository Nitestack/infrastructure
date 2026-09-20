{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatMapStringsSep
    escapeShellArg
    optionals
    unique
    ;

  dataDir = config.homelab.dataDir;
  musicLibrary = config.homelab.libraries.music.path;

  localResticRepository = "/mnt/backup/restic/homestation";
  nextcloudAioBackupDirectory = "/mnt/backup/nextcloud-borg";
  nextcloudAioRepository = "${nextcloudAioBackupDirectory}/borg";

  oneDriveRemote = "onedrive";
  oneDriveResticPath = "homestation/restic";
  oneDriveAioPath = "homestation/nextcloud-aio-borg";
  oneDriveResticRepository = "rclone:${oneDriveRemote}:${oneDriveResticPath}";
  oneDriveAioRepository = "${oneDriveRemote}:${oneDriveAioPath}";

  localResticPassword = config.sops.secrets."backup/restic-password".path;
  offsiteResticPassword = config.sops.secrets."backup/offsite-restic-password".path;
  oneDriveRcloneConfig = config.sops.secrets."backup/onedrive-rclone-config".path;

  localBackupRuntimeDirectory = "/run/restic-backups-local";
  localBackupStagingDirectory = "/mnt/backup/.local-backup-staging";
  stoppedServicesFile = "${localBackupRuntimeDirectory}/stopped-services";
  aioPauseMarker = "${localBackupRuntimeDirectory}/aio-paused";
  aioOperationTimeoutSeconds = 8 * 60 * 60;

  retention = {
    daily = 7;
    weekly = 4;
    monthly = 12;
  };

  # Keep remote pruning disabled until the remote repository size and policy
  # have been reviewed. Native Restic still checks every copied repository.
  offsiteRetentionReviewed = false;
  offsiteResticPrune = false;

  directPaths = [
    "${dataDir}/adventure-log/data"
    "${dataDir}/immich/library"
    musicLibrary
    "${dataDir}/calibre-web-automated/library"
    "${dataDir}/calibre-web-automated/upload"
    "${dataDir}/rdtclient/downloads"
    "${dataDir}/vikunja/files"
  ];

  # Stage names are part of the snapshot format; keep them independent of list order.
  mutableSources = [
    {
      path = "${dataDir}/caddy/data";
      service = "docker-caddy.service";
      stageName = "caddy-data";
    }
    {
      path = "${dataDir}/caddy/config";
      service = "docker-caddy.service";
      stageName = "caddy-config";
    }
    {
      path = "${dataDir}/calibre-web-automated/config";
      service = "arion-calibre-web-automated.service";
      stageName = "calibre-web-automated-config";
    }
    {
      path = "${dataDir}/calibre-web-automated/plugins";
      service = "arion-calibre-web-automated.service";
      stageName = "calibre-web-automated-plugins";
    }
    {
      path = "${dataDir}/beets/config";
      service = "arion-beets.service";
      stageName = "beets-config";
    }
    {
      path = "${dataDir}/freshrss/data";
      service = "arion-freshrss.service";
      stageName = "freshrss-data";
    }
    {
      path = "${dataDir}/freshrss/extensions";
      service = "arion-freshrss.service";
      stageName = "freshrss-extensions";
    }
    {
      path = "${dataDir}/navidrome/data";
      service = "arion-navidrome.service";
      stageName = "navidrome-data";
    }
    {
      path = "${dataDir}/pocket-id/data";
      service = "arion-pocket-id.service";
      stageName = "pocket-id-data";
    }
    {
      path = "${dataDir}/prowlarr/data";
      service = "arion-prowlarr.service";
      stageName = "prowlarr-data";
    }
    {
      path = "${dataDir}/rdtclient/db";
      service = "arion-rdtclient.service";
      stageName = "rdtclient-db";
    }
    {
      path = "${dataDir}/shelfmark/config";
      service = "arion-shelfmark.service";
      stageName = "shelfmark-config";
    }
    {
      path = "${dataDir}/vaultwarden/data";
      service = "arion-vaultwarden.service";
      stageName = "vaultwarden-data";
    }
    {
      path = "${dataDir}/vikunja/db";
      service = "arion-vikunja.service";
      stageName = "vikunja-db";
    }
    {
      path = "${dataDir}/wealthfolio/data";
      service = "arion-wealthfolio.service";
      stageName = "wealthfolio-data";
    }
    {
      path = "${dataDir}/yamtrack/db";
      service = "arion-yamtrack.service";
      stageName = "yamtrack-db";
    }
  ];

  runtimeVolumes = [
    {
      volume = "audiomuse-ai_plugins-flask";
      destination = "audiomuse/plugins-flask";
      service = "arion-audiomuse-ai.service";
    }
    {
      volume = "audiomuse-ai_plugins-worker";
      destination = "audiomuse/plugins-worker";
      service = "arion-audiomuse-ai.service";
    }
  ];

  postgresDumps = [
    {
      container = "adventurelog-db";
      database = "database";
      passwordFile = config.sops.secrets."adventure-log/db-password".path;
      outputName = "postgres/adventure-log.sql.gz";
      user = "adventure";
    }
    {
      container = "audiomuse-postgres";
      database = "audiomusedb";
      passwordFile = config.sops.secrets."audiomuse-ai/db-password".path;
      outputName = "postgres/audiomuse.sql.gz";
      user = "audiomuse";
    }
    {
      container = "ente-postgres";
      database = "ente_db";
      passwordFile = config.sops.secrets."ente/db-password".path;
      outputName = "postgres/ente.sql.gz";
      user = "pguser";
    }
    {
      container = "immich_postgres";
      database = "immich";
      passwordFile = config.sops.secrets."immich/db-password".path;
      outputName = "postgres/immich.sql.gz";
      user = "postgres";
    }
  ];

  mutableServices = unique (
    map (source: source.service) mutableSources ++ map (volume: volume.service) runtimeVolumes
  );

  directPathChecks = concatMapStringsSep "\n" (
    path: "require_path ${escapeShellArg path}"
  ) directPaths;

  stopServiceCommands = concatMapStringsSep "\n" (
    service: "stop_service ${escapeShellArg service}"
  ) mutableServices;

  mutableSourceCommands = concatMapStringsSep "\n" (source: ''
    capture_path \
      ${escapeShellArg source.path} \
      "$stage_dir/sources/${source.stageName}"
  '') mutableSources;

  runtimeVolumeCommands = concatMapStringsSep "\n" (volume: ''
    capture_volume \
      ${escapeShellArg volume.volume} \
      ${escapeShellArg volume.destination}
  '') runtimeVolumes;

  postgresDumpCommands = concatMapStringsSep "\n" (dump: ''
    dump_postgres \
      ${escapeShellArg dump.container} \
      ${escapeShellArg dump.database} \
      ${escapeShellArg dump.user} \
      ${escapeShellArg dump.passwordFile} \
      "$stage_dir/${dump.outputName}"
  '') postgresDumps;

  prepareScript = pkgs.writeShellApplication {
    name = "homestation-backup-prepare";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.docker
      pkgs.gnugrep
      pkgs.gzip
      pkgs.systemd
      pkgs.util-linux
    ];
    text = ''
      stage_dir=${escapeShellArg localBackupStagingDirectory}
      stopped_services_file=${escapeShellArg stoppedServicesFile}
      aio_pause_marker=${escapeShellArg aioPauseMarker}
      aio_backup_directory=${escapeShellArg nextcloudAioBackupDirectory}
      aio_repository=${escapeShellArg nextcloudAioRepository}
      aio_operation_timeout=${toString aioOperationTimeoutSeconds}

      die() {
        printf 'homestation backup: %s\n' "$*" >&2
        exit 1
      }

      if ! mountpoint --quiet -- /mnt/backup; then
        die "backup filesystem is not mounted at /mnt/backup"
      fi
      if [[ ! -r ${escapeShellArg localResticPassword} ]]; then
        die "local Restic password file is unavailable"
      fi
      if [[ -e "$aio_pause_marker" ]]; then
        die "a previous backup run still owns the AIO pause marker"
      fi

      rm -rf -- "$stage_dir"
      install -d -m 0700 -- "$stage_dir" "$(dirname -- "$stopped_services_file")"
      : >"$stopped_services_file"

      require_path() {
        if [[ ! -e "$1" ]]; then
          die "backup source is missing: $1"
        fi
      }

      ${directPathChecks}

      dump_postgres() {
        local container="$1"
        local database="$2"
        local user="$3"
        local dump_password_file="$4"
        local output="$5"
        local temporary_output="''${output}.partial"
        local password
        local pgpass_password

        if ! docker inspect "$container" >/dev/null 2>&1; then
          die "PostgreSQL container $container is missing"
        fi
        if [[ "$(docker inspect --format '{{.State.Running}}' "$container")" != "true" ]]; then
          die "PostgreSQL container $container is not running"
        fi
        if [[ ! -r "$dump_password_file" ]]; then
          die "PostgreSQL password file is unavailable for $container"
        fi

        password="$(<"$dump_password_file")"
        pgpass_password=''${password//\\/\\\\}
        pgpass_password=''${pgpass_password//:/\\:}
        pgpass_password=''${pgpass_password//$'\n'/\\n}
        mkdir -p -- "$(dirname -- "$output")"
        rm -f -- "$temporary_output"
        if ! printf '*:*:*:*:%s\n' "$pgpass_password" | docker exec -i "$container" sh -c '
          umask 077
          password_file="$(mktemp)"
          cleanup_password_file() {
            rm -f -- "$password_file"
          }
          trap cleanup_password_file EXIT
          cat >"$password_file"
          PGPASSFILE="$password_file" pg_dump \
            --no-password \
            --clean \
            --if-exists \
            --no-owner \
            --no-privileges \
            --format=plain \
            --username="$1" \
            --dbname="$2"
        ' -- "$user" "$database" | gzip --stdout >"$temporary_output"; then
          rm -f -- "$temporary_output"
          die "PostgreSQL logical dump failed for $container"
        fi
        mv -- "$temporary_output" "$output"
      }

      ${postgresDumpCommands}

      stop_service() {
        local service="$1"

        if ! systemctl cat "$service" >/dev/null 2>&1; then
          die "required service unit is missing: $service"
        fi
        if systemctl is-active --quiet "$service"; then
          printf '%s\n' "$service" >>"$stopped_services_file"
          printf 'homestation backup: stopping %s\n' "$service" >&2
          systemctl stop "$service"
        fi
      }

      capture_path() {
        local source="$1"
        local destination="$2"

        require_path "$source"
        if [[ -d "$source" ]]; then
          install -d -m 0700 -- "$destination"
          cp -a -- "$source"/. "$destination"/
        else
          install -d -m 0700 -- "$(dirname -- "$destination")"
          cp -a -- "$source" "$destination"
        fi
      }

      capture_volume() {
        local volume="$1"
        local destination="$2"
        local mountpoint

        if ! mountpoint="$(docker volume inspect --format '{{.Mountpoint}}' "$volume" 2>/dev/null)"; then
          die "required Docker volume is missing: $volume"
        fi
        if [[ ! -d "$mountpoint" ]]; then
          die "Docker volume has no readable mountpoint: $volume"
        fi
        install -d -m 0700 -- "$stage_dir/runtime/$destination"
        cp -a -- "$mountpoint"/. "$stage_dir/runtime/$destination"/
      }

      ${stopServiceCommands}
      ${mutableSourceCommands}
      ${runtimeVolumeCommands}

      if [[ -s "$stopped_services_file" ]]; then
        while IFS= read -r service; do
          if ! systemctl start "$service"; then
            die "could not restart $service; cleanup will retry"
          fi
        done <"$stopped_services_file"
        : >"$stopped_services_file"
      fi

      aio_master_container=nextcloud-aio-mastercontainer
      aio_borg_container=nextcloud-aio-borgbackup

      wait_for_aio_borg() {
        local previous_id="$1"
        local previous_started_at="$2"
        local operation="$3"
        local deadline="$4"
        local current_id=""
        local current_started_at=""
        local state=""
        local exit_code=""

        while :; do
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
          if (( $(date +%s) >= deadline )); then
            die "AIO $operation did not start within $aio_operation_timeout seconds"
          fi
          sleep 5
        done

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
              if (( $(date +%s) >= deadline )); then
                die "AIO $operation did not finish within $aio_operation_timeout seconds"
              fi
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
        local deadline
        local -a trigger_environment

        # AIO's supported trigger does not make the Borg container's exit code
        # the trigger's exit code, and the check path is asynchronous. Treat
        # the child container transition and exit code as the result boundary.
        # See https://github.com/nextcloud/all-in-one/blob/main/Containers/mastercontainer/daily-backup.sh
        if ! docker inspect "$aio_master_container" >/dev/null 2>&1; then
          die "AIO mastercontainer is missing"
        fi
        if [[ "$(docker inspect --format '{{.State.Running}}' "$aio_master_container")" != "true" ]]; then
          die "AIO mastercontainer is not running"
        fi
        if docker exec "$aio_master_container" test -e /mnt/docker-aio-config/data/daily_backup_time >/dev/null 2>&1; then
          die "disable AIO's native daily schedule before using this timer"
        fi
        if docker exec "$aio_master_container" test -e /mnt/docker-aio-config/data/daily_backup_running >/dev/null 2>&1; then
          die "another AIO backup operation is already running"
        fi

        previous_id="$(docker inspect --format '{{.Id}}' "$aio_borg_container" 2>/dev/null || true)"
        previous_started_at="$(docker inspect --format '{{.State.StartedAt}}' "$aio_borg_container" 2>/dev/null || true)"
        deadline=$(($(date +%s) + aio_operation_timeout))
        if [[ "$operation" == "backup" ]]; then
          trigger_environment=(--env DAILY_BACKUP=1 --env START_CONTAINERS=1)
        else
          trigger_environment=(--env CHECK_BACKUP=1)
        fi

        if ! timeout --foreground --kill-after=1m "$aio_operation_timeout" \
          docker exec "''${trigger_environment[@]}" "$aio_master_container" /daily-backup.sh; then
          die "AIO $operation trigger failed or exceeded $aio_operation_timeout seconds"
        fi
        wait_for_aio_borg "$previous_id" "$previous_started_at" "$operation" "$deadline"
      }

      run_aio_operation backup
      run_aio_operation check

      if [[ -e "$aio_pause_marker" ]]; then
        die "AIO pause marker already exists"
      fi
      : >"$aio_pause_marker"
      if ! docker pause "$aio_master_container" >/dev/null; then
        rm -f -- "$aio_pause_marker"
        die "could not pause AIO before repository replication"
      fi

      if [[ "$(docker inspect --format '{{.State.Paused}}' "$aio_master_container")" != "true" ]]; then
        die "AIO mastercontainer did not remain paused"
      fi
      if [[ "$(docker inspect --format '{{.State.Status}}' "$aio_borg_container" 2>/dev/null || true)" != "exited" ]]; then
        die "AIO Borg container is active after its check"
      fi
      if docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "$aio_borg_container" |
        grep -Eq '^BORG_REMOTE_REPO=.+$'; then
        die "AIO is configured with a remote Borg repository"
      fi
      actual_backup_directory="$(docker inspect --format '{{range .Mounts}}{{if eq .Destination "/mnt/borgbackup"}}{{.Source}}{{end}}{{end}}' "$aio_borg_container")"
      if [[ "$actual_backup_directory" != "$aio_backup_directory" ]]; then
        die "AIO Borg mount is $actual_backup_directory, expected $aio_backup_directory"
      fi
      if [[ ! -f "$aio_repository/config" ]]; then
        die "AIO Borg repository is unavailable at $aio_repository"
      fi

      printf 'homestation backup: AIO Borg repository is ready for replication\n' >&2
    '';
  };

  cleanupScript = pkgs.writeShellApplication {
    name = "homestation-backup-cleanup";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.docker
      pkgs.systemd
    ];
    text = ''
      stage_dir=${escapeShellArg localBackupStagingDirectory}
      stopped_services_file=${escapeShellArg stoppedServicesFile}
      aio_pause_marker=${escapeShellArg aioPauseMarker}
      cleanup_status=0

      set +e
      if [[ -e "$aio_pause_marker" ]]; then
        unpaused=false
        if ! docker inspect nextcloud-aio-mastercontainer >/dev/null 2>&1; then
          printf 'homestation backup: AIO mastercontainer disappeared while paused\n' >&2
          cleanup_status=1
        elif [[ "$(docker inspect --format '{{.State.Paused}}' nextcloud-aio-mastercontainer)" != "true" ]]; then
          printf 'homestation backup: AIO mastercontainer was not paused during cleanup\n' >&2
          cleanup_status=1
        else
          for ((attempt = 1; attempt <= 3; attempt++)); do
            if docker unpause nextcloud-aio-mastercontainer >/dev/null; then
              unpaused=true
              printf 'homestation backup: AIO mastercontainer unpaused\n' >&2
              break
            fi
            sleep 1
          done
          if [[ "$unpaused" != "true" ]]; then
            printf 'homestation backup: could not unpause AIO mastercontainer\n' >&2
            cleanup_status=1
          fi
        fi
        if [[ "$unpaused" == "true" || ! -e "$aio_pause_marker" ]]; then
          rm -f -- "$aio_pause_marker" || cleanup_status=1
        fi
      fi

      if [[ -f "$stopped_services_file" ]]; then
        mapfile -t stopped_services <"$stopped_services_file"
        for ((index = ''${#stopped_services[@]} - 1; index >= 0; index--)); do
          service="''${stopped_services[index]}"
          [[ -z "$service" ]] && continue
          printf 'homestation backup: starting %s\n' "$service" >&2
          if ! systemctl start "$service"; then
            printf 'homestation backup: could not start %s\n' "$service" >&2
            cleanup_status=1
          fi
        done
      fi

      if ! rm -rf -- "$stage_dir"; then
        printf 'homestation backup: could not remove staging data\n' >&2
        cleanup_status=1
      fi
      exit "$cleanup_status"
    '';
  };

  stageFilesScript = pkgs.writeShellApplication {
    name = "homestation-backup-files";
    text = ''
      printf '%s\n' ${escapeShellArg localBackupStagingDirectory}
    '';
  };

  offsiteMirrorScript = pkgs.writeShellApplication {
    name = "homestation-offsite-mirror";
    runtimeInputs = [
      pkgs.docker
      pkgs.rclone
    ];
    text = ''
      aio_repository=${escapeShellArg nextcloudAioRepository}
      aio_pause_marker=${escapeShellArg aioPauseMarker}
      remote_aio_repository=${escapeShellArg oneDriveAioRepository}
      rclone_config=${escapeShellArg oneDriveRcloneConfig}

      die() {
        printf 'homestation offsite backup: %s\n' "$*" >&2
        exit 1
      }

      if [[ ! -e "$aio_pause_marker" ]]; then
        die "AIO pause is not owned by the local backup run"
      fi
      if [[ "$(docker inspect --format '{{.State.Paused}}' nextcloud-aio-mastercontainer 2>/dev/null || true)" != "true" ]]; then
        die "AIO mastercontainer is not paused"
      fi
      if [[ "$(docker inspect --format '{{.State.Status}}' nextcloud-aio-borgbackup 2>/dev/null || true)" != "exited" ]]; then
        die "AIO Borg container is active"
      fi
      if [[ ! -f "$aio_repository/config" ]]; then
        die "local AIO Borg repository is unavailable"
      fi

      printf 'homestation offsite backup: mirroring AIO Borg repository\n' >&2
      rclone --config "$rclone_config" sync "$aio_repository" "$remote_aio_repository"
      rclone --config "$rclone_config" lsf "$remote_aio_repository/config" >/dev/null
    '';
  };

  offsitePrepareScript = pkgs.writeShellApplication {
    name = "homestation-offsite-prepare";
    runtimeInputs = [
      pkgs.docker
      pkgs.rclone
      pkgs.restic
      pkgs.systemd
    ];
    text = ''
      local_repository=${escapeShellArg localResticRepository}
      local_password_file=${escapeShellArg localResticPassword}
      remote_repository=${escapeShellArg oneDriveResticRepository}
      remote_password_file=${escapeShellArg offsiteResticPassword}
      rclone_config=${escapeShellArg oneDriveRcloneConfig}
      remote_name=${escapeShellArg oneDriveRemote}
      aio_repository=${escapeShellArg nextcloudAioRepository}
      aio_pause_marker=${escapeShellArg aioPauseMarker}

      die() {
        printf 'homestation offsite backup: %s\n' "$*" >&2
        exit 1
      }

      if [[ ! -e "$aio_pause_marker" ]]; then
        die "AIO pause is not owned by the local backup run"
      fi
      local_state="$(systemctl show --property=ActiveState --value restic-backups-local.service)"
      if [[ "$local_state" != "active" && "$local_state" != "activating" ]]; then
        die "the local backup service is not active"
      fi
      if [[ "$(docker inspect --format '{{.State.Paused}}' nextcloud-aio-mastercontainer 2>/dev/null || true)" != "true" ]]; then
        die "AIO mastercontainer is not paused"
      fi
      if [[ "$(docker inspect --format '{{.State.Status}}' nextcloud-aio-borgbackup 2>/dev/null || true)" != "exited" ]]; then
        die "AIO Borg container is active"
      fi
      if [[ ! -f "$aio_repository/config" ]]; then
        die "local AIO Borg repository is unavailable"
      fi
      if ! restic --repo "$local_repository" --password-file "$local_password_file" cat config >/dev/null 2>&1; then
        die "local Restic repository is unavailable"
      fi
      if [[ ! -r "$remote_password_file" || ! -r "$rclone_config" ]]; then
        die "offsite secret is unavailable"
      fi
      if ! rclone --config "$rclone_config" lsd "$remote_name:" >/dev/null; then
        die "OneDrive rclone remote $remote_name is unavailable"
      fi
      export RCLONE_CONFIG="$rclone_config"

      if ! restic --repo "$remote_repository" --password-file "$remote_password_file" cat config >/dev/null 2>&1; then
        printf 'homestation offsite backup: initializing the independent remote Restic repository\n' >&2
        restic --repo "$remote_repository" --password-file "$remote_password_file" init
      fi

      printf 'homestation offsite backup: copying Restic snapshots\n' >&2
      restic \
        --repo "$remote_repository" \
        --password-file "$remote_password_file" \
        --from-repo "$local_repository" \
        --from-password-file "$local_password_file" \
        copy
    '';
  };

  retentionOptions = [
    "--tag local-application"
    "--keep-daily ${toString retention.daily}"
    "--keep-weekly ${toString retention.weekly}"
    "--keep-monthly ${toString retention.monthly}"
  ];
in
assert !offsiteResticPrune || offsiteRetentionReviewed;
{
  services.restic.backups = {
    local = {
      repository = localResticRepository;
      passwordFile = localResticPassword;
      initialize = true;
      paths = directPaths;
      dynamicFilesFrom = "${stageFilesScript}/bin/homestation-backup-files";
      backupPrepareCommand = "${prepareScript}/bin/homestation-backup-prepare";
      backupCleanupCommand = "${cleanupScript}/bin/homestation-backup-cleanup";
      extraBackupArgs = [
        "--one-file-system"
        "--exclude-caches"
        "--tag local-application"
      ];
      pruneOpts = retentionOptions;
      runCheck = true;
      timerConfig = {
        OnCalendar = "*-*-* 03:30:00";
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
    };

    offsite = {
      repository = oneDriveResticRepository;
      passwordFile = offsiteResticPassword;
      rcloneConfigFile = oneDriveRcloneConfig;
      backupPrepareCommand = "${offsitePrepareScript}/bin/homestation-offsite-prepare";
      pruneOpts = optionals offsiteResticPrune retentionOptions;
      runCheck = true;
      timerConfig = null;
    };
  };

  systemd.services."restic-backups-local" = {
    after = [
      "docker.service"
      "docker.socket"
    ];
    requires = [
      "docker.service"
      "docker.socket"
    ];
    unitConfig.RequiresMountsFor = [
      "/mnt/backup"
      localBackupStagingDirectory
      localResticRepository
      nextcloudAioRepository
    ];
    serviceConfig = {
      TimeoutStartSec = "24h";
      ExecStartPost = "${pkgs.systemd}/bin/systemctl start --wait restic-backups-offsite.service";
    };
  };

  systemd.services."restic-backups-offsite" = {
    after = [
      "docker.service"
      "docker.socket"
    ];
    requires = [
      "docker.service"
      "docker.socket"
    ];
    path = [ pkgs.rclone ];
    unitConfig = {
      ConditionPathExists = aioPauseMarker;
      RequiresMountsFor = [
        "/mnt/backup"
        localResticRepository
        nextcloudAioRepository
      ];
    };
    serviceConfig = {
      TimeoutStartSec = "24h";
      ExecStartPost = "${offsiteMirrorScript}/bin/homestation-offsite-mirror";
    };
  };
}
