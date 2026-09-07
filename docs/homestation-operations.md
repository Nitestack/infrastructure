# Homestation Operations

`homestation` runs the self-hosted services declared through the `homelab` NixOS
module. The module reference in [Homelab services](homelab-services.md) explains
how to declare services; this runbook explains how to operate the deployed host.

## Service model

Each enabled `homelab.apps.<name>` entry becomes an Arion project and a systemd
unit named `arion-<name>.service`. Underscores are normalized to hyphens. The
generated containers log to journald. Caddy is a generated OCI container, while
Cloudflare Tunnel, AdGuard Home, and Tailscale are native NixOS services.

Persistent app bind mounts normally live under `/var/lib/homelab/<app>/`.
Named Docker volumes and deliberately absolute bind mounts are exceptions, so
check the owning app configuration before moving or restoring data.

## First checks

Run these on `homestation` when an app is unavailable:

```sh
systemctl --failed
systemctl list-units --type=service 'arion-*'
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
```

Inspect one app by project name, for example Immich:

```sh
systemctl status arion-immich
journalctl -u arion-immich -b --no-pager
```

Then inspect a specific container if the Arion unit does not reveal the cause:

```sh
docker logs immich_server
docker inspect immich_server --format '{{json .State.Health}}'
```

Container names can be explicit in the app configuration. For generated names,
single-service apps use the app name; multi-service apps use
`<app>-<service>`. The [service inventory](homestation-services.md) links to
each source file.

## Ingress and network checks

```sh
systemctl status docker-caddy
journalctl -u docker-caddy -b --no-pager
systemctl status cloudflared
journalctl -u cloudflared -b --no-pager
systemctl status adguardhome
tailscale status
```

The public path is Cloudflare → Cloudflare Tunnel → Caddy's loopback tunnel
listener → the exposed application container. Local DNS routes
`*.npham.de` to the server LAN address, and Caddy terminates the local HTTPS
connection. A failure at the tunnel or Caddy layer can therefore affect many
apps at once; begin there before restarting individual containers.

The Tailscale node advertises `192.168.178.0/24`. Route approval and Tailnet
policy are external to this repository.

## Apply a service change

All managed service changes originate in this repository. Do not edit generated
Compose state or container configuration by hand; a later activation will
replace it.

```sh
cd ~/infrastructure
nix run .#check
sudo nixos-rebuild switch --flake .#homestation
```

After activation, repeat the relevant status and log checks. Changes to
Cloudflare DNS or zone settings require the separate OpenTofu workflow in
[`opentofu/cloudflare/README.md`](../opentofu/cloudflare/README.md).

## Local application backup

The full coverage, check, failure, and restore procedure is in the
[Homestation backup and recovery runbook](homestation-backup-recovery.md).

`homestation` runs a root-owned local Restic job from the `local-backup` systemd
timer. The job runs daily at approximately 03:30, keeps seven daily, four weekly,
and twelve monthly snapshots, and stores the encrypted repository at
`/mnt/backup/restic/homestation`. When enabled, the job also runs the separate
Nextcloud AIO Borg backup and integrity check; AIO's repository is counted by
the capacity gate but is not copied into Restic.

Review the report-only coverage manifest and runtime AudioMuse plugin inspection:

```sh
local-backup-manifest
```

Run one complete backup manually and inspect its result:

```sh
sudo systemctl start local-backup.service
systemctl status local-backup.service
journalctl -u local-backup.service --no-pager
```

The service refuses to create staging or repository paths unless `/mnt/backup`
is mounted. It serializes concurrent runs, creates PostgreSQL logical dumps,
briefly stops the configured mutable-state services, and restarts services that
were active even when preparation or Restic fails. A failed capacity gate or
preparation step leaves retention untouched and marks the systemd service failed.

### OneDrive offsite stage

After the local Restic snapshot and local retention complete successfully, the
same locked `local-backup.service` runs the OneDrive offsite stage. It initializes
and updates an independent encrypted Restic repository, then mirrors the
verified AIO Borg repository. Failure of either replication fails the systemd
service and triggers the backup alert.

The remote paths are deliberately separate:

```text
rclone:onedrive:homestation/restic
onedrive:homestation/nextcloud-aio-borg
```

The AIO `rclone sync` destination is only the second prefix, so it cannot delete
generic Restic objects or unrelated OneDrive content. Both stages use the same
`/run/local-backup/lock`; an offsite operation cannot overlap another local or
offsite backup run.

The OneDrive remote and the independent Restic password are runtime-only sops
secrets. Before activating the homestation configuration, add these keys to the
encrypted host file with `sops`:

```sh
cd ~/infrastructure
sops secrets/hosts/homestation/backup.yaml
```

```text
offsite-restic-password: <password for the remote Restic repository>
onedrive-rclone-config: <complete rclone config containing a remote named onedrive>
```

The rclone config contains the OneDrive OAuth token and must remain encrypted;
do not place it in Nix, the Nix store, command arguments, or logs. The remote
Restic password is separate from the local Restic password and is also rendered
only below `/run/secrets`.

The first successful offsite run emits a OneDrive Restic `rclone size` report and
a retention dry run, but pruning is initially disabled. Review that report and
the OneDrive quota before changing `configurations/nixos/homestation/backup.nix`.
If the default seven-daily, four-weekly, and twelve-monthly policy fits, keep
`offsiteResticRetention` unchanged; otherwise select the extended history that
fits. Then set both `offsiteRetentionReviewed = true` and
`offsiteResticPrune = true`. Evaluation rejects pruning before that explicit
review marker is set.

### Nextcloud AIO Borg

The AIO backup location and encryption key are configured through the AIO
interface, not by editing generated Docker state. Before relying on the timer,
complete the AIO **Backup and restore** setup and enter this local backup
directory:

```text
/mnt/backup/nextcloud-borg
```

AIO creates the actual Borg repository at
`/mnt/backup/nextcloud-borg/borg`. Keep the passphrase shown by AIO separately.
Disable AIO's native daily backup schedule after completing setup;
`local-backup.timer` is the sole scheduler, and the service refuses to run while
the native schedule is enabled. Manual backup and restore operations must not be
started while `local-backup.service` is active.

After setup on `homestation`, add it to the encrypted host backup file as
`nextcloud-borg-passphrase` using the existing sops workflow from the repository
root:

```sh
cd ~/infrastructure
sops secrets/hosts/homestation/backup.yaml
```

The file is encrypted for both the `homestation` age identity and the
administrator PGP recipient, so the administrator PGP key is the recovery path
when restoring AIO. Do not put the passphrase in Nix, the Nix store, shell
arguments, or logs.

This is recovery escrow only and is intentionally not mapped into `sops.nix`:
AIO keeps the operational passphrase in its own configuration and its
supported trigger does not accept a passphrase file.

`local-backup.service` invokes AIO's supported
`DAILY_BACKUP=1 /daily-backup.sh` trigger, waits for the Borg container to exit
successfully, and then invokes the `CHECK_BACKUP=1 /daily-backup.sh` trigger.
Although AIO's check trigger is asynchronous, the pipeline waits for its Borg
container to exit successfully. AIO performs its configured retention pruning
and compaction before the integrity check. Both operations must succeed before
the generic Restic stage begins. The pipeline verifies that AIO mounted
`/mnt/backup/nextcloud-borg` at `/mnt/borgbackup` and rejects an AIO remote Borg
configuration so a stale local repository cannot be replicated.

The complete pipeline holds `/run/local-backup/lock`; the OneDrive stage runs
inside that same lock after the local Restic stage. It does not read the AIO
repository until the AIO backup, compaction, and verification have succeeded.
The AIO mastercontainer is paused before Restic and repository replication, then
an `ExecStopPost` cleanup unpauses it on every service exit path. Nextcloud's
application containers remain running during this pause.

## Storage and recovery

The external `/mnt/backup` filesystem is mounted on demand with `nofail` and is
used by Beszel for capacity monitoring. Check it with:

```sh
findmnt /mnt/backup
df -h /mnt/backup
```

The local job is an application-data backup, not a tested restore workflow. The
manifest records the deliberate Obsidian LiveSync gap and the separate
Nextcloud Borg coverage. Before relying on recovery, restore a database dump,
an application-data snapshot, and an AIO Borg archive into an isolated location
and verify the relevant service startup procedure.
