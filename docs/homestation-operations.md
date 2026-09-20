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

`homestation` uses Nixpkgs' root-owned `services.restic.backups` job. The local
job runs daily at approximately 03:30, keeps seven daily, four weekly, and
twelve monthly snapshots, and stores the encrypted repository at
`/mnt/backup/restic/homestation`. The explicit source, dump, and Docker-volume
lists are in `configurations/nixos/homestation/backup.nix`.

Run one complete backup manually and inspect its result:

```sh
sudo systemctl start restic-backups-local.service
systemctl status restic-backups-local.service
journalctl -u restic-backups-local.service --no-pager
```

The local unit requires the backup mount before Restic can initialize or access
the repository. Its prepare hook creates PostgreSQL logical dumps, briefly
stops the configured mutable-state services while copying them to staging, and
restarts services that were active. Its cleanup hook repeats those restarts and
retries the AIO unpause on every exit path. Staging is removed after the run; a
failed prepare, snapshot, retention, check, or offsite stage fails the systemd
unit.

### OneDrive offsite stage

After the local Restic snapshot, retention, and check complete successfully,
`restic-backups-local.service` starts the manual-only
`restic-backups-offsite.service` and waits for it. The offsite prepare hook uses
Restic's `copy` command to update an independent encrypted repository, then
mirrors the verified AIO Borg repository. The native Restic unit performs the
remote check and any explicitly enabled retention. Failure of either
replication or the remote check fails the local systemd unit.

The remote paths are deliberately separate:

```text
rclone:onedrive:homestation/restic
onedrive:homestation/nextcloud-aio-borg
```

The AIO `rclone sync` destination is only the second prefix, so it cannot delete
generic Restic objects or unrelated OneDrive content. The offsite service has no
timer and runs only while the local service owns the AIO pause marker.
If the remote Restic repository is absent, the first successful offsite stage
initializes it with the separate offsite password; an existing incompatible
repository fails rather than being reinitialized.

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

Remote pruning is initially disabled. Review the OneDrive quota and the remote
repository with the recovery commands before changing
`offsiteResticPrune = true` in `configurations/nixos/homestation/backup.nix`.
The evaluation assertion requires `offsiteRetentionReviewed = true` before
remote pruning can be enabled.

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
`restic-backups-local.timer` is the sole scheduler, and the service refuses to
run while the native schedule is enabled. Manual backup and restore operations
must not be started while `restic-backups-local.service` is active.

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

`restic-backups-local.service` invokes AIO's supported
`DAILY_BACKUP=1 /daily-backup.sh` trigger, waits for the Borg container to exit
successfully, and then invokes the `CHECK_BACKUP=1 /daily-backup.sh` trigger.
Although AIO's check trigger is asynchronous, the pipeline waits for its Borg
container to exit successfully. AIO performs its configured retention pruning
and compaction before the integrity check. Both operations must succeed before
the local Restic stage begins. The prepare hook verifies that AIO mounted
`/mnt/backup/nextcloud-borg` at `/mnt/borgbackup` and rejects an AIO remote Borg
configuration so a stale local repository cannot be replicated.

The AIO mastercontainer is paused after its backup and check, before the local
Restic snapshot and repository replication. Nixpkgs' cleanup hook retries the
unpause on every service exit path; an unpause failure fails the unit and needs
operator attention. Nextcloud's application containers remain running during
this pause.

## Storage and recovery

The external `/mnt/backup` filesystem is mounted on demand with `nofail` and is
used by Beszel for capacity monitoring. Check it with:

```sh
findmnt /mnt/backup
df -h /mnt/backup
```

The local job is an application-data backup, not a tested restore workflow. The
runbook records the deliberate Obsidian LiveSync gap and the separate Nextcloud
Borg coverage. Before relying on recovery, restore a database dump, an
application-data snapshot, and an AIO Borg archive into an isolated location
and verify the relevant service startup procedure.
