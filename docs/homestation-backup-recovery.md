# Homestation Backup And Recovery

This runbook is for `homestation`. Run host commands on `homestation`; run
repository and secret commands from `~/infrastructure` on a machine that has
the administrator GPG key when the host itself is unavailable.

The backup is application-data coverage, not a full machine image. Rebuild the
NixOS host and its container definitions from this repository first, then
restore only the service data that is needed. Generated Compose state, images,
logs, and caches are recreated rather than restored.

Restore drills are not automated and have not been performed. The repository
checks below are automated, but a successful check does not prove that a
service can be restored and started.

## Coverage And Retention

| Store | Local location | OneDrive location | Retention |
| --- | --- | --- | --- |
| Restic application data | `/mnt/backup/restic/homestation` | `rclone:onedrive:homestation/restic` | 7 daily, 4 weekly, 12 monthly |
| Nextcloud AIO Borg | `/mnt/backup/nextcloud-borg/borg` | `onedrive:homestation/nextcloud-aio-borg` | AIO's configured Borg policy; the OneDrive copy mirrors the local repository |

The local Restic repository uses the `restic-password` secret. The OneDrive
Restic repository is independent and uses `offsite-restic-password`; it cannot
be opened with the local password. The AIO Borg passphrase is configured in
the AIO interface and must be escrowed as `nextcloud-borg-passphrase` in the
encrypted host backup file before AIO recovery is considered covered. It is
not wired into Nix because AIO's supported trigger does not accept a passphrase
file.

The generated coverage manifest is the source of truth for application paths,
PostgreSQL dumps, runtime volumes, and deliberate exclusions:

```sh
sudo local-backup-manifest
```

Obsidian LiveSync is explicitly deferred. Its CouchDB state is not in either
backup repository and must not be presented as covered. Beszel history,
AdGuard state, Redis, temporary/model caches, logs, PostgreSQL data directories,
and generated container state are also outside the application-data snapshot
for the reasons shown in the manifest.

## Schedule And Checks

`local-backup.timer` runs every day at `03:30` with a randomized delay of up to
30 minutes and is persistent across downtime. One run holds
`/run/local-backup/lock` from preparation through OneDrive replication.

The daily pipeline runs in this order:

1. Nextcloud AIO performs its supported `DAILY_BACKUP=1` operation, including
   its configured retention and compaction.
2. The pipeline invokes AIO's `CHECK_BACKUP=1` operation and waits for the Borg
   container to exit successfully.
3. Local Restic creates a snapshot and applies the 7/4/12 retention policy.
4. Local Restic runs a structural `restic check`.
5. The independent OneDrive Restic repository receives copied snapshots,
   checks its own structure, reports its size, and applies the validated 7/4/12
   policy.
6. The verified local AIO Borg repository is mirrored to its isolated
   OneDrive prefix.

The pipeline is operator-visible through systemd. A failure in preparation,
capacity validation, either AIO operation, either Restic check, or either
OneDrive replication stage makes `local-backup.service` fail. Its
`OnFailure` unit writes a `daemon.err` journal message; this is logging, not a
pager or email notification.

Inspect the latest run and the failure alert on `homestation`:

```sh
systemctl list-timers local-backup.timer
systemctl status local-backup.service
journalctl -u local-backup.service -b --no-pager
journalctl -u local-backup-alert.service -b --no-pager
journalctl -t local-backup -p err..alert --since today --no-pager
```

Run the complete pipeline manually when investigating, rather than invoking a
sub-step that could bypass the lock:

```sh
sudo systemctl start local-backup.service
systemctl status local-backup.service
journalctl -u local-backup.service --no-pager
```

The automated Restic check is the normal structural check. A full pack-data
read is intentionally a manual operation because it can be much slower and
consume substantial local or OneDrive bandwidth:

```sh
nix shell nixpkgs#restic
RESTIC="$(command -v restic)"
```

Use the secret-recovery procedure below to run `"$RESTIC" check --read-data`
without putting a password in a command argument or terminal output.

## Mount And Failure Handling

The backup filesystem is an external ext4 filesystem mounted at
`/mnt/backup`. It uses `nofail` and systemd automount, but the backup service
still refuses to create staging or repository paths unless it is actually
mounted:

```sh
findmnt /mnt/backup
df -h /mnt/backup
```

The capacity gate accounts for the staged source data, the existing local
Restic repository, the AIO Borg repository, and a 1 GiB safety margin. It runs
before preparation and again after the AIO preparation step. A missing mount
or failed gate leaves the local Restic snapshot and its retention unchanged;
the service fails and the alert is logged. AIO may already have completed its
own backup and compaction before the second gate fails.

The local Restic snapshot and retention are completed before OneDrive work
starts. If the remote Restic copy, remote check, remote retention, rclone
connectivity, or AIO mirror fails, the local result remains available, the
service is failed, and the next run retries the remote stages. The AIO mirror
uses only `onedrive:homestation/nextcloud-aio-borg`; it cannot delete unrelated
OneDrive content.

Do not create `/mnt/backup/restic`, `/mnt/backup/nextcloud-borg`, or the
staging directory by hand on the root filesystem when the disk is unavailable.
Fix the mount first and rerun the service.

## Recover Repository Access

The encrypted file `secrets/hosts/homestation/backup.yaml` is encrypted for
the homestation age identity and the administrator PGP recipient declared in
`.sops.yaml`. After homestation loss, the administrator PGP key is the
recovery path for the Restic passwords and the escrowed AIO passphrase. The
administrator key must exist in the GPG keyring or an available GPG agent; a
repository copy without that key cannot decrypt the backup secrets.

From a trusted administrator workstation, verify decryption without printing
plaintext:

```sh
cd ~/infrastructure
sops decrypt --decryption-order pgp \
  --extract '["restic-password"]' \
  secrets/hosts/homestation/backup.yaml >/dev/null

sops decrypt --decryption-order pgp \
  --extract '["nextcloud-borg-passphrase"]' \
  secrets/hosts/homestation/backup.yaml >/dev/null
```

The second command is a required AIO recovery preflight. If it fails because
the key is absent, add the passphrase currently shown by AIO with `sops` while
the host is still available; do not mark the AIO repository recoverable until
the command succeeds.

Do not run the decrypt command by itself, paste a password into a shell
command, or commit a temporary decrypted file. The following helpers pipe the
selected value directly to Restic's password input. They never print the
selected value:

```sh
cd ~/infrastructure
nix shell nixpkgs#restic nixpkgs#sops
RESTIC="$(command -v restic)"
set -o pipefail

restic_local() {
  sops decrypt --decryption-order pgp --extract '["restic-password"]' \
    secrets/hosts/homestation/backup.yaml |
    sudo "$RESTIC" \
      --repo /mnt/backup/restic/homestation \
      --password-file /dev/stdin \
      "$@"
}

restic_local snapshots --tag local-application
```

For a complete local repository read, run this explicitly when the available
disk and maintenance window allow it:

```sh
restic_local check --read-data
```

For the offsite repository, use the separate key and make the runtime rclone
configuration available to the root Restic process. On an activated
homestation it is rendered at `/run/secrets/backup/onedrive-rclone-config`:

```sh
RCLONE_CONFIG=/run/secrets/backup/onedrive-rclone-config

restic_remote() {
  sops decrypt --decryption-order pgp --extract '["offsite-restic-password"]' \
    secrets/hosts/homestation/backup.yaml |
    sudo env RCLONE_CONFIG="$RCLONE_CONFIG" "$RESTIC" \
      --repo rclone:onedrive:homestation/restic \
      --password-file /dev/stdin \
      "$@"
}

restic_remote snapshots --tag local-application
```

For AIO, use the `nextcloud-borg-passphrase` value only in the AIO restore
interface. If it has not yet been added to the encrypted file, complete the
AIO setup and add it with the existing sops editor workflow before depending
on it for recovery:

```sh
sops secrets/hosts/homestation/backup.yaml
```

Keep the AIO passphrase out of Nix, the Nix store, shell arguments, logs, and
the repository. Close the editor without saving a plaintext copy after using
the value.

## Inspect And Extract Restic Data

List snapshots before choosing one. Prefer an explicit snapshot ID over
`latest` when restoring a database or service state:

```sh
restic_local snapshots --tag local-application
SNAPSHOT='snapshot-id-from-the-list'
restic_local ls --recursive "$SNAPSHOT" /var/lib/homelab
restic_local find --snapshot "$SNAPSHOT" 'postgres/*.sql.gz'
```

Restore selected content into an isolated directory first. The include path
must be copied from `restic ls` or `restic find`; do not restore the whole
repository over `/`:

```sh
RESTORE_ROOT="$(mktemp -d /var/tmp/homestation-restic.XXXXXX)"
INCLUDE_PATH='/var/lib/homelab/immich/library/**'
restic_local restore "$SNAPSHOT" \
  --target "$RESTORE_ROOT" \
  --include "$INCLUDE_PATH"
sudo find "$RESTORE_ROOT" -maxdepth 8 -type f -print
```

Sources whose services are stopped during backup are captured under the run's
staging directory rather than their live path. Use the manifest and the
snapshot listing to select the matching `source-*` tree, then restore its
contents to the service's target path below. Never infer a source number from
a different snapshot.

When the isolated copy is verified, remove it or keep it as evidence. Do not
leave restored secrets in `/var/tmp`:

```sh
sudo rm -rf -- "$RESTORE_ROOT"
```

## Restore PostgreSQL Services

The backup contains compressed logical dumps, not live PostgreSQL data
directories:

| Dump | Container | Database | User | Container password variable | Sops password path |
| --- | --- | --- | --- | --- | --- |
| AdventureLog | `adventurelog-db` | `database` | `adventure` | `POSTGRES_PASSWORD` | `/run/secrets/adventure-log/db-password` |
| AudioMuse-AI | `audiomuse-postgres` | `audiomusedb` | `audiomuse` | `POSTGRES_PASSWORD` | `/run/secrets/audiomuse-ai/db-password` |
| Ente | `ente-postgres` | `ente_db` | `pguser` | `POSTGRES_PASSWORD` | `/run/secrets/ente/db-password` |
| Immich | `immich_postgres` | `immich` | `postgres` | `DB_PASSWORD` | `/run/secrets/immich/db-password` |

Find and extract one dump into the isolated directory:

```sh
restic_local find --snapshot "$SNAPSHOT" '*.sql.gz'
DUMP_PATH='/mnt/backup/.local-backup-staging/<run>/postgres/immich.sql.gz'
restic_local restore "$SNAPSHOT" \
  --target "$RESTORE_ROOT" \
  --include "$DUMP_PATH"
DUMP_FILE="$RESTORE_ROOT$DUMP_PATH"
sudo gzip -t -- "$DUMP_FILE"
```

Before changing the live database, capture a rollback dump of its current
state. Stop only the application container that writes the selected database;
keep the database container running. The database containers already receive
the password through their environment file; setting `PGPASSWORD` inside the
container avoids putting the password in the host command line. Confirm the
container, database, user, and password variable against the table before
running these commands:

```sh
set -o pipefail
CURRENT_DUMP="$RESTORE_ROOT/current-immich.sql.gz"
if ! sudo docker exec -i immich_postgres sh -c \
  'PGPASSWORD="$DB_PASSWORD" pg_dump --clean --if-exists --no-owner --no-privileges --format=plain --username=postgres --dbname=immich' |
  gzip --stdout > "$CURRENT_DUMP"; then
  rm -f -- "$CURRENT_DUMP"
  printf 'could not capture the current database; aborting restore\n' >&2
  return 1 2>/dev/null || exit 1
fi
gzip -t -- "$CURRENT_DUMP"

sudo docker stop immich_server
if gzip --decompress --stdout -- "$DUMP_FILE" |
  sudo docker exec -i immich_postgres sh -c \
    'PGPASSWORD="$DB_PASSWORD" psql --username=postgres --dbname=immich --set=ON_ERROR_STOP=1'; then
  :
else
  printf 'restore failed; rolling the database back\n' >&2
  if ! gzip --decompress --stdout -- "$CURRENT_DUMP" |
    sudo docker exec -i immich_postgres sh -c \
      'PGPASSWORD="$DB_PASSWORD" psql --username=postgres --dbname=immich --set=ON_ERROR_STOP=1'; then
    printf 'rollback failed; leave immich_server stopped for investigation\n' >&2
    return 1 2>/dev/null || exit 1
  fi
  sudo docker start immich_server
  return 1 2>/dev/null || exit 1
fi
sudo docker start immich_server
```

The selected dump contains `--clean` and `--if-exists`, so the import replaces
that one database rather than adding to it. The rollback dump uses the same
options. A failed rollback requires database investigation before the
application is started; do not delete `CURRENT_DUMP` or the pre-restore
service data until the service is healthy.

If a rebuilt container does not contain the expected password variable, stop
and repair the sops-rendered environment rather than putting `PGPASSWORD` or
the password itself in a command argument, shell history, or log. Check the
service logs and application health before deleting the pre-restore database
or the isolated dump.

## Restore SQLite And Application Data

The following are the important service data targets. The systemd unit is the
unit to stop while replacing that target; the snapshot path may be a staged
`source-*` path, as described above.

| Service | Restore target | Unit |
| --- | --- | --- |
| Calibre-Web Automated | `/var/lib/homelab/calibre-web-automated/config` | `arion-calibre-web-automated.service` |
| Beets | `/var/lib/homelab/beets/config` | `arion-beets.service` |
| FreshRSS | `/var/lib/homelab/freshrss/data` and `extensions` | `arion-freshrss.service` |
| Navidrome | `/var/lib/homelab/navidrome/data` | `arion-navidrome.service` |
| Pocket ID | `/var/lib/homelab/pocket-id/data` | `arion-pocket-id.service` |
| Prowlarr | `/var/lib/homelab/prowlarr/data` | `arion-prowlarr.service` |
| RdtClient | `/var/lib/homelab/rdtclient/db` | `arion-rdtclient.service` |
| Shelfmark | `/var/lib/homelab/shelfmark/config` | `arion-shelfmark.service` |
| Vaultwarden | `/var/lib/homelab/vaultwarden/data` | `arion-vaultwarden.service` |
| Vikunja | `/var/lib/homelab/vikunja/db` and `files` | `arion-vikunja.service` |
| Wealthfolio | `/var/lib/homelab/wealthfolio/data` | `arion-wealthfolio.service` |
| Yamtrack | `/var/lib/homelab/yamtrack/db` | `arion-yamtrack.service` |

For one selected target, restore to `RESTORE_ROOT`, stop only its unit, move
the current target aside, and move the verified restored directory into place:

```sh
TARGET='/var/lib/homelab/navidrome/data'
UNIT='arion-navidrome.service'
RESTORED_PATH="$RESTORE_ROOT/<path-restored-from-the-snapshot>"
PREVIOUS="${TARGET}.before-restore.$(date -u +%Y%m%dT%H%M%SZ)"

sudo systemctl stop "$UNIT"
if sudo test -e "$TARGET"; then
  sudo mv -- "$TARGET" "$PREVIOUS"
fi
sudo install -d -m 0755 -- "$(dirname "$TARGET")"
sudo mv -- "$RESTORED_PATH" "$TARGET"
sudo systemctl start "$UNIT"
systemctl status "$UNIT"
```

This procedure changes one service directory only. Do not move or restore the
whole `/var/lib/homelab` tree, and keep the `*.before-restore.*` directory until
the service has been verified. Shared libraries such as the music and book
libraries must be restored separately and must not be used to replace another
service's configuration.

## Restore Nextcloud AIO

Use AIO's supported **Backup and restore** workflow rather than running
`borg extract` against the live AIO containers. The upstream AIO migration
instructions are at [How to migrate from AIO to AIO](https://github.com/nextcloud/all-in-one#how-to-migrate-from-aio-to-aio).

For a local restore, make sure the configured AIO backup directory is present
and contains the Borg repository:

```sh
findmnt /mnt/backup
sudo test -f /mnt/backup/nextcloud-borg/borg/config
```

For a OneDrive-only recovery, restore only the AIO prefix into the local AIO
backup directory. Use an activated host's root-readable rclone configuration;
do not put the OAuth token in this document or in a command argument:

```sh
nix shell nixpkgs#rclone
RCLONE="$(command -v rclone)"
RCLONE_CONFIG=/run/secrets/backup/onedrive-rclone-config
sudo install -d -m 0700 /mnt/backup/nextcloud-borg/borg
sudo env RCLONE_CONFIG="$RCLONE_CONFIG" "$RCLONE" copy \
  onedrive:homestation/nextcloud-aio-borg \
  /mnt/backup/nextcloud-borg/borg
sudo env RCLONE_CONFIG="$RCLONE_CONFIG" "$RCLONE" lsf \
  onedrive:homestation/nextcloud-aio-borg/config
sudo test -f /mnt/backup/nextcloud-borg/borg/config
```

Open the AIO interface, select its **Backup and restore** page, point it at
`/mnt/backup/nextcloud-borg`, provide the escrowed AIO passphrase, and follow
the supported restore flow. This restores Nextcloud through AIO without
replacing unrelated Arion services or their data. Start and verify the
Nextcloud service before removing any pre-restore AIO state.

After any recovery, re-enable the timer and run a complete backup only after
the restored service is healthy:

```sh
sudo systemctl start local-backup.timer
sudo systemctl start local-backup.service
systemctl status local-backup.service
```
