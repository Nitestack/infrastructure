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
    filter
    hasPrefix
    imap0
    mkEnableOption
    mkIf
    mkOption
    optional
    optionalString
    unique
    types
    ;

  cfg = config.services.localBackup;

  sourceType = types.submodule {
    options = {
      label = mkOption {
        type = types.str;
      };

      path = mkOption {
        type = types.str;
      };

      purpose = mkOption {
        type = types.str;
      };

      stoppedService = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Systemd service to stop briefly while this mutable source is copied into staging.";
      };

      shared = mkOption {
        type = types.bool;
        default = false;
        description = "Whether this source is shared by multiple services and must be listed only once.";
      };
    };
  };

  postgresDumpType = types.submodule {
    options = {
      label = mkOption {
        type = types.str;
      };

      container = mkOption {
        type = types.str;
      };

      database = mkOption {
        type = types.str;
      };

      user = mkOption {
        type = types.str;
      };

      passwordFile = mkOption {
        type = types.str;
      };

      outputName = mkOption {
        type = types.str;
      };
    };
  };

  runtimeVolumeType = types.submodule {
    options = {
      label = mkOption {
        type = types.str;
      };

      volume = mkOption {
        type = types.str;
      };

      destination = mkOption {
        type = types.str;
      };

      stoppedService = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Systemd service to stop briefly while this runtime volume is copied into staging.";
      };

      required = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  exclusionType = types.submodule {
    options = {
      label = mkOption {
        type = types.str;
      };

      reason = mkOption {
        type = types.str;
      };
    };
  };

  sourcePaths = unique (map (source: source.path) cfg.sources);
  mutableSourceEntries = imap0 (
    index: source:
    source
    // {
      stagingName = "source-${toString index}";
    }
  ) (filter (source: source.stoppedService != null) cfg.sources);
  mutableSourcePaths = map (source: source.path) mutableSourceEntries;
  mutableRuntimeVolumes = filter (volume: volume.stoppedService != null) cfg.runtimeVolumes;
  mutableServices = unique (
    map (source: source.stoppedService) mutableSourceEntries
    ++ map (volume: volume.stoppedService) mutableRuntimeVolumes
  );
  managedRepositories = unique ([ cfg.repository ] ++ cfg.managedRepositories);

  sourceConsistency =
    source:
    if source.stoppedService == null then
      ""
    else
      " (captured while `" + source.stoppedService + "` is stopped)";

  runtimeVolumeConsistency =
    volume:
    if volume.stoppedService == null then
      ""
    else
      " (captured while `" + volume.stoppedService + "` is stopped)";

  includedManifest =
    if cfg.sources == [ ] then
      "- None"
    else
      concatMapStringsSep "\n" (
        source:
        "- ${source.label}: `${source.path}` - ${source.purpose}${optionalString source.shared " (shared source; captured once)"}${sourceConsistency source}"
      ) cfg.sources;

  sharedManifest =
    let
      sharedSources = filter (source: source.shared) cfg.sources;
    in
    if sharedSources == [ ] then
      "- None"
    else
      concatMapStringsSep "\n" (source: "- ${source.label}: `${source.path}`") sharedSources;

  postgresManifest =
    if cfg.postgresDumps == [ ] then
      "- None"
    else
      concatMapStringsSep "\n" (
        dump:
        "- ${dump.label}: logical `pg_dump` from `${dump.container}` database `${dump.database}` as `${dump.user}` -> `${dump.outputName}`"
      ) cfg.postgresDumps;

  runtimeManifest =
    if cfg.runtimeVolumes == [ ] then
      "- None"
    else
      concatMapStringsSep "\n" (
        volume:
        "- ${volume.label}: inspect Docker volume `${volume.volume}` and capture it under `runtime/${volume.destination}`${runtimeVolumeConsistency volume}"
      ) cfg.runtimeVolumes;

  exclusionManifest =
    if cfg.exclusions == [ ] then
      "- None"
    else
      concatMapStringsSep "\n" (entry: "- ${entry.label}: ${entry.reason}") cfg.exclusions;

  managedRepositoryManifest = concatMapStringsSep "\n" (path: "- `${path}`") managedRepositories;

  preResticManifest =
    if cfg.preResticScript == null then
      "- None"
    else
      "- Configured command (runs under the pipeline lock before the Restic stage)";

  postResticManifest =
    if cfg.postResticScript == null then
      "- None"
    else
      "- Configured command (runs under the pipeline lock after the local Restic stage)";

  manifestFile = "/etc/local-backup/manifest";

  manifestText = ''
    Local application backup manifest (report-only)
    =================================================

    Repository: ${cfg.repository}
    Required filesystem: ${cfg.requiredMount}
    Schedule: ${cfg.timer.onCalendar}
    Retention: ${toString cfg.retention.daily} daily, ${toString cfg.retention.weekly} weekly, ${toString cfg.retention.monthly} monthly
    Tag: ${cfg.tag}

    Integrity checks:
    - Restic runs a structural `restic check` after local retention on every pipeline run.

    Pre-Restic backup step:
    ${preResticManifest}

    Post-Restic backup step:
    ${postResticManifest}

    Included service data:
    ${includedManifest}

    Shared sources captured once:
    ${sharedManifest}

    PostgreSQL logical dumps (database directories are not copied):
    ${postgresManifest}

    Runtime volume inspection:
    ${runtimeManifest}

    Deliberate exclusions and coverage gaps:
    ${exclusionManifest}

    Managed repositories counted by the one-copy capacity gate:
    ${managedRepositoryManifest}

    Preparation behavior:
    - The backup filesystem is verified as mounted before any repository or staging path is created.
    - Services associated with mutable sources or runtime volumes are stopped only while their staged copy is made and are restarted on every exit path.
    - Any configured pre-Restic backup step completes before the Restic snapshot starts.
    - One Restic snapshot is created only after all required preparation and the capacity gate succeed.
    - Any configured post-Restic backup step completes before this service is successful.
    - The systemd service holds `/run/local-backup/lock` for the complete pipeline.
  '';

  reportScript = pkgs.writeShellApplication {
    name = "local-backup-manifest";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.docker
      pkgs.findutils
    ];
    text = ''
      cat ${escapeShellArg manifestFile}
      printf '\nRuntime volume inspection (read-only):\n'

      inspect_volume() {
        local volume="$1"
        local label="$2"
        local mountpoint

        if mountpoint="$(docker volume inspect --format '{{.Mountpoint}}' "$volume" 2>/dev/null)"; then
          printf '%s: %s (%s)\n' "$label" "$volume" "$mountpoint"
          if [[ -d "$mountpoint" ]]; then
            find "$mountpoint" -mindepth 1 -maxdepth 2 -type f -printf '  %P\n' | sort
          else
            printf '  mountpoint is not readable\n'
          fi
        else
          printf '%s: %s (volume is not present)\n' "$label" "$volume"
        fi
      }

      ${concatMapStringsSep "\n" (
        volume: "inspect_volume ${escapeShellArg volume.volume} ${escapeShellArg volume.label}"
      ) cfg.runtimeVolumes}
    '';
  };

  sourcePathArray = concatMapStringsSep "\n" (path: "  ${escapeShellArg path}") (
    filter (path: !(builtins.elem path mutableSourcePaths)) sourcePaths
  );

  postgresDumpCommands = concatMapStringsSep "\n" (dump: ''
    dump_postgres \
      ${escapeShellArg dump.label} \
    ${escapeShellArg dump.container} \
    ${escapeShellArg dump.database} \
    ${escapeShellArg dump.user} \
    ${escapeShellArg dump.passwordFile} \
    "$run_dir/${dump.outputName}"
  '') cfg.postgresDumps;

  runtimeVolumeCommands = concatMapStringsSep "\n" (volume: ''
    inspect_runtime_volume \
      ${escapeShellArg volume.label} \
      ${escapeShellArg volume.volume} \
      ${escapeShellArg volume.destination} \
      ${if volume.required then "true" else "false"}
  '') (filter (volume: volume.stoppedService == null) cfg.runtimeVolumes);

  mutableSourceCommands =
    service:
    concatMapStringsSep "\n" (source: ''
      capture_mutable_source \
        ${escapeShellArg source.label} \
        ${escapeShellArg source.path} \
        "$run_dir/${source.stagingName}"
    '') (filter (source: source.stoppedService == service) mutableSourceEntries);

  mutableRuntimeVolumeCommands =
    service:
    concatMapStringsSep "\n" (volume: ''
      inspect_runtime_volume \
        ${escapeShellArg volume.label} \
        ${escapeShellArg volume.volume} \
        ${escapeShellArg volume.destination} \
        ${if volume.required then "true" else "false"}
    '') (filter (volume: volume.stoppedService == service) mutableRuntimeVolumes);

  mutableServiceCommands = concatMapStringsSep "\n" (
    service:
    let
      sourceCommands = mutableSourceCommands service;
      runtimeVolumeCommandsForService = mutableRuntimeVolumeCommands service;
    in
    ''
      service_was_active=false
      stop_service ${escapeShellArg service}
      ${sourceCommands}
      ${runtimeVolumeCommandsForService}
      if [[ "$service_was_active" == "true" ]]; then
        restart_service ${escapeShellArg service}
      fi
    ''
  ) mutableServices;

  managedRepositoryCommands = concatMapStringsSep "\n" (path: ''
    if [[ -e ${escapeShellArg path} ]]; then
      repository_bytes=$((repository_bytes + $(measure_bytes ${escapeShellArg path})))
    fi
  '') managedRepositories;

  preResticCommands =
    if cfg.preResticScript == null then
      ""
    else
      ''
        printf 'local backup: running pre-Restic backup step\n' >&2
        if ! ${escapeShellArg (toString cfg.preResticScript)}; then
          die "pre-Restic backup step failed"
        fi
      '';

  postResticCommands =
    if cfg.postResticScript == null then
      ""
    else
      ''
        printf 'local backup: running post-Restic backup step\n' >&2
        if ! ${escapeShellArg (toString cfg.postResticScript)}; then
          die "post-Restic backup step failed"
        fi
      '';

  backupScript = pkgs.writeShellApplication {
    name = "local-backup";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.docker
      pkgs.findutils
      pkgs.gawk
      pkgs.gzip
      pkgs.restic
      pkgs.systemd
      pkgs.util-linux
    ];
    text = ''
      required_mount=${escapeShellArg cfg.requiredMount}
      repository=${escapeShellArg cfg.repository}
      staging_directory=${escapeShellArg cfg.stagingDirectory}
      password_file=${escapeShellArg cfg.passwordFile}
      manifest_file=${escapeShellArg manifestFile}
      tag=${escapeShellArg cfg.tag}
      run_dir=""
      stopped_services=()

      die() {
        printf 'local backup: %s\n' "$*" >&2
        exit 1
      }

      cleanup() {
        local status="$?"
        local cleanup_status=0
        local index

        trap - EXIT
        set +e

        if [[ -n "$run_dir" ]]; then
          if ! rm -rf -- "$run_dir"; then
            cleanup_status=1
          fi
          run_dir=""
        fi

        for ((index = ''${#stopped_services[@]} - 1; index >= 0; index--)); do
          printf 'local backup: restarting %s\n' "''${stopped_services[index]}" >&2
          if ! systemctl start "''${stopped_services[index]}"; then
            printf 'local backup: failed to restart %s\n' "''${stopped_services[index]}" >&2
            cleanup_status=1
          fi
        done

        if [[ "$cleanup_status" -ne 0 ]]; then
          status=1
        fi
        if [[ "$status" -ne 0 ]]; then
          printf 'local backup: preparation or backup failed; inspect journalctl -u local-backup.service\n' >&2
        fi
        exit "$status"
      }
      trap cleanup EXIT

      if ! mountpoint --quiet -- "$required_mount"; then
        die "required backup filesystem is not mounted at $required_mount"
      fi
      if [[ "$repository" != "$required_mount"/* ]]; then
        die "repository $repository is outside required filesystem $required_mount"
      fi
      if [[ "$staging_directory" != "$required_mount"/* ]]; then
        die "staging directory $staging_directory is outside required filesystem $required_mount"
      fi
      if [[ ! -r "$password_file" ]]; then
        die "Restic password file is unavailable"
      fi

      install -d -m 0700 -- "$staging_directory"
      run_dir="$staging_directory/$(date -u +%Y%m%dT%H%M%SZ)-$$"
      install -d -m 0700 -- "$run_dir"
      install -m 0444 -- "$manifest_file" "$run_dir/manifest.txt"

      dump_postgres() {
        local label="$1"
        local container="$2"
        local database="$3"
        local user="$4"
        local dump_password_file="$5"
        local output="$6"
        local temporary_output="''${output}.partial"
        local password

        if ! docker inspect "$container" >/dev/null 2>&1; then
          die "PostgreSQL container $container for $label is missing"
        fi
        if [[ "$(docker inspect --format '{{.State.Running}}' "$container")" != "true" ]]; then
          die "PostgreSQL container $container for $label is not running"
        fi
        if [[ ! -r "$dump_password_file" ]]; then
          die "password file for PostgreSQL dump $label is unavailable"
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
          die "PostgreSQL logical dump failed for $label"
        fi
        mv -- "$temporary_output" "$output"
        printf 'local backup: captured PostgreSQL dump for %s\n' "$label" >&2
      }

      ${postgresDumpCommands}

      stop_service() {
        local service="$1"

        if ! systemctl cat "$service" >/dev/null 2>&1; then
          die "required service unit $service is missing"
        fi
        service_was_active=false
        if systemctl is-active --quiet "$service"; then
          stopped_services+=("$service")
          service_was_active=true
          printf 'local backup: stopping %s\n' "$service" >&2
          if ! systemctl stop "$service"; then
            die "could not stop $service"
          fi
        fi
      }

      restart_service() {
        local service="$1"

        printf 'local backup: restarting %s\n' "$service" >&2
        if ! systemctl start "$service"; then
          die "could not restart $service"
        fi
        stopped_services=()
      }

      capture_mutable_source() {
        local label="$1"
        local source="$2"
        local destination="$3"

        if [[ ! -e "$source" ]]; then
          die "mutable source is missing for $label: $source"
        fi
        if [[ -d "$source" ]]; then
          install -d -m 0700 -- "$destination"
          cp -a -- "$source"/. "$destination"/
        else
          install -d -m 0700 -- "$(dirname -- "$destination")"
          cp -a -- "$source" "$destination"
        fi
        printf 'local backup: captured mutable source %s\n' "$label" >&2
      }

      inspect_runtime_volume() {
        local label="$1"
        local volume="$2"
        local destination="$3"
        local required="$4"
        local mountpoint
        local output="$run_dir/runtime/$destination"

        if ! mountpoint="$(docker volume inspect --format '{{.Mountpoint}}' "$volume" 2>/dev/null)"; then
          if [[ "$required" == "true" ]]; then
            die "required runtime volume $volume for $label is missing"
          fi
          printf 'local backup: optional runtime volume %s is missing\n' "$volume" >&2
          return
        fi
        if [[ ! -d "$mountpoint" ]]; then
          die "runtime volume $volume for $label has no readable mountpoint"
        fi

        install -d -m 0700 -- "$output"
        cp -a -- "$mountpoint"/. "$output"/
        printf 'local backup: captured runtime volume %s for %s\n' "$volume" "$label" >&2
      }

      ${mutableServiceCommands}

      ${runtimeVolumeCommands}

      backup_paths=(
      ${sourcePathArray}
        "$run_dir"
      )
      for backup_path in "''${backup_paths[@]}"; do
        if [[ ! -e "$backup_path" ]]; then
          die "included source is missing: $backup_path"
        fi
      done

      measure_bytes() {
        du --bytes --summarize --one-file-system -- "$1" | awk '{ print $1 }'
      }

      capacity_gate() {
        source_bytes=0
        for backup_path in "''${backup_paths[@]}"; do
          source_bytes=$((source_bytes + $(measure_bytes "$backup_path")))
        done

        repository_bytes=0
        ${managedRepositoryCommands}

        free_bytes="$(df --block-size=1 --output=avail -- "$required_mount" | awk 'NR == 2 { print $1 }')"
        required_bytes=$((source_bytes + repository_bytes + ${toString cfg.safetyMarginBytes}))
        if [[ -z "$free_bytes" ]] || ((free_bytes < required_bytes)); then
          die "capacity gate failed: free=$free_bytes required=$required_bytes (sources=$source_bytes repositories=$repository_bytes margin=${toString cfg.safetyMarginBytes})"
        fi
        printf 'local backup: capacity gate passed: free=%s required=%s\n' "$free_bytes" "$required_bytes" >&2
      }

      capacity_gate

      ${preResticCommands}

      ${optionalString (cfg.preResticScript != null) "capacity_gate"}

      install -d -m 0700 -- "$repository"
      if [[ ! -e "$repository/config" ]]; then
        printf 'local backup: initializing encrypted Restic repository\n' >&2
        restic --repo "$repository" --password-file "$password_file" init
      fi

      files_from="$run_dir/files-from"
      printf '%s\n' "''${backup_paths[@]}" >"$files_from"
      restic --repo "$repository" --password-file "$password_file" backup \
        --files-from "$files_from" \
        --one-file-system \
        --exclude-caches \
        --tag "$tag"

      restic --repo "$repository" --password-file "$password_file" forget \
        --tag "$tag" \
        --keep-daily ${toString cfg.retention.daily} \
        --keep-weekly ${toString cfg.retention.weekly} \
        --keep-monthly ${toString cfg.retention.monthly} \
        --prune

      printf 'local backup: checking Restic repository integrity\n' >&2
      restic --repo "$repository" --password-file "$password_file" check
      printf 'local backup: Restic repository integrity check passed\n' >&2

      ${postResticCommands}

      printf 'local backup: completed one Restic snapshot\n' >&2
    '';
  };

  alertService = {
    description = "Report a failed local application backup";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/logger -p daemon.err -t local-backup local-backup.service failed; inspect its journal";
    };
  };
in
{
  options.services.localBackup = {
    enable = mkEnableOption "a locked local application backup pipeline";

    repository = mkOption {
      type = types.str;
      default = "";
      description = "Restic repository path. It must be below requiredMount.";
    };

    requiredMount = mkOption {
      type = types.str;
      default = "";
      description = "Filesystem mountpoint that must be mounted before staging or repository access.";
    };

    stagingDirectory = mkOption {
      type = types.str;
      default = "";
      description = "Temporary staging directory for dumps and runtime volume copies. It must be below requiredMount.";
    };

    passwordFile = mkOption {
      type = types.str;
      default = "";
      description = "Runtime-only file containing the Restic repository password.";
    };

    requiresSops = mkOption {
      type = types.bool;
      default = false;
      description = "Wait for sops-nix secret installation before starting the backup.";
    };

    tag = mkOption {
      type = types.str;
      default = "local-application";
    };

    timer = {
      onCalendar = mkOption {
        type = types.str;
        default = "*-*-* 03:30:00";
      };

      randomizedDelaySec = mkOption {
        type = types.str;
        default = "30m";
      };

      persistent = mkOption {
        type = types.bool;
        default = true;
      };
    };

    retention = {
      daily = mkOption {
        type = types.ints.positive;
        default = 7;
      };

      weekly = mkOption {
        type = types.ints.positive;
        default = 4;
      };

      monthly = mkOption {
        type = types.ints.positive;
        default = 12;
      };
    };

    safetyMarginBytes = mkOption {
      type = types.int;
      default = 1073741824;
      description = "Additional free-space margin required by the one-copy capacity gate.";
    };

    managedRepositories = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Other backup repositories whose existing size is included in the capacity gate.";
    };

    preResticScript = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Optional command run under the pipeline lock after the initial capacity gate and before the Restic stage. The command must return zero before Restic continues.";
    };

    postResticScript = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Optional command run under the pipeline lock after local Restic retention. The command must return zero before the backup service succeeds.";
    };

    sources = mkOption {
      type = types.listOf sourceType;
      default = [ ];
    };

    postgresDumps = mkOption {
      type = types.listOf postgresDumpType;
      default = [ ];
    };

    runtimeVolumes = mkOption {
      type = types.listOf runtimeVolumeType;
      default = [ ];
      description = "Docker volumes inspected and copied into the staging run at backup time.";
    };

    exclusions = mkOption {
      type = types.listOf exclusionType;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.repository != "";
        message = "services.localBackup.repository must be set when localBackup.enable = true.";
      }
      {
        assertion = cfg.requiredMount != "";
        message = "services.localBackup.requiredMount must be set when localBackup.enable = true.";
      }
      {
        assertion = cfg.stagingDirectory != "";
        message = "services.localBackup.stagingDirectory must be set when localBackup.enable = true.";
      }
      {
        assertion = cfg.passwordFile != "";
        message = "services.localBackup.passwordFile must be set when localBackup.enable = true.";
      }
      {
        assertion = hasPrefix "${cfg.requiredMount}/" cfg.repository;
        message = "services.localBackup.repository must be below services.localBackup.requiredMount.";
      }
      {
        assertion = hasPrefix "${cfg.requiredMount}/" cfg.stagingDirectory;
        message = "services.localBackup.stagingDirectory must be below services.localBackup.requiredMount.";
      }
      {
        assertion = cfg.repository != cfg.stagingDirectory;
        message = "services.localBackup.repository and stagingDirectory must be different paths.";
      }
      {
        assertion = cfg.safetyMarginBytes >= 0;
        message = "services.localBackup.safetyMarginBytes must not be negative.";
      }
      {
        assertion = cfg.sources != [ ];
        message = "services.localBackup.sources must declare at least one included source.";
      }
      {
        assertion = builtins.all (path: hasPrefix "${cfg.requiredMount}/" path) managedRepositories;
        message = "services.localBackup.managedRepositories must be below services.localBackup.requiredMount.";
      }
      {
        assertion = builtins.length sourcePaths == builtins.length cfg.sources;
        message = "services.localBackup.sources must list each source path only once so shared data is captured once.";
      }
    ];

    environment.etc."local-backup/manifest" = {
      text = manifestText;
      mode = "0444";
    };

    environment.systemPackages = [ reportScript ];

    systemd.services."local-backup-alert" = alertService;

    systemd.services."local-backup" = {
      description = "Create the locked local application backups";
      after = [
        "docker.service"
        "docker.socket"
      ]
      ++ optional cfg.requiresSops "sops-install-secrets.service";
      requires = [
        "docker.service"
        "docker.socket"
      ]
      ++ optional cfg.requiresSops "sops-install-secrets.service";
      unitConfig = {
        OnFailure = [ "local-backup-alert.service" ];
        RequiresMountsFor = [
          cfg.requiredMount
          cfg.repository
          cfg.stagingDirectory
        ];
      };
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "root";
        RuntimeDirectory = "local-backup";
        RuntimeDirectoryMode = "0700";
        UMask = "0077";
        TimeoutStartSec = "24h";
        ExecStart = "${pkgs.util-linux}/bin/flock --exclusive /run/local-backup/lock ${backupScript}/bin/local-backup";
      };
    };

    systemd.timers."local-backup" = {
      description = "Run the local application backup pipeline daily";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.timer.onCalendar;
        RandomizedDelaySec = cfg.timer.randomizedDelaySec;
        Persistent = cfg.timer.persistent;
        Unit = "local-backup.service";
      };
    };
  };
}
