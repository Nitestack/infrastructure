{
  inputs,
  pkgs,
  system,
}:
let
  lib = inputs.nixpkgs.lib;

  baseModule = {
    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
    };
    boot.loader.grub.devices = [ "/dev/null" ];
    system.stateVersion = "26.05";
  };

  mkSystem =
    extraModules:
    lib.nixosSystem {
      inherit system;
      modules = [
        ../modules/nixos/local-backup.nix
        baseModule
      ]
      ++ extraModules;
    };

  goodConfig = mkSystem [
    {
      services.localBackup = {
        enable = true;
        requiredMount = "/mnt/backup";
        repository = "/mnt/backup/restic";
        stagingDirectory = "/mnt/backup/.staging";
        passwordFile = "/run/secrets/restic-password";
        managedRepositories = [ "/mnt/backup/nextcloud-aio/borg" ];
        preResticScript = pkgs.writeShellApplication {
          name = "pre-restic-regression";
          text = "true";
        };
        sources = [
          {
            label = "application data";
            path = "/var/lib/application";
            purpose = "persistent state";
          }
        ];
        postgresDumps = [
          {
            label = "application PostgreSQL";
            container = "application-postgres";
            database = "application";
            user = "application";
            passwordFile = "/run/secrets/application-password";
            outputName = "postgres/application.sql.gz";
          }
        ];
      };
    }
  ];

  invalidRepositoryEval = builtins.tryEval (
    (mkSystem [
      {
        services.localBackup = {
          enable = true;
          requiredMount = "/mnt/backup";
          repository = "/var/lib/restic";
          stagingDirectory = "/mnt/backup/.staging";
          passwordFile = "/run/secrets/restic-password";
          sources = [
            {
              label = "application data";
              path = "/var/lib/application";
              purpose = "persistent state";
            }
          ];
        };
      }
    ]).config.system.build.toplevel.drvPath
  );

  invalidSourcesEval = builtins.tryEval (
    (mkSystem [
      {
        services.localBackup = {
          enable = true;
          requiredMount = "/mnt/backup";
          repository = "/mnt/backup/restic";
          stagingDirectory = "/mnt/backup/.staging";
          passwordFile = "/run/secrets/restic-password";
        };
      }
    ]).config.system.build.toplevel.drvPath
  );

  service = goodConfig.config.systemd.services.local-backup;
  timer = goodConfig.config.systemd.timers.local-backup;
  manifest = goodConfig.config.environment.etc."local-backup/manifest".text;
in
assert builtins.elem "/mnt/backup" service.unitConfig.RequiresMountsFor;
assert builtins.elem "local-backup-alert.service" service.unitConfig.OnFailure;
assert lib.hasInfix "/run/local-backup/lock" service.serviceConfig.ExecStart;
assert timer.timerConfig.Persistent;
assert timer.timerConfig.OnCalendar == "*-*-* 03:30:00";
assert lib.hasInfix "Retention: 7 daily, 4 weekly, 12 monthly" manifest;
assert lib.hasInfix "PostgreSQL logical dumps" manifest;
assert lib.hasInfix "Pre-Restic backup step" manifest;
assert lib.hasInfix "/mnt/backup/nextcloud-aio/borg" manifest;
assert !invalidRepositoryEval.success;
assert !invalidSourcesEval.success;
pkgs.runCommand "local-backup-regressions" { } ''
  touch "$out"
''
