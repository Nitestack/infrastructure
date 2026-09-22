{
  inputs,
  pkgs,
  system,
}:
let
  lib = inputs.nixpkgs.lib;

  secretNames = [
    "backup/restic-password"
    "backup/offsite-restic-password"
    "backup/onedrive-rclone-config"
    "adventure-log/db-password"
    "audiomuse-ai/db-password"
    "ente/db-password"
    "immich/db-password"
  ];

  baseModule = {
    options.sops.secrets = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.path = lib.mkOption { type = lib.types.str; };
        }
      );
      default = { };
    };
    config = {
      fileSystems."/" = {
        device = "none";
        fsType = "tmpfs";
      };
      system.stateVersion = "26.05";
      homelab.libraries.music.path = "/var/lib/homelab/music";
      sops.secrets = lib.genAttrs secretNames (name: {
        path = "/run/secrets/${name}";
      });
    };
  };

  testSystem = lib.nixosSystem {
    inherit system;
    modules = [
      inputs.arion.nixosModules.arion
      ../modules/nixos/homelab
      ../configurations/nixos/homestation/backup.nix
      baseModule
    ];
  };

  localService = testSystem.config.systemd.services."restic-backups-local";
  localTimer = testSystem.config.systemd.timers."restic-backups-local";
  offsiteService = testSystem.config.systemd.services."restic-backups-offsite";
  localRestic = testSystem.config.services.restic.backups.local;
  offsiteBackup = testSystem.config.services.restic.backups.offsite;
  localPrepareScript = builtins.readFile localRestic.backupPrepareCommand;
  offsitePrepareScript = builtins.readFile offsiteBackup.backupPrepareCommand;
  offsiteMirrorScript = builtins.readFile offsiteService.serviceConfig.ExecStartPost;
  stableStageNames = [
    "caddy-data"
    "caddy-config"
    "calibre-web-automated-config"
    "calibre-web-automated-plugins"
    "beets-config"
    "freshrss-data"
    "freshrss-extensions"
    "navidrome-data"
    "pocket-id-data"
    "prowlarr-data"
    "rdtclient-db"
    "shelfmark-config"
    "vaultwarden-data"
    "vikunja-db"
    "wealthfolio-data"
    "floppy-db"
    "floppy-backups"
  ];
in
assert localRestic.repository == "/mnt/backup/restic/homestation";
assert
  localRestic.paths == [
    "/var/lib/homelab/adventure-log/data"
    "/var/lib/homelab/immich/library"
    "/var/lib/homelab/music"
    "/var/lib/homelab/calibre-web-automated/library"
    "/var/lib/homelab/calibre-web-automated/upload"
    "/var/lib/homelab/rdtclient/downloads"
    "/var/lib/homelab/vikunja/files"
  ];
assert localRestic.initialize;
assert localRestic.runCheck;
assert
  localRestic.pruneOpts == [
    "--tag local-application"
    "--keep-daily 7"
    "--keep-weekly 4"
    "--keep-monthly 12"
  ];
assert localTimer.timerConfig.OnCalendar == "*-*-* 03:30:00";
assert localTimer.timerConfig.Persistent;
assert localTimer.timerConfig.RandomizedDelaySec == "30m";
assert builtins.elem "/mnt/backup" localService.unitConfig.RequiresMountsFor;
assert builtins.elem "/mnt/backup/.local-backup-staging" localService.unitConfig.RequiresMountsFor;
assert builtins.elem "/mnt/backup/borg" localService.unitConfig.RequiresMountsFor;
assert localService.serviceConfig.TimeoutStartSec == "24h";
assert lib.hasInfix "restic-backups-offsite.service" localService.serviceConfig.ExecStartPost;
assert lib.hasInfix "backupPrepareCommand" localService.preStart;
assert lib.hasInfix "backupCleanupCommand" localService.postStop;
assert lib.hasInfix "homestation-backup-prepare" localRestic.backupPrepareCommand;
assert lib.hasInfix "homestation-backup-cleanup" localRestic.backupCleanupCommand;
assert builtins.all (
  stageName: lib.hasInfix "/sources/${stageName}" localPrepareScript
) stableStageNames;
assert !lib.hasInfix "/sources/source-" localPrepareScript;
assert lib.hasInfix ''
  done <"$stopped_services_file"
    : >"$stopped_services_file"'' localPrepareScript;
assert lib.hasInfix "cleanup will retry" localPrepareScript;
assert offsiteBackup.repository == "rclone:onedrive:homestation/restic";
assert offsiteBackup.timerConfig == null;
assert lib.hasInfix "homestation-offsite-prepare" offsiteBackup.backupPrepareCommand;
assert offsiteBackup.runCheck;
assert builtins.elem pkgs.rclone offsiteService.path;
assert lib.hasInfix "restic check" (builtins.head offsiteService.serviceConfig.ExecStart);
assert lib.hasInfix "homestation-offsite-mirror" offsiteService.serviceConfig.ExecStartPost;
assert !lib.hasInfix " sync " offsitePrepareScript;
assert lib.hasInfix " sync " offsiteMirrorScript;
assert lib.hasInfix "State.Paused" offsiteMirrorScript;
assert offsiteService.serviceConfig.TimeoutStartSec == "24h";
assert offsiteService.unitConfig.ConditionPathExists == "/run/restic-backups-local/aio-paused";
pkgs.runCommand "homestation-backup-regressions" { } ''
  touch "$out"
''
