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

`homestation` runs a root-owned local Restic job from the `local-backup` systemd
timer. The job runs daily at approximately 03:30, keeps seven daily, four weekly,
and twelve monthly snapshots, and stores the encrypted repository at
`/mnt/backup/restic/homestation`. The separate Nextcloud AIO Borg repository is
counted by the capacity gate but is not written by this job.

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

## Storage and recovery

The external `/mnt/backup` filesystem is mounted on demand with `nofail` and is
used by Beszel for capacity monitoring. Check it with:

```sh
findmnt /mnt/backup
df -h /mnt/backup
```

The local job is an application-data backup, not a tested restore workflow. The
manifest records the deliberate Obsidian LiveSync gap and the separate
Nextcloud Borg coverage. Before relying on recovery, restore a database dump and
an application-data snapshot into an isolated location and verify the relevant
service startup procedure.
