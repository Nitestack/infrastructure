# Homelab Service Module

The `homestation-homelab` module exposes a service-oriented API for declaring
homelab apps, their container workloads, and app-level ingress rules.

Module source: `modules/nixos/homestation-homelab/`

This document reflects the public option schema defined in
`modules/nixos/homestation-homelab/options.nix`.

---

## Quick Start

```nix
homestation.homelab = {
  enable = true;
  domain = "example.com";
  lanAddress = "192.168.1.10";

  apps.paperless = {
    expose = {
      mode = "private";
      host = "paperless";
      service = "web";
      protocol = "http";
    };

    services.web = {
      enable = true;
      image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
      port = 8000;
      volumes = [
        {
          type = "bind";
          source = "data";
          target = "/usr/src/paperless/data";
        }
      ];
    };
  };
};
```

---

## Conceptual Model

```text
homestation.homelab
`-- apps
    `-- <appName>
        |-- expose
        |-- routes
        `-- services
            `-- <serviceName>
```

- An **app** is the public unit of configuration.
- An app can define one or more **services** under `services.<name>`.
- App-level `expose` selects whether the app is private, public, or internal.
- App-level `routes` describe how inbound traffic reaches services.
- Each service maps closely to one Arion/Docker Compose service stanza.

`services` is the only supported workload form. The temporary
`apps.<app>.container` and `apps.<app>.containers` compatibility paths were
removed.

---

## Global Options (`homestation.homelab.*`)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Master switch for the module |
| `domain` | string\|null | `null` | Base domain used for host derivation |
| `lanAddress` | string\|null | `null` | LAN IP used for generated LAN DNS A records for exposed apps |
| `dataDir` | string | `"/var/lib/homelab"` | Base directory for persistent app data |
| `network.prefix` | string | `"homelab"` | Prefix for Arion project names (`<prefix>-<appName>`) and the per-app Docker networks those projects create |
| `edgeNetwork.name` | string | `"homelab-edge"` | Name of the external Docker network Caddy is attached to. Services are automatically joined to this network when they are an upstream for an exposed app |
| `logging.driver` | string\|null | `null` | Default logging driver for every service. Set to `"journald"` on NixOS for host-managed log rotation. Per-service override via `extraServiceConfig.logging` |
| `logging.options` | attrs of string | `{}` | Driver-specific options (e.g. `max-size`, `max-file` for `json-file`). Ignored when `logging.driver` is null |
| `libraries` | attrs of libraryType | `{}` | Named shared host paths mountable from services |
| `apps` | attrs of appType | `{}` | App definitions |
| `dns.records` | attrs of dnsRecordType | `{}` | Extra manual DNS records |

When native `services.adguardhome.enable = true` is also set on the host, all
LAN-visible records from `homestation.homelab.dns.records` are rendered into
AdGuard Home `filtering.rewrites` automatically.

### `cloudflared.*`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `cloudflared.enable` | bool | `true` | Enable Cloudflare tunnel integration |
| `cloudflared.tunnelId` | string\|null | `null` | Tunnel UUID |
| `cloudflared.wildcardIngress` | bool | auto | Auto-enabled when any app uses `expose.mode = "public"`; set to `false` to override |

### `caddy.*`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `caddy.enable` | bool | `true` | Enable generated Caddy integration |
| `caddy.enableWithoutServices` | bool | `false` | Run Caddy even with no routed services |
| `caddy.image` | string | `"caddy:latest"` | Caddy image |
| `caddy.ports` | list of string | `["80:80" "443:443" "443:443/udp"]` | Port mappings for Caddy |
| `caddy.openFirewall` | bool | `true` | Open firewall for Caddy ports |
| `caddy.environment` | attrs of string | `{}` | Environment variables for Caddy |
| `caddy.environmentFiles` | list of path | `[]` | Environment files for Caddy |
| `caddy.globalConfig` | lines | `""` | Content prepended to the generated Caddyfile |
| `caddy.extraSiteBlocks` | lines | `""` | Extra site blocks appended after generated virtual hosts in the Caddyfile |
| `caddy.extraVolumes` | list of string | `[]` | Extra volume mounts for Caddy |

### `smtp.*`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `smtp.host` | string\|null | `null` | Shared SMTP host |
| `smtp.port` | int\|null | `null` | Shared SMTP port |
| `smtp.security` | enum | `"starttls"` | Shared SMTP mode: `"starttls"`, `"force_tls"`, or `"off"` |
| `smtp.from` | string\|null | `null` | Default sender address |
| `smtp.username` | string\|null | `null` | Shared SMTP username |

These are a shared reference registry — the module does not inject SMTP values into service environments automatically. Each app that needs SMTP must wire the values itself, for example:

```nix
services.web.environment = {
  SMTP_HOST = config.homestation.homelab.smtp.host;
  SMTP_PORT = toString config.homestation.homelab.smtp.port;
};
```

Keep passwords out of `environment`; pass them via `environmentFiles` instead.

### `libraries.<name>.*`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `path` | string | none | Absolute host path |
| `create` | bool | `false` | Create the path via tmpfiles |
| `user` | string | `"root"` | Owner when `create = true` |
| `group` | string | `"root"` | Group when `create = true` |
| `mode` | string | `"0755"` | Permissions when `create = true` |

### `dns.records.<name>.*`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `type` | enum | `"A"` | DNS record type: `"A"`, `"AAAA"`, or `"CNAME"` |
| `value` | string | none | DNS record value |
| `visibility` | enum | `"lan"` | Record visibility: `"lan"` or `"public"` |

---

## App Options (`apps.<app>.*`)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `true` | Enable or disable the app |
| `expose.mode` | enum | `"none"` | Exposure mode: `"none"`, `"private"`, or `"public"` |
| `expose.host` | string\|null | `null` | Hostname or subdomain for the app |
| `expose.service` | string\|null | auto | Default upstream target; auto-derived when the app has exactly one service |
| `expose.protocol` | enum | `"http"` | Protocol Caddy uses when proxying *to* the container (backend leg only — Caddy always terminates TLS publicly). Use `"https"` only when the container itself speaks TLS; `"http"` covers nearly all homelab services |
| `routes` | list of routeType | `[]` | Ordered ingress routes for the app. When empty, a catch-all route is auto-derived from `expose.service` |
| `services` | attrs of serviceType | `{}` | Workloads that belong to the app |

### App Exposure

- `mode = "none"` keeps the app internal.
- `mode = "private"` is for LAN-only ingress.
- `mode = "public"` is for internet-facing ingress.
- `host = null` means the app has no hostname.
- `service` should name a member of `services`. When the app has exactly one service, `expose.service` is auto-derived and can be omitted.
- When `routes` is empty, a single catch-all route is generated automatically from `expose.service`. Declare `routes` explicitly only when you need path matchers, multiple upstreams, or per-route proxy settings.

**Host resolution:** A plain label is expanded to `<host>.<domain>` (e.g. `host = "paperless"` with `domain = "home.example.com"` yields `paperless.home.example.com`). If `host` already contains a `.` it is used as a fully-qualified domain name without modification. The special value `"@"` resolves to the bare `domain`, useful for apex-domain services.

### App Routes (`apps.<app>.routes`)

Each route can refine matching and upstream behavior:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `match.path` | list of string | `[]` | Path matchers |
| `match.not.path` | list of string | `[]` | Excluded path matchers |
| `upstream.service` | string\|null | `null` | Service selected for this route |
| `proxy.headers.request` | attrs of string | `{}` | Request headers to set on the proxy |
| `proxy.transport.http` | attrs of bool | `{}` | HTTP transport flags |
| `requestBody.maxSize` | string\|null | `null` | Max request body size |
| `encode` | list of string | `[]` | Encoders to enable |
| `extraConfig` | lines | `""` | Extra route-level config |

---

## Service Options (`apps.<app>.services.<service>.*`)

### Basic

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable the service |
| `containerName` | string\|null | `null` | Override the generated container name. Only set when a container requires a fixed externally-known name (e.g. Nextcloud AIO). User-specified names are included in the global uniqueness check |
| `image` | string | none | Container image |
| `port` | int\|null | `null` | Primary service port |
| `command` | list of string\|null | `null` | Override the service command |
| `entrypoint` | string\|null | `null` | Override the service entrypoint |
| `environment` | attrs of string | `{}` | Environment variables |
| `helpers.linuxserver` | bool | `false` | Inject LinuxServer-style defaults: `PUID`, `PGID`, and `TZ` |
| `helpers.identity` | bool | `false` | Inject `PUID` and `PGID` derived from the host's primary user defaults |
| `helpers.timezone` | bool | `false` | Inject `TZ` from `config.time.timeZone` |
| `environmentFiles` | list of path | `[]` | Environment files |
| `volumes` | list of volumeType | `[]` | Volume mounts |
| `ports` | list of string | `[]` | Published Docker/Arion ports |
| `networks` | list of string | `[]` | Additional Docker networks |
| `restart` | enum | `"unless-stopped"` | Container restart policy |
| `labels` | attrs of string | `{}` | Container labels |
| `extraServiceConfig` | attrs | `{}` | Raw attrs merged last into the Arion service definition. Escape hatch for compose options not covered by the typed API (e.g. `security_opt`). Values here override typed options |

### Helpers

`helpers` is a typed convenience layer for common container environment defaults:

- `helpers.linuxserver = true` injects `PUID`, `PGID`, and `TZ`
- `helpers.identity = true` injects `PUID` and `PGID`
- `helpers.timezone = true` injects `TZ`

These toggles are additive only. If multiple helpers are enabled, their values
are unioned together. Explicit values in `environment` still win on key
conflicts, which keeps the helper API simple while preserving a manual escape
hatch.

Injected values come from the host:

- `PUID` uses `config.users.users.${config.meta.username}.uid`, falling back to `"1000"` when unset
- `PGID` uses `config.ids.gids.users`
- `TZ` uses `config.time.timeZone`

```nix
services.web.helpers.identity = true;    # PUID + PGID
services.web.helpers.timezone = true;    # TZ only
services.web.helpers.linuxserver = true; # PUID + PGID + TZ
```

### Healthcheck

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `healthcheck.test` | list of string\|null | `null` | Healthcheck command |
| `healthcheck.interval` | string\|null | `null` | Healthcheck interval |
| `healthcheck.timeout` | string\|null | `null` | Healthcheck timeout |
| `healthcheck.retries` | int\|null | `null` | Retry count |
| `healthcheck.startPeriod` | string\|null | `null` | Startup grace period |

### Dependencies

`dependsOn` is an attribute set keyed by dependency service name.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `dependsOn` | attrs of submodule | `{}` | Dependency map |
| `dependsOn.<service>.condition` | enum | `"service_started"` | Dependency condition |

Allowed `condition` values:

- `"service_started"`
- `"service_healthy"`
- `"service_completed_successfully"`

Because `condition` defaults to `"service_started"`, you can omit it when that condition is sufficient:

```nix
dependsOn.redis = {};          # equivalent to dependsOn.redis.condition = "service_started"
dependsOn.db.condition = "service_healthy";
```

### Runtime

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `runtime.user` | string\|null | `null` | Container user |

For other runtime options (`working_dir`, `tmpfs`, `tty`, `init`, `stop_grace_period`, `stop_signal`, etc.) use `extraServiceConfig`.

### Privileges

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `privileges.networkMode` | string\|null | `null` | Docker network mode |
| `privileges.privileged` | bool | `false` | Run as privileged |
| `privileges.devices` | list of string | `[]` | Extra device mappings |
| `privileges.capabilities.add` | list of string | `[]` | Added Linux capabilities |
| `privileges.capabilities.drop` | list of string | `[]` | Dropped Linux capabilities |

For other privilege options (`dns`, `extra_hosts`, `sysctls`, etc.) use `extraServiceConfig`.

### Inter-service Networking

Services within the same app share the Arion/Compose project default network. They can reach each other using the service key as a DNS name — the key under `services.<name>`, not the container name.

```nix
# services.web can connect to "db:5432" and "redis:6379"
services.web.environment = {
  DATABASE_URL = "postgres://db:5432/app";
  REDIS_URL    = "redis://redis:6379";
};
```

Services in different apps are isolated by default. Cross-app communication requires either publishing ports (`services.<name>.ports`) or placing both apps on a shared external Docker network via `services.<name>.networks`.

---

## Volume Options (`apps.<app>.services.<service>.volumes[]`)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `type` | enum | `"bind"` | Volume kind: `"bind"`, `"library"`, or `"volume"` |
| `source` | string\|null | `null` | Bind source path |
| `name` | string\|null | `null` | Named volume or library name |
| `target` | string | none | Mount target inside the container |
| `readOnly` | bool | `false` | Mount read-only |
| `external` | bool | `false` | Treat named volume as external |
| `dockerName` | string\|null | `null` | Pin the Docker-level volume name by emitting `name:` in the compose volumes section. Without this, Docker prefixes the volume key with the project name. Use when a container requires an exact volume name (e.g. Nextcloud AIO's `nextcloud_aio_mastercontainer`) |

### `hostPath.*`

Controls host-side directory creation for bind mounts.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `hostPath.enable` | bool | `false` | Only for absolute bind sources: enable host path creation and ownership management via tmpfiles. Relative sources are always auto-created; set `hostPath.user/group/mode` directly without enabling this |
| `hostPath.type` | enum | `"directory"` | Managed host path type |
| `hostPath.user` | string | `"root"` | Owner of the managed path |
| `hostPath.group` | string | `"root"` | Group of the managed path |
| `hostPath.mode` | string | `"0755"` | Permissions of the managed path |

### Volume Kinds

- `type = "bind"` uses `source` as a host path.
- `type = "library"` uses `name` to reference `homestation.homelab.libraries.<name>`.
- `type = "volume"` uses `name` as the Docker/Arion volume name and emits a
  named compose volume definition.
- `external = true` marks that named compose volume as external.

### Volume Patterns

**Shared host path across multiple apps** — declare a library and reference it by name. Change the path in one place:

```nix
homestation.homelab.libraries.media = { path = "/srv/media"; };

apps.navidrome.services.server.volumes = [{ type = "library"; name = "media"; target = "/music"; readOnly = true; }];
apps.jellyfin.services.server.volumes  = [{ type = "library"; name = "media"; target = "/media"; readOnly = true; }];
```

**App-private managed path** — use a relative `source`. The module automatically creates `$dataDir/<app>/<source>`. Set `hostPath.user/group` when the container runs as a non-root user:

```nix
services.web.volumes = [{
  type   = "bind";
  source = "data";        # → /var/lib/homelab/myapp/data, created automatically
  target = "/app/data";
  hostPath.user  = "1000";
  hostPath.group = "1000";
}];
```

**Pre-existing absolute path** — use an absolute `source`. The module leaves the host path alone unless you opt in with `hostPath.enable = true`. Setting `hostPath.user/group/mode` without enabling this has no effect and is caught at evaluation time:

```nix
services.web.volumes = [{
  type   = "bind";
  source = "/mnt/external-disk/data";
  target = "/app/data";
  # hostPath.enable = true;   # add when you want the module to create/chown the path
}];
```

---

## Validation

The public schema in `options.nix` enforces these constraints:

- Ports are limited to `1..65535`.
- `expose.mode` is one of `"none"`, `"private"`, or `"public"`.
- `expose.protocol` is one of `"http"` or `"https"`.
- `dependsOn.<service>.condition` is limited to the supported dependency modes.
- Volume `type` is limited to `"bind"`, `"library"`, or `"volume"`.
- DNS record `type` is limited to `"A"`, `"AAAA"`, or `"CNAME"`.
- DNS record `visibility` is limited to `"lan"` or `"public"`.

At evaluation time, `validation.nix` adds runtime assertions against the
normalized app/service graph:

- Exposed apps must resolve an effective host and at least one route.
- When `routes` is empty, a catch-all route is auto-derived from `expose.service`; if neither `expose.service` nor a single-service default is resolvable, evaluation fails.
- `expose.service` must reference an enabled service in the same app.
- `expose.mode = "public"` requires
  `homestation.homelab.cloudflared.wildcardIngress = true`.
- Every resolved route must target an enabled service with a defined `port`.
- `services.<name>.dependsOn` may only reference enabled services in the same
  app.
- `services.<name>.volumes` must use a valid `type/source/name` combination.
- Relative bind sources may not start with `..`; escaping the app data
  directory is rejected at evaluation time.
- Exposed hostnames must be globally unique.
- Generated Arion project names must remain unique after `_` to `-`
  normalization.
- Generated container names must remain unique after `_` to `-`
  normalization.
- `cloudflared.wildcardIngress` also requires `cloudflared.enable`,
  `cloudflared.tunnelId`, and `domain` to be set.

These runtime checks now target the `services` API rather than the removed
`container` / `containers` compatibility surface.

---

## Recipes

### Single-service app

```nix
apps.whoami = {
  expose = {
    mode = "private";
    host = "whoami";
    # service omitted — auto-derived from the single service below
  };

  # routes omitted — auto-derived from expose.service

  services.web = {
    enable = true;
    image = "traefik/whoami:latest";
    port = 80;
    helpers.timezone = true;
  };
};
```

### Multi-service app

```nix
apps.paperless = {
  expose = {
    mode = "private";
    host = "paperless";
    service = "web";
  };

  # routes omitted — auto-derived from expose.service

  services.web = {
    enable = true;
    image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
    port = 8000;
    helpers.identity = true;
    dependsOn.redis = {};
    dependsOn.db.condition = "service_healthy";
  };

  services.redis = {
    enable = true;
    image = "docker.io/library/redis:7";
  };

  services.db = {
    enable = true;
    image = "docker.io/library/postgres:16";
    healthcheck.test = [ "CMD-SHELL" "pg_isready -U postgres" ];
  };
};
```

### Library-backed mount

```nix
homestation.homelab.libraries.media = {
  path = "/srv/media";
};

homestation.homelab.apps.navidrome.services.server = {
  enable = true;
  image = "deluan/navidrome:latest";
  port = 4533;
  volumes = [
    {
      type = "library";
      name = "media";
      target = "/music";
      readOnly = true;
    }
  ];
};
```

---

## Maintenance Note

When `modules/nixos/homestation-homelab/options.nix` changes, update this
document in the same patch. Keep the app, service, route, volume, and
validation sections aligned with the module API.
