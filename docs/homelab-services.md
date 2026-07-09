# Homelab Service Module

The `homestation-homelab` module is a small API for declaring self-hosted apps,
their container services, and how traffic reaches them.

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
      targetService = "web";
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
        `-- services
            `-- <serviceName>
```

- An app is the unit a human thinks about: `paperless`, `nextcloud`, `immich`.
- A service is one containerized part of that app: `web`, `db`, `redis`.
- `expose` says whether the app gets a hostname and which service receives that traffic.
- `services` is the only supported workload form.

The older `apps.<app>.container` and `apps.<app>.containers` compatibility
paths were removed.

---

## Global Options (`homestation.homelab.*`)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Turn the homelab API on for this host |
| `domain` | string | `""` | Base domain used to expand short host labels like `"paperless"` into full hostnames; required and non-empty when `enable = true` |
| `lanAddress` | string | `""` | Host LAN IP used when the module generates local DNS records for exposed apps; required and non-empty when `enable = true` |
| `dataDir` | string | `"/var/lib/homelab"` | Base directory for app-owned persistent data |
| `ingressNetwork` | string | `"edge"` | Shared external Docker network used by Caddy and any exposed app backend |
| `libraries` | attrs of libraryType | `{}` | Named shared host paths that apps can mount by reference |
| `apps` | attrs of appType | `{}` | App definitions |

When native `services.adguardhome.enable = true` is also set on the host, all
hosts matching `*.${domain}` are rewritten to `lanAddress` in AdGuard Home.

### `cloudflared.*`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `cloudflared.enable` | bool | `true` | Enable Cloudflare Tunnel integration for public apps |
| `cloudflared.tunnelId` | string\|null | `null` | Tunnel UUID |

When any app uses `expose.mode = "public"`, the module automatically generates
Cloudflare Tunnel ingress for `*.${domain}` and points it at Caddy's internal
tunnel listener on `http://127.0.0.1:<caddy.tunnelPort>`. The apex `domain` is
added only when some public app explicitly resolves to the apex, for example
`host = "@"`.

### `caddy.*`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `caddy.enable` | bool | `true` | Enable generated Caddy ingress |
| `caddy.image` | string | `caddybuilds/caddy-cloudflare` (pinned) | Caddy image; by default the module uses a build with the Cloudflare DNS plugin |
| `caddy.ports` | list of string | `["80:80" "443:443" "443:443/udp"]` | Host port mappings for the Caddy container |
| `caddy.tunnelPort` | port | `8080` | Loopback-only HTTP listener used as the Cloudflare Tunnel origin |
| `caddy.openFirewall` | bool | `true` | Open the firewall for the externally bound Caddy ports |
| `caddy.environment` | attrs of string | `{}` | Environment variables for the Caddy container |
| `caddy.environmentFiles` | list of path | `[config.sops.templates."caddy.env".path]` | Environment files for the Caddy container |
| `caddy.globalConfig` | lines | `acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}` | Raw global Caddy config prepended before generated hosts |
| `caddy.extraHosts` | lines | `""` | Extra hand-written Caddy host handling that should live next to the generated app hosts |
| `caddy.extraVolumes` | list of string | `[]` | Extra bind mounts or named-volume mounts for the Caddy container |

By default, `modules/nixos/homestation-homelab/caddy.nix` configures HTTPS via
Cloudflare DNS-01 (`acme_dns cloudflare`). That means certificates are issued
through DNS API access rather than public HTTP reachability, so generated hosts
can work for LAN, Tailnet, and Tunnel access without changing the app API.

The generated Caddy config uses separate listeners:

- `https://*.${domain}` for local clients
- `http://*.${domain}:<caddy.tunnelPort>` for Cloudflare Tunnel origin traffic

Unknown hosts abort on the local wildcard listener and return `403` on the
tunnel listener.

### `smtp.*`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `smtp.host` | string\|null | `null` | Shared SMTP host reference |
| `smtp.port` | int\|null | `null` | Shared SMTP port reference |
| `smtp.security` | enum | `"starttls"` | Shared SMTP security mode: `"starttls"`, `"force_tls"`, or `"off"` |
| `smtp.from` | string\|null | `null` | Default sender address for apps that send mail |
| `smtp.username` | string\|null | `null` | Shared SMTP username reference |

These options are only a shared registry. The module does not inject SMTP
values into service environments automatically. Each app that needs SMTP wires
them in explicitly, for example:

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
| `path` | string | none | Absolute host path exposed as a reusable named library mount |

---

## App Options (`apps.<app>.*`)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `true` | Enable or disable the app |
| `expose.mode` | enum | `"none"` | Whether the app gets no ingress, private ingress, or public ingress |
| `expose.host` | string\|null | `null` | Host label or full hostname for the app |
| `expose.targetService` | string\|null | auto | Which service receives incoming traffic for this app |
| `expose.protocol` | enum | `"http"` | Protocol Caddy uses when talking to the app backend |
| `expose.caddyDirectives` | lines | `""` | Extra per-app Caddy directives inserted before `reverse_proxy` |
| `services` | attrs of serviceType | `{}` | Services that make up the app |

### App Exposure

- `mode = "none"` means the app stays internal.
- `mode = "private"` means the app gets local ingress but is not published through Cloudflare Tunnel.
- `mode = "public"` means the app gets both local ingress and Cloudflare Tunnel ingress.
- `targetService` should name a member of `services`. If the app has exactly one enabled service, the module uses it automatically.
- `caddyDirectives` is the small escape hatch for per-app Caddy tweaks such as extra headers or transport settings.

**Host resolution:** A plain label expands to `<host>.<domain>`. If `host`
already contains a dot, it is treated as a fully qualified hostname. The
special value `"@"` resolves to the bare `domain`.

---

## Service Options (`apps.<app>.services.<service>.*`)

### Basic

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable the service |
| `containerName` | string\|null | `null` | Override the generated container name when an app requires a fixed externally known name |
| `image` | string | none | Container image |
| `port` | int\|null | `null` | Main backend port used for app ingress when this service is the target service |
| `command` | list of string\|null | `null` | Override the container command |
| `entrypoint` | string\|null | `null` | Override the container entrypoint |
| `environment` | attrs of string | `{}` | Environment variables |
| `helpers.userIds` | bool | `false` | Inject `PUID` and `PGID` from the host defaults |
| `helpers.timezone` | bool | `false` | Inject `TZ` from `config.time.timeZone` |
| `environmentFiles` | list of path | `[]` | Environment files |
| `volumes` | list of volumeType | `[]` | Mounts for this service |
| `ports` | list of string | `[]` | Published host ports |
| `networks` | list of string | `[]` | Additional external Docker networks |
| `restart` | enum | `"unless-stopped"` | Container restart policy |
| `labels` | attrs of string | `{}` | Container labels |
| `extraServiceConfig` | attrs | `{}` | Last-resort escape hatch for compose options not covered by the typed API |

### Helpers

`helpers` exists for common environment values that many self-hosted containers
expect:

- `helpers.userIds = true` injects `PUID` and `PGID`
- `helpers.timezone = true` injects `TZ`
- LinuxServer images automatically receive `PUID`, `PGID`, and `TZ`

These toggles are additive. Explicit values in `environment` still win on key
conflicts.

Injected values come from the host:

- `PUID` uses `config.users.users.${config.meta.username}.uid`, falling back to `"1000"` when unset
- `PGID` uses `config.ids.gids.users`
- `TZ` uses `config.time.timeZone`

```nix
services.web.helpers.userIds = true;  # PUID + PGID
services.web.helpers.timezone = true; # TZ only
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

`dependsOn` lets one service wait for another service in the same app.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `dependsOn` | attrs of submodule | `{}` | Dependency map keyed by service name |
| `dependsOn.<service>.condition` | enum | `"service_started"` | Condition required before the dependent service starts |

Allowed `condition` values:

- `"service_started"`
- `"service_healthy"`
- `"service_completed_successfully"`

Because `condition` defaults to `"service_started"`, you can omit it when that
is enough:

```nix
dependsOn.redis = {};
dependsOn.db.condition = "service_healthy";
```

### Runtime

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `runtime.user` | string\|null | `null` | Container runtime user |

For other runtime options (`working_dir`, `tmpfs`, `tty`, `init`,
`stop_grace_period`, `stop_signal`, etc.), use `extraServiceConfig`.

### Privileges

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `privileges.networkMode` | string\|null | `null` | Docker network mode override |
| `privileges.privileged` | bool | `false` | Run the container as privileged |
| `privileges.devices` | list of string | `[]` | Extra device mappings |
| `privileges.capabilities.add` | list of string | `[]` | Linux capabilities to add |
| `privileges.capabilities.drop` | list of string | `[]` | Linux capabilities to drop |

For other privilege options (`dns`, `extra_hosts`, `sysctls`, etc.), use
`extraServiceConfig`.

### Inter-service Networking

Services within the same app can talk to each other on the default internal app
network by using their service key as the hostname.

```nix
services.web.environment = {
  DATABASE_URL = "postgres://db:5432/app";
  REDIS_URL = "redis://redis:6379";
};
```

Different apps are isolated by default. Cross-app communication requires either
published ports (`services.<name>.ports`) or a shared external Docker network
via `services.<name>.networks`.

---

## Volume Options (`apps.<app>.services.<service>.volumes[]`)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `type` | enum | `"bind"` | Mount kind: `"bind"`, `"library"`, or `"volume"` |
| `source` | string\|null | `null` | Host path when `type = "bind"` |
| `library` | string\|null | `null` | Library key when `type = "library"` |
| `volume` | string\|null | `null` | Logical volume key when `type = "volume"` |
| `target` | string | none | Mount point inside the container |
| `readOnly` | bool | `false` | Mount read-only |
| `external` | bool | `false` | Treat a named volume as pre-existing |
| `engineName` | string\|null | `null` | Exact engine-level name for a named volume when Docker's derived name is not acceptable |
| `owner` | string | `"root"` | Owner for module-managed relative bind sources |
| `group` | string | `"root"` | Group for module-managed relative bind sources |
| `mode` | string | `"0755"` | Permissions for module-managed relative bind sources |

### Volume Kinds

- `type = "bind"` mounts a host path
- `type = "library"` mounts a named shared path from `homestation.homelab.libraries`
- `type = "volume"` creates or references a named Docker volume
- `external = true` marks that named volume as pre-existing

### Volume Patterns

**Shared host path across multiple apps**:

```nix
homestation.homelab.libraries.media = { path = "/srv/media"; };

apps.navidrome.services.server.volumes = [{ type = "library"; library = "media"; target = "/music"; readOnly = true; }];
apps.jellyfin.services.server.volumes = [{ type = "library"; library = "media"; target = "/media"; readOnly = true; }];
```

**App-private managed path**:

```nix
services.web.volumes = [{
  type = "bind";
  source = "data";
  target = "/app/data";
  owner = "1000";
  group = "1000";
}];
```

A relative bind `source` like `"data"` becomes
`$dataDir/<app>/<source>` automatically.

**Pre-existing absolute path**:

```nix
services.web.volumes = [{
  type = "bind";
  source = "/mnt/external-disk/data";
  target = "/app/data";
}];
```

Absolute bind paths are left alone. Ownership and permissions are only managed
for relative bind sources.

---

## Validation

The public schema in `options.nix` enforces these constraints:

- Ports are limited to `1..65535`
- `expose.mode` is one of `"none"`, `"private"`, or `"public"`
- `expose.protocol` is one of `"http"` or `"https"`
- `dependsOn.<service>.condition` is limited to the supported dependency modes
- Volume `type` is limited to `"bind"`, `"library"`, or `"volume"`
- DNS record `type` is limited to `"A"`, `"AAAA"`, or `"CNAME"`
- DNS record `visibility` is limited to `"lan"` or `"public"`

At evaluation time, `validation.nix` adds runtime assertions:

- `domain` must be non-empty when the module is enabled
- `lanAddress` must be non-empty when the module is enabled
- Exposed apps must resolve an effective host
- Exposed apps must resolve `expose.targetService`; when the app has exactly one enabled service, that service is auto-derived
- The exposed target service must define a `port`
- `expose.targetService` must reference an enabled service in the same app
- `expose.mode = "public"` requires `cloudflared.enable` and `cloudflared.tunnelId`
- `services.<name>.dependsOn` may only reference enabled services in the same app
- `services.<name>.volumes` must use a valid `type/source/library/volume` combination
- Relative bind sources may not escape the app data directory
- `owner/group/mode` may only be set on relative bind sources
- Exposed hostnames must be globally unique
- Generated Arion project names must remain unique after `_` to `-` normalization
- Generated container names must remain unique after `_` to `-` normalization

---

## Recipes

### Single-service app

```nix
apps.whoami = {
  expose = {
    mode = "private";
    host = "whoami";
    # targetService omitted: auto-derived from the single enabled service
  };

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
    targetService = "web";
  };

  services.web = {
    enable = true;
    image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
    port = 8000;
    helpers.userIds = true;
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
      library = "media";
      target = "/music";
      readOnly = true;
    }
  ];
};
```

---

## Maintenance Note

When `modules/nixos/homestation-homelab/options.nix` changes, update this
document in the same patch. Keep the global, app, service, volume, and
validation sections aligned with the module API.
