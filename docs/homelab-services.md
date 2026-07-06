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

    routes = [
      {
        upstream.service = "web";
      }
    ];

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
| `lanAddress` | string\|null | `null` | LAN IP used for private DNS/ingress |
| `dataDir` | string | `"/var/lib/homelab"` | Base directory for persistent app data |
| `network.prefix` | string | `"homelab"` | Prefix used when generating network names |
| `edgeNetwork.name` | string | `"homelab-edge"` | Shared edge network name |
| `libraries` | attrs of libraryType | `{}` | Named shared host paths mountable from services |
| `apps` | attrs of appType | `{}` | App definitions |
| `dns.records` | attrs of dnsRecordType | `{}` | Extra manual DNS records |

### `cloudflared.*`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `cloudflared.enable` | bool | `true` | Enable Cloudflare tunnel integration |
| `cloudflared.tunnelId` | string\|null | `null` | Tunnel UUID |
| `cloudflared.wildcardIngress` | bool | `false` | Enable wildcard ingress generation |

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
| `caddy.extraVolumes` | list of string | `[]` | Extra volume mounts for Caddy |

### `smtp.*`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `smtp.host` | string\|null | `null` | Shared SMTP host |
| `smtp.port` | int\|null | `null` | Shared SMTP port |
| `smtp.security` | enum | `"starttls"` | Shared SMTP mode: `"starttls"`, `"force_tls"`, or `"off"` |
| `smtp.from` | string\|null | `null` | Default sender address |
| `smtp.username` | string\|null | `null` | Shared SMTP username |

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
| `expose.service` | string\|null | `null` | Service name used as the default upstream target |
| `expose.protocol` | enum | `"http"` | Upstream protocol: `"http"` or `"https"` |
| `routes` | list of routeType | `[]` | Ordered ingress routes for the app |
| `services` | attrs of serviceType | `{}` | Workloads that belong to the app |

### App Exposure

- `mode = "none"` keeps the app internal.
- `mode = "private"` is for LAN-only ingress.
- `mode = "public"` is for internet-facing ingress.
- `host = null` means the app has no hostname.
- `service` should name a member of `services`.

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
| `image` | string | none | Container image |
| `port` | int\|null | `null` | Primary service port |
| `command` | list of string\|null | `null` | Override the service command |
| `entrypoint` | string\|null | `null` | Override the service entrypoint |
| `volumes` | list of volumeType | `[]` | Volume mounts |

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

### Runtime

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `runtime.user` | string\|null | `null` | Container user |
| `runtime.workingDir` | string\|null | `null` | Working directory |
| `runtime.init` | bool | `false` | Run with an init process |
| `runtime.tmpfs` | list of string | `[]` | Tmpfs mounts |
| `runtime.tty` | bool | `false` | Allocate a TTY |
| `runtime.stopGracePeriod` | string\|null | `null` | Grace period before forced stop |
| `runtime.stopSignal` | string\|null | `null` | Stop signal |

### Privileges

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `privileges.networkMode` | string\|null | `null` | Docker network mode |
| `privileges.privileged` | bool | `false` | Run as privileged |
| `privileges.devices` | list of string | `[]` | Extra device mappings |
| `privileges.capabilities.add` | list of string | `[]` | Added Linux capabilities |
| `privileges.capabilities.drop` | list of string | `[]` | Dropped Linux capabilities |
| `privileges.dns` | list of string | `[]` | Custom DNS servers |
| `privileges.extraHosts` | list of string | `[]` | Extra host mappings |
| `privileges.sysctls` | attrs of string | `{}` | Kernel sysctls |

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

### `hostPath.*`

Use `hostPath` when the module should manage metadata for bind mounts.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `hostPath.enable` | bool | `false` | Manage the host path |
| `hostPath.type` | enum | `"directory"` | Managed host path type |
| `hostPath.user` | string | `"root"` | Owner of the managed path |
| `hostPath.group` | string | `"root"` | Group of the managed path |
| `hostPath.mode` | string | `"0755"` | Permissions of the managed path |

### Volume Kinds

- `type = "bind"` uses `source` as a host path.
- `type = "library"` uses `name` to reference `homestation.homelab.libraries.<name>`.
- `type = "volume"` uses `name` as the Docker/Arion volume name.

---

## Validation

The public schema currently enforces these constraints directly in
`options.nix`:

- Ports are limited to `1..65535`.
- `expose.mode` is one of `"none"`, `"private"`, or `"public"`.
- `expose.protocol` is one of `"http"` or `"https"`.
- `dependsOn.<service>.condition` is limited to the supported dependency modes.
- Volume `type` is limited to `"bind"`, `"library"`, or `"volume"`.
- DNS record `type` is limited to `"A"`, `"AAAA"`, or `"CNAME"`.
- DNS record `visibility` is limited to `"lan"` or `"public"`.

Any additional runtime assertions in the rest of the module should be updated to
target the `services` API rather than the removed `container` /
`containers` compatibility surface.

---

## Recipes

### Single-service app

```nix
apps.whoami = {
  expose = {
    mode = "private";
    host = "whoami";
    service = "web";
  };

  routes = [{ upstream.service = "web"; }];

  services.web = {
    enable = true;
    image = "traefik/whoami:latest";
    port = 80;
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

  routes = [{ upstream.service = "web"; }];

  services.web = {
    enable = true;
    image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
    port = 8000;
    dependsOn.redis.condition = "service_started";
    dependsOn.db.condition = "service_started";
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
