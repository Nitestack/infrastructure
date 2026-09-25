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
| Restic application data | `/mnt/backup/restic/homestation` | `rclone:onedrive:backups/homestation/restic` | Local: 7 daily, 4 weekly, 12 monthly. Remote: copied and checked; pruning disabled by default |
| Nextcloud AIO Borg | `/mnt/backup/borg` | `onedrive:backups/homestation/nextcloud-aio-borg` | AIO's configured Borg policy; the OneDrive copy mirrors the local repository |

The local Restic repository uses the `restic-password` secret. The OneDrive
Restic repository is independent and uses `offsite-restic-password`; it cannot
be opened with the local password. The AIO Borg passphrase is configured in
the AIO interface and must be escrowed as `nextcloud-borg-passphrase` in the
encrypted host backup file before AIO recovery is considered covered. It is
not wired into Nix because AIO's supported trigger does not accept a passphrase
file.

The explicit coverage lists in
`configurations/nixos/homestation/backup.nix` are the source of truth for
application paths, PostgreSQL dumps, and runtime volumes. The local job stages
mutable sources below `/mnt/backup/.local-backup-staging` for the snapshot and
removes that staging data during cleanup.

Obsidian LiveSync is explicitly deferred. Its CouchDB state is not in either
backup repository and must not be presented as covered. Beszel history,
AdGuard state, Redis, temporary/model caches, logs, PostgreSQL data directories,
and generated container state are also outside the application-data snapshot
for the reasons documented in this runbook.

## Schedule And Checks

`restic-backups-local.timer` runs every day at `03:30` with a randomized delay
of up to 30 minutes and is persistent across downtime. The offsite unit has no
timer; the local unit starts it synchronously after the local Restic work.

The daily pipeline runs in this order:

1. Nextcloud AIO performs its supported `DAILY_BACKUP=1` operation, including
   its configured retention and compaction.
2. The pipeline invokes AIO's `CHECK_BACKUP=1` operation and waits for the Borg
   container to exit successfully.
3. Nixpkgs' local Restic unit creates a snapshot, applies the 7/4/12 retention
   policy, and runs a structural `restic check`.
4. The offsite prepare hook uses Restic's native `copy` command to update the
   independent OneDrive Restic repository.
5. Nixpkgs' offsite Restic unit runs its native remote repository check and
   prunes only when the explicit host retention-review switch is enabled.
6. Its post-start hook mirrors the verified local AIO Borg repository to its
   isolated OneDrive prefix.

The pipeline is operator-visible through systemd. A failure in preparation,
either AIO operation, either Restic check, or either OneDrive replication stage
makes `restic-backups-local.service` fail. The native Restic service status and
journal are the failure signal; there is no custom alerting layer.

Inspect the latest run and its failure journal on `homestation`:

```sh
systemctl list-timers restic-backups-local.timer
systemctl status restic-backups-local.service
journalctl -u restic-backups-local.service -b --no-pager
journalctl -u restic-backups-offsite.service -b --no-pager
```

Run the complete pipeline manually when investigating, rather than invoking a
preparation or replication hook by hand:

```sh
sudo systemctl start restic-backups-local.service
systemctl status restic-backups-local.service
journalctl -u restic-backups-local.service --no-pager
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

## Set Up Or Reconfigure The OneDrive Remote

The offsite job requires a remote named exactly `onedrive`. It first runs
`rclone lsd onedrive:`; on success, the local service continues with the remote
Restic copy and check, then mirrors the AIO Borg repository. These steps are
defined in [`backup.nix`](../configurations/nixos/homestation/backup.nix).

Run this from `~/infrastructure` on `homestation` when repairing the live host,
or from a trusted administrator workstation for a first deployment. Use the
rclone package declared by the `homestation` flake output so the saved
configuration is accepted by the deployed version. Create a private, temporary
config and run the interactive wizard against it; `--config` keeps rclone from
writing to its default user config location ([rclone config-file docs](https://rclone.org/docs/#config-config-file)):

```sh
cd ~/infrastructure
RCLONE_STORE="$(
  nix build --quiet --no-link --no-write-lock-file --print-out-paths \
    .#nixosConfigurations.homestation.pkgs.rclone |
    while IFS= read -r candidate; do
      if test -x "$candidate/bin/rclone"; then
        printf '%s\n' "$candidate"
      fi
    done |
    head -n 1
)"
test -n "$RCLONE_STORE"
RCLONE="$RCLONE_STORE/bin/rclone"
test -x "$RCLONE"
"$RCLONE" --version

umask 077
: "${XDG_RUNTIME_DIR:?use a homestation login session with a private runtime directory}"
RCLONE_CONFIG="$(mktemp "$XDG_RUNTIME_DIR/onedrive-rclone-config.XXXXXX")"
cleanup() {
  if test -n "${RCLONE_CONFIG:-}"; then
    rm -f -- "$RCLONE_CONFIG"
  fi
}
trap cleanup EXIT HUP INT TERM
"$RCLONE" --config "$RCLONE_CONFIG" config
```

Keep this shell open until the temporary config has been copied into the SOPS
editor. The exit trap removes it if setup is abandoned.

In the wizard, create a OneDrive remote named `onedrive`, authenticate to the
intended Microsoft account, and accept the drive selected by the wizard. The
official [OneDrive configuration guide](https://rclone.org/onedrive/#configuration)
documents the browser authentication and drive-selection flow; its generated
configuration includes the OAuth token and the selected `drive_id` and
`drive_type`. The wizard may show a config summary containing the token, so use
a private terminal with session recording disabled. Never record or share that
summary, and do not deliberately print the config with `cat` or `rclone config
show`/`dump`, or put it in shell arguments, logs, or chat. For a headless
session, follow rclone's
[remote setup guide](https://rclone.org/remote_setup/) rather than copying a
token through an untrusted channel.

Validate the new config with the same read-only root listing the service uses:

```sh
"$RCLONE" --config "$RCLONE_CONFIG" lsd onedrive: >/dev/null
```

If this fails, do not replace the encrypted value yet. For the current
`unable to get drive_id and drive_type` error, re-run the wizard with the
deployed rclone version and select the intended drive there; do not guess or
hand-write drive IDs or types. Stop if the intended drive cannot be identified.

When validation succeeds, edit the existing encrypted host file:

```sh
sops secrets/hosts/homestation/backup.yaml
```

Replace only `onedrive-rclone-config` with the complete temporary config as a
YAML literal block (`onedrive-rclone-config: |`, with each rclone line indented
under it). Use the editor's file-insert function so the config is not emitted as
shell output. The secret is rendered by
[`sops.nix`](../configurations/nixos/homestation/sops.nix) as
`/run/secrets/backup/onedrive-rclone-config` with mode `0400`; never put the
plaintext in Nix, the Nix store, or Git. After saving the encrypted file, remove
the temporary config:

```sh
rm -f -- "$RCLONE_CONFIG"
```

Review the encrypted diff from the repository checkout:

```sh
git diff --check
git diff -- secrets/hosts/homestation/backup.yaml
nix run .#check
```

Make the encrypted file available in the deployment checkout. For an existing
installation, activate the updated secret on `homestation`:

```sh
sudo nixos-rebuild switch --flake .#homestation
```

For a first deployment, include the encrypted file before the initial
`homestation` system activation. Follow the repository's first-install workflow
for the initial `boot`; do not copy the plaintext rclone config to the host.

After activation, use the active system's rclone package again and validate the
rendered runtime config as root. This mirrors the offsite prepare hook's
`rclone lsd` preflight without changing OneDrive data:

```sh
RCLONE_STORE="$(
  nix build --quiet --no-link --no-write-lock-file --print-out-paths \
    .#nixosConfigurations.homestation.pkgs.rclone |
    while IFS= read -r candidate; do
      if test -x "$candidate/bin/rclone"; then
        printf '%s\n' "$candidate"
      fi
    done |
    head -n 1
)"
test -n "$RCLONE_STORE"
RCLONE="$RCLONE_STORE/bin/rclone"
test -x "$RCLONE"
sudo "$RCLONE" --config /run/secrets/backup/onedrive-rclone-config \
  lsd onedrive: >/dev/null
```

If that succeeds, rerun and inspect the **full** pipeline through the local
service; it owns the offsite stage and its AIO pause lifecycle. Do not start the
offsite unit directly:

```sh
sudo systemctl start restic-backups-local.service
systemctl status restic-backups-local.service
journalctl -u restic-backups-local.service -u restic-backups-offsite.service \
  --no-pager
```

## Mount And Failure Handling

The backup filesystem is an external ext4 filesystem mounted at
`/mnt/backup`. It uses `nofail` and systemd automount, but the backup service
still refuses to initialize or access the repository unless it is actually
mounted:

```sh
findmnt /mnt/backup
df -h /mnt/backup
```

Preparation staging is kept in `/mnt/backup/.local-backup-staging` and is
removed after each run. There is deliberately no custom capacity gate: a full
local filesystem or repository makes the native Restic unit fail, while cleanup
still retries any pending service restarts and unpauses AIO.

The AIO native daily schedule must remain disabled because
`restic-backups-local.timer` is the scheduling authority. After AIO backup and
integrity checks complete, the prepare hook verifies AIO's actual
`/mnt/borgbackup` host mount and pauses the mastercontainer while Restic and
OneDrive work run. The native Restic cleanup hook retries the unpause whether
the service succeeds, fails, or times out; an unpause failure fails the unit and
requires operator attention. The complete services have a 24-hour timeout, and
each AIO Borg operation has an eight-hour deadline plus a one-minute
forced-termination grace period, so a stuck container eventually fails visibly.

The local Restic snapshot and retention are completed before OneDrive work
starts. If the remote Restic copy, remote check, remote retention, rclone
connectivity, or AIO mirror fails, the local result remains available, the
service is failed, and the next run retries the remote stages. The AIO mirror
uses only `onedrive:backups/homestation/nextcloud-aio-borg`; it cannot delete unrelated
OneDrive content.

Do not create `/mnt/backup/restic` or `/mnt/backup/borg` by hand on the root
filesystem when the disk is unavailable. Fix the mount first and rerun the
service.

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
      --repo rclone:onedrive:backups/homestation/restic \
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
staging directory rather than their live path. Current snapshots use stable,
semantic names under `sources/`; source-list reordering does not change those
names. Use the table below and the snapshot listing to select the matching
tree, then restore its contents to the service's target path. Snapshots from
the first version of this configuration used positional names; their fixed
mapping is retained here so those snapshots remain understandable:

| Legacy name | Source |
| --- | --- |
| `source-0` | Caddy `data` |
| `source-1` | Caddy `config` |
| `source-2` | Calibre-Web Automated `config` |
| `source-3` | Calibre-Web Automated `plugins` |
| `source-4` | Beets `config` |
| `source-5` | FreshRSS `data` |
| `source-6` | FreshRSS `extensions` |
| `source-7` | Navidrome `data` |
| `source-8` | Pocket ID `data` |
| `source-9` | Prowlarr `data` |
| `source-10` | RdtClient `db` |
| `source-11` | Shelfmark `config` |
| `source-12` | Vaultwarden `data` |
| `source-13` | Vikunja `db` |
| `source-14` | Wealthfolio `data` |
| `source-15` | Retired media-tracker `db` |

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
DUMP_PATH='/mnt/backup/.local-backup-staging/postgres/immich.sql.gz'
restic_local restore "$SNAPSHOT" \
  --target "$RESTORE_ROOT" \
  --include "$DUMP_PATH"
DUMP_FILE="$RESTORE_ROOT$DUMP_PATH"
if ! sudo gzip -t -- "$DUMP_FILE"; then
  printf 'selected backup dump is invalid; aborting restore\n' >&2
  return 1 2>/dev/null || exit 1
fi
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
if ! gzip -t -- "$CURRENT_DUMP"; then
  printf 'rollback dump is invalid; aborting restore\n' >&2
  return 1 2>/dev/null || exit 1
fi

if ! sudo docker stop immich_server; then
  printf 'could not stop immich_server; aborting restore\n' >&2
  return 1 2>/dev/null || exit 1
fi
if sudo gzip --decompress --stdout -- "$DUMP_FILE" |
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
  if ! sudo docker start immich_server; then
    printf 'rollback succeeded but immich_server could not be started\n' >&2
  fi
  return 1 2>/dev/null || exit 1
fi
if ! sudo docker start immich_server; then
  printf 'restore completed but immich_server could not be started\n' >&2
  return 1 2>/dev/null || exit 1
fi
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
`sources/<stable-name>` path, or a legacy `source-*` path for an older snapshot,
as described above.

| Service/data | Stable staged name | Restore target | Unit |
| --- | --- | --- | --- |
| Caddy data | `caddy-data` | `/var/lib/homelab/caddy/data` | `docker-caddy.service` |
| Caddy config | `caddy-config` | `/var/lib/homelab/caddy/config` | `docker-caddy.service` |
| Calibre-Web Automated config | `calibre-web-automated-config` | `/var/lib/homelab/calibre-web-automated/config` | `arion-calibre-web-automated.service` |
| Calibre-Web Automated plugins | `calibre-web-automated-plugins` | `/var/lib/homelab/calibre-web-automated/plugins` | `arion-calibre-web-automated.service` |
| Beets config | `beets-config` | `/var/lib/homelab/beets/config` | `arion-beets.service` |
| FreshRSS data | `freshrss-data` | `/var/lib/homelab/freshrss/data` | `arion-freshrss.service` |
| FreshRSS extensions | `freshrss-extensions` | `/var/lib/homelab/freshrss/extensions` | `arion-freshrss.service` |
| Navidrome data | `navidrome-data` | `/var/lib/homelab/navidrome/data` | `arion-navidrome.service` |
| Pocket ID data | `pocket-id-data` | `/var/lib/homelab/pocket-id/data` | `arion-pocket-id.service` |
| Prowlarr data | `prowlarr-data` | `/var/lib/homelab/prowlarr/data` | `arion-prowlarr.service` |
| RdtClient database | `rdtclient-db` | `/var/lib/homelab/rdtclient/db` | `arion-rdtclient.service` |
| Shelfmark config | `shelfmark-config` | `/var/lib/homelab/shelfmark/config` | `arion-shelfmark.service` |
| Vaultwarden data | `vaultwarden-data` | `/var/lib/homelab/vaultwarden/data` | `arion-vaultwarden.service` |
| Vikunja database | `vikunja-db` | `/var/lib/homelab/vikunja/db` | `arion-vikunja.service` |
| Wealthfolio data | `wealthfolio-data` | `/var/lib/homelab/wealthfolio/data` | `arion-wealthfolio.service` |
| Floppy database | `floppy-db` | `/var/lib/homelab/floppy/db` | `arion-floppy.service` |
| Floppy backups | `floppy-backups` | `/var/lib/homelab/floppy/backups` | `arion-floppy.service` |

For one selected target, restore to `RESTORE_ROOT`, stop only its unit, move
the current target aside, and move the verified restored directory into place:

```sh
restore_application_data() {
  local target='/var/lib/homelab/navidrome/data'
  local unit='arion-navidrome.service'
  local restored_path="$RESTORE_ROOT/<path-restored-from-the-snapshot>"
  local timestamp
  local previous
  local candidate
  local failed_restore
  local had_previous=false

  timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
  previous="${target}.before-restore.${timestamp}"
  candidate="${target}.restore-candidate.${timestamp}"
  failed_restore="${target}.failed-restore.${timestamp}"

  if ! sudo test -e "$restored_path"; then
    printf 'restored data is missing; aborting before service stop\n' >&2
    return 1
  fi
  if sudo test -e "$candidate"; then
    printf 'restore candidate already exists: %s\n' "$candidate" >&2
    return 1
  fi
  if ! sudo install -d -m 0755 -- "$(dirname "$target")" ||
    ! sudo cp -a -- "$restored_path" "$candidate"; then
    sudo rm -rf -- "$candidate"
    printf 'could not stage restored data; aborting before service stop\n' >&2
    return 1
  fi
  if ! sudo systemctl stop "$unit"; then
    sudo rm -rf -- "$candidate"
    printf 'could not stop %s; live data is unchanged\n' "$unit" >&2
    return 1
  fi
  if sudo test -e "$target"; then
    if ! sudo mv -- "$target" "$previous"; then
      sudo rm -rf -- "$candidate"
      sudo systemctl start "$unit" || true
      printf 'could not preserve live data; restore aborted\n' >&2
      return 1
    fi
    had_previous=true
  fi
  if ! sudo mv -- "$candidate" "$target"; then
    printf 'could not install restored data; attempting rollback\n' >&2
    if [[ "$had_previous" == "true" ]] && sudo mv -- "$previous" "$target"; then
      sudo systemctl start "$unit" || true
    else
      printf 'rollback unavailable or failed; leave %s stopped\n' "$unit" >&2
    fi
    return 1
  fi
  if ! sudo systemctl start "$unit"; then
    printf 'restored data failed to start; attempting rollback\n' >&2
    sudo systemctl stop "$unit" || true
    if [[ "$had_previous" == "true" ]] &&
      sudo mv -- "$target" "$failed_restore" &&
      sudo mv -- "$previous" "$target"; then
      if ! sudo systemctl start "$unit"; then
        printf 'previous data was restored but %s still failed to start\n' "$unit" >&2
      fi
    else
      printf 'rollback unavailable or failed; leave %s stopped\n' "$unit" >&2
    fi
    return 1
  fi
  systemctl status "$unit"
}

restore_application_data
```

This procedure stages the restored directory beside the target before stopping
the service, so the final replacement is on one filesystem and can be rolled
back. It changes one service directory only. Do not move or restore the whole
`/var/lib/homelab` tree, and keep the `*.before-restore.*` directory until the
service has been verified. Shared libraries such as the music and book
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
sudo test -f /mnt/backup/borg/config
```

For a OneDrive-only recovery, restore only the AIO prefix into the local AIO
backup directory. Use an activated host's root-readable rclone configuration;
do not put the OAuth token in this document or in a command argument:

```sh
nix shell nixpkgs#rclone
RCLONE="$(command -v rclone)"
RCLONE_CONFIG=/run/secrets/backup/onedrive-rclone-config
sudo install -d -m 0700 /mnt/backup/borg
sudo env RCLONE_CONFIG="$RCLONE_CONFIG" "$RCLONE" copy \
  onedrive:backups/homestation/nextcloud-aio-borg \
  /mnt/backup/borg
sudo env RCLONE_CONFIG="$RCLONE_CONFIG" "$RCLONE" lsf \
  onedrive:backups/homestation/nextcloud-aio-borg/config
sudo test -f /mnt/backup/borg/config
```

Open the AIO interface, select its **Backup and restore** page, point it at
`/mnt/backup`, provide the escrowed AIO passphrase, and follow
the supported restore flow. This restores Nextcloud through AIO without
replacing unrelated Arion services or their data. Start and verify the
Nextcloud service before removing any pre-restore AIO state.

After recovery, disable AIO's native daily backup schedule again before
re-enabling `restic-backups-local.timer`; overlapping schedulers are rejected by
the prepare hook.

After any recovery, re-enable the timer and run a complete backup only after
the restored service is healthy:

```sh
sudo systemctl start restic-backups-local.timer
sudo systemctl start restic-backups-local.service
systemctl status restic-backups-local.service
```
