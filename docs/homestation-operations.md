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

## Storage and recovery

The external `/mnt/backup` filesystem is mounted on demand with `nofail` and is
used by Beszel for capacity monitoring. Check it with:

```sh
findmnt /mnt/backup
df -h /mnt/backup
```

This repository does **not** currently configure a backup job or a tested
restore workflow. The mount is not evidence that application data is backed up.
Before relying on it for recovery, choose a backup tool, define which bind
mounts and named volumes it covers, document retention and off-site copies, and
test restoring an application into an isolated location.

Until then, treat the Nix configuration as reproducible but application data as
state requiring a separate recovery plan.
