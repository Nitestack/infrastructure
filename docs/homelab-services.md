# Homelab Service Module

The `homestation-homelab` NixOS module provides a declarative abstraction for
running containerized services on the homestation host. It manages Docker
networks, Caddy reverse proxy config, Cloudflare tunnel ingress, and local DNS
records — all derived from a single unified service definition.

Module source: `modules/nixos/homestation-homelab/`

---

## Quick Start

```nix
# configurations/nixos/homestation/default.nix
homestation.homelab = {
  enable = true;
  domain = "example.com";
  lanAddress = "192.168.1.10";
  cloudflared.tunnelId = "<your-tunnel-uuid>";

  apps.myapp.containers.web = {
    image = "myimage:latest";
    edge.enable = true;
    expose = {
      mode = "private";
      subdomain = "myapp";   # resolves to myapp.example.com
      port = 8080;
    };
    # relative source → auto-resolves to /var/lib/homelab/myapp/data
    volumes = [{ source = "data"; target = "/data"; }];
  };
};
```

---

## Conceptual Model

Services are organized in a two-level hierarchy:

```
homestation.homelab
└── apps
    └── <appName>          (logical grouping, e.g. "nextcloud")
        └── containers
            └── <containerName>   (individual container, e.g. "web", "db")
```

Each **app** is a named group of containers that share an isolated Docker
network. Each **container** maps to one OCI container and carries all its own
networking, ingress, volume, and DNS configuration.

The module then generates:
- `virtualisation.oci-containers.containers.*` entries for each enabled container
- A Caddy OCI container with an auto-built Caddyfile for HTTP reverse proxying
- Cloudflare tunnel ingress rules for public exposure
- Adguard/local DNS A records for private LAN exposure
- systemd-tmpfiles rules to pre-create host paths for volumes

---

## Global Options (`homestation.homelab.*`)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Master switch for the module |
| `domain` | string\|null | `null` | Base domain (e.g. `"example.com"`) used for subdomain derivation |
| `lanAddress` | string\|null | `null` | LAN IP of this host; required for private DNS records |
| `dataDir` | string | `"/var/lib/homelab"` | Root directory for all persistent service data |
| `libraries` | attrs of libraryType | `{}` | Named shared host paths (music library, etc.) mountable by any container |
| `network.prefix` | string | `"homelab"` | Prefix for Docker network names (must be non-empty) |
| `edgeNetwork.name` | string | `"homelab-edge"` | Name of the shared edge Docker network (Caddy + edge containers) |

### `cloudflared` sub-options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `cloudflared.enable` | bool | `true` | Enable the Cloudflare tunnel integration |
| `cloudflared.tunnelId` | string\|null | `null` | Cloudflare tunnel UUID; required for `expose.mode = "tunnel"` |

### `caddy` sub-options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `caddy.enable` | bool | `true` | Enable the Caddy reverse proxy container |
| `caddy.enableWithoutServices` | bool | `false` | Start Caddy even if no containers need it |
| `caddy.image` | string | `"caddy:latest"` | Docker image for Caddy |
| `caddy.ports` | list of string | `["80:80", "443:443", "443:443/udp"]` | Host port mappings for the Caddy container |
| `caddy.openFirewall` | bool | `true` | Open firewall for Caddy's host ports |
| `caddy.environment` | attrs of string | `{}` | Environment variables passed to Caddy |
| `caddy.environmentFiles` | list of path | `[]` | Secret env files for Caddy (e.g. for ACME credentials) |
| `caddy.globalConfig` | lines | `""` | Content prepended to the generated Caddyfile (global block) |
| `caddy.extraVolumes` | list of string | `[]` | Extra volume mounts for the Caddy container |

### `libraries` sub-options

Libraries are named host paths that can be volume-mounted into any container using
`library = "<name>"` instead of `source`. Useful for shared media, book, or data
collections that multiple services need to access.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `libraries.<name>.path` | string | — | Absolute host path of the shared directory (required) |
| `libraries.<name>.create` | bool | `false` | Auto-create via systemd-tmpfiles if the path doesn't exist |
| `libraries.<name>.user` | string | `"root"` | Owner user (only used when `create = true`) |
| `libraries.<name>.group` | string | `"root"` | Owner group (only used when `create = true`) |
| `libraries.<name>.mode` | string | `"0755"` | Permissions (only used when `create = true`) |

```nix
homestation.homelab.libraries = {
  music = { path = "/srv/music"; };           # pre-existing mount, no auto-create
  books = { path = "/srv/books"; create = true; user = "1000"; group = "1000"; };
};
```

### `dns.records` (manual records)

Manually add DNS records outside of any container definition:

```nix
homestation.homelab.dns.records = {
  "nas.example.com" = {
    type = "A";
    value = "192.168.1.20";
    visibility = "lan";  # "lan" | "public"
  };
};
```

---

## App Options (`apps.<appName>.*`)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `true` | Enable or disable all containers in this app |
| `containers` | attrs of containerType | `{}` | Container definitions for this app |

---

## Container Options (`apps.<appName>.containers.<containerName>.*`)

### Basic

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable this container (must be explicitly set to `true`) |
| `image` | string | — | Docker image (required) |
| `command` | list of string\|null | `null` | Override the container command |
| `entrypoint` | string\|null | `null` | Override the container entrypoint |
| `env` | attrs of string | `{}` | Environment variables |
| `environmentFiles` | list of path | `[]` | Paths to env files (e.g. from sops-nix) |

### Edge / Networking

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `edge.enable` | bool | `false` | Attach this container to the shared edge network so Caddy can reach it |
| `networks` | list of string | `[]` | Additional Docker networks to join beyond the auto-assigned ones |

**Automatic networks:** A container is placed on the app's isolated network
when its app has more than one container. If `edge.enable = true`, it also
joins `edgeNetwork.name`. Extra networks from `networks` are appended.

### Exposure / Ingress

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `expose.mode` | enum | `"none"` | How to expose the service (see modes below) |
| `expose.host` | string\|null | `null` | Explicit hostname (e.g. `"svc.example.com"`) |
| `expose.subdomain` | string\|null | `null` | Derive host as `<subdomain>.<domain>`; `""` means bare domain |
| `expose.protocol` | enum | `"http"` | `"http"` or `"https"` — affects Caddy upstream scheme |
| `expose.port` | int\|null | `null` | Container port Caddy reverse-proxies to |

**Exposure modes:**

| Mode | Effect |
|------|--------|
| `"none"` | No ingress; container is internal only |
| `"private"` | LAN DNS A record → `lanAddress` + Caddy reverse proxy |
| `"public"` | Same as `"private"` but also registered for internet access |
| `"tunnel"` | Cloudflare tunnel ingress only (no LAN DNS, no direct Caddy port) |

**Host resolution order:**
1. `expose.host` if set
2. `expose.subdomain + "." + domain` if both are non-null
3. `domain` if `expose.subdomain == ""`
4. `null` (no host; exposure requires a host)

### Caddy Reverse Proxy

These options control the generated Caddyfile block for this container.
`caddy.enable` auto-enables when `edge.enable = true`, `expose.mode != "none"`,
and `expose.protocol == "http"`.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `caddy.enable` | bool | auto | Enable Caddy virtual host for this container |
| `caddy.extraConfig` | lines | `""` | Arbitrary Caddy directives inside the virtual host block |
| `caddy.reverseProxyExtraConfig` | lines | `""` | Directives inside the `reverse_proxy` block (e.g. for health checks or TLS transport) |
| `caddy.upstream` | string\|null | `null` | Override the upstream address (default: `<container-name>:<expose.port>`) |

The generated Caddyfile block looks like:

```caddy
myapp.example.com {
  <caddy.extraConfig>
  reverse_proxy myapp-web:8080 {
    <caddy.reverseProxyExtraConfig>
  }
}
```

For **HTTPS upstreams**, set `expose.protocol = "https"` and either provide a
custom `caddy.upstream` or configure TLS transport via
`caddy.reverseProxyExtraConfig`:

```nix
caddy = {
  reverseProxyExtraConfig = ''
    transport http {
      tls
      tls_insecure_skip_verify
    }
  '';
};
```

### DNS Records

Private DNS is auto-enabled when `edge.enable = true` and `expose.mode =
"private"`. It creates an A record pointing `expose.host` → `lanAddress`.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `dns.enable` | bool | auto | Enable auto-generated DNS A record |
| `dns.records` | attrs of dnsRecordType | `{}` | Extra DNS records for this container |

Custom records per container:

```nix
dns.records = {
  "alias.example.com" = {
    type = "CNAME";
    value = "myapp.example.com";
    visibility = "lan";
  };
};
```

### Port Listeners (Host Port Mappings)

Direct host port bindings, independent of reverse proxy exposure:

```nix
listeners = {
  smtp = {
    protocol = "tcp";        # "tcp" | "udp"
    containerPort = 25;
    hostPort = 25;
    bind = null;             # null = all interfaces; or specific IP
  };
  dns-udp = {
    protocol = "udp";
    containerPort = 53;
    hostPort = 53;
  };
};
```

The module validates that no two containers bind the same `hostPort/protocol`
combination on overlapping interfaces.

### Volumes

Each volume entry requires exactly one of `source` or `library` — not both, not neither.

**`source` — host path (absolute or relative):**

```nix
volumes = [
  # Relative source: auto-resolves to ${dataDir}/<appName>/config
  # Directory is created automatically — no hostPath.enable needed.
  {
    source = "config";
    target = "/config";
  }

  # Relative source with custom permissions
  {
    source = "data";
    target = "/data";
    hostPath.user = "1000";
    hostPath.group = "1000";
    hostPath.mode = "0750";
  }

  # Absolute source — requires hostPath.enable = true to auto-create
  {
    source = "/etc/localtime";
    target = "/etc/localtime";
    readOnly = true;
  }

  # Absolute source within dataDir, auto-created
  {
    source = "/var/lib/homelab/myapp/uploads";
    target = "/uploads";
    hostPath.enable = true;
    hostPath.type = "directory";
    hostPath.user = "root";
    hostPath.group = "root";
    hostPath.mode = "0755";
  }
];
```

Relative sources are always managed (directory created via systemd-tmpfiles).
Per-app base directories (`${dataDir}/<appName>`) are created automatically
whenever any container in the app has a relative-source volume.

**`library` — shared named path:**

```nix
volumes = [
  # Mounts the host path from homestation.homelab.libraries.music
  {
    library = "music";
    target = "/music";
    readOnly = true;
  }
];
```

Library volumes reference paths declared in `homestation.homelab.libraries`.
The host path is resolved at eval time; no tmpfiles rule is generated unless
`libraries.<name>.create = true`.

### Container Dependencies

Order containers within the same app. Names must refer to other containers in
the same app (enabled or not — the module filters to enabled ones at eval time).

```nix
dependsOn = [ "db" ];
```

### Docker-Specific Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `docker.name` | string\|null | `null` | Override the generated container name (default: `<appName>-<containerName>`) |
| `docker.autoStart` | bool | `true` | Start container on boot |
| `docker.labels` | attrs of string | `{}` | Docker labels |
| `docker.extraOptions` | list of string | `[]` | Raw `docker run` flags |

**Container naming:** By default the container is named `<appName>-<containerName>`.
Override with `docker.name` if needed, but take care: duplicate names across apps
will be caught by validation.

---

## Networking Internals

```
Internet
   │
   ▼
[Cloudflare Tunnel]  ← tunnel mode services
   │
   ▼
[Caddy container]  ← on homelab-edge network
   │
   ├── myapp-web        (edge.enable = true → also on homelab-edge)
   └── otherapp-web

[homelab-myapp network]  ← multi-container app isolation
   ├── myapp-web
   └── myapp-db         (only on app network, not edge)
```

- **Single-container apps** are placed only on the edge network (if `edge.enable`).
- **Multi-container apps** automatically get an isolated `{prefix}-{appName}` network
  for inter-container communication.
- The Caddy container is always on `edgeNetwork.name`.
- Containers with `edge.enable = true` join `edgeNetwork.name`, making them
  reachable by Caddy by their generated name.

---

## Validation

The module catches configuration errors at `nix eval` time:

- Duplicate container names (across all apps)
- Duplicate exposed hostnames
- Duplicate or conflicting host port listeners
- `expose.mode != "none"` without a resolvable hostname
- `expose.mode = "tunnel"` without `cloudflared.enable` and a valid `tunnelId`
- `caddy.enable = true` without `edge.enable`, `expose.host`, or `expose.port`
- `expose.protocol = "https"` without a `caddy.upstream` or `reverseProxyExtraConfig`
- `dns.enable = true` with `expose.mode = "private"` but no `lanAddress`
- `dependsOn` referencing unknown containers in the app
- Volume with both `source` and `library` set, or neither set
- Relative `source` that starts with `..` (would escape the app data directory)
- `library` referencing a name not declared in `homestation.homelab.libraries`
- Auto-generated DNS keys conflicting with explicit `dns.records` keys
- OCI backend must be `"docker"` (`virtualisation.oci-containers.backend`)
- Native `services.caddy.enable` must be `false` (conflicts with the generated container)

---

## Recipes

### Minimal private service

```nix
apps.myapp.containers.web = {
  enable = true;
  image = "myimage:1.0";
  edge.enable = true;
  expose = {
    mode = "private";
    subdomain = "myapp";
    port = 3000;
  };
};
```

Creates:
- Docker container `myapp-web` on `homelab-edge`
- Caddy virtual host `myapp.example.com → myapp-web:3000`
- DNS A record `myapp.example.com → lanAddress`

### Public service via Cloudflare tunnel

```nix
apps.myapp.containers.web = {
  enable = true;
  image = "myimage:1.0";
  edge.enable = true;
  expose = {
    mode = "tunnel";
    subdomain = "myapp";
    port = 3000;
  };
};
```

### Multi-container app (app + database)

```nix
apps.nextcloud = {
  containers.web = {
    enable = true;
    image = "nextcloud:latest";
    edge.enable = true;
    expose = {
      mode = "private";
      subdomain = "cloud";
      port = 80;
    };
    dependsOn = [ "db" ];
    env = {
      POSTGRES_HOST = "nextcloud-db";
      POSTGRES_DB = "nextcloud";
    };
    # relative → /var/lib/homelab/nextcloud/html, auto-created
    volumes = [{ source = "html"; target = "/var/www/html"; }];
  };

  containers.db = {
    enable = true;
    image = "postgres:16";
    environmentFiles = [ config.sops.secrets."nextcloud/db-env".path ];
    volumes = [{ source = "db"; target = "/var/lib/postgresql/data"; }];
  };
};
```

Both containers share the auto-created `homelab-nextcloud` Docker network.
`nextcloud-web` also joins the edge network. `nextcloud-db` is isolated.

### Shared library mounts (music, books, etc.)

```nix
homestation.homelab = {
  libraries.music = { path = "/srv/music"; };

  apps.navidrome.containers.server = {
    enable = true;
    image = "deluan/navidrome:latest";
    edge.enable = true;
    expose = { mode = "private"; subdomain = "music"; port = 4533; };
    volumes = [
      { source = "data"; target = "/data"; }           # /var/lib/homelab/navidrome/data
      { library = "music"; target = "/music"; readOnly = true; }
    ];
  };

  apps.beets.containers.server = {
    enable = true;
    image = "lscr.io/linuxserver/beets:latest";
    volumes = [
      { source = "config"; target = "/config"; }
      { library = "music"; target = "/music"; }        # same library, read-write for tagging
    ];
  };
};
```

### Direct port binding (no reverse proxy)

```nix
apps.minecraft.containers.server = {
  enable = true;
  image = "itzg/minecraft-server:latest";
  env.EULA = "TRUE";
  listeners.game = {
    containerPort = 25565;
    hostPort = 25565;
  };
  volumes = [{ source = "data"; target = "/data"; }];
};
```

### Custom Caddy config (rate limiting, headers, etc.)

```nix
caddy.extraConfig = ''
  header X-Frame-Options SAMEORIGIN
  rate_limit {
    zone dynamic {
      key {remote_host}
      events 100
      window 1m
    }
  }
'';
```

### HTTPS upstream (container speaks TLS)

```nix
expose.protocol = "https";
expose.port = 8443;
caddy.reverseProxyExtraConfig = ''
  transport http {
    tls
    tls_insecure_skip_verify
  }
'';
```

---

## Prerequisites

The following must be configured on the host before enabling this module:

```nix
virtualisation.oci-containers.backend = "docker";
virtualisation.docker.enable = true;   # or enable via the module that does this
services.caddy.enable = false;          # must NOT be enabled (module runs Caddy in Docker)
```

For `expose.mode = "tunnel"`:
```nix
services.cloudflared.enable = true;
services.cloudflared.tunnelId = "...";
services.cloudflared.tunnels."<tunnelId>".credentialsFile = ...;
```

---

## Maintenance Note

> **When the `homestation-homelab` module API changes** (options added, renamed,
> or removed in `modules/nixos/homestation-homelab/options.nix`), update this
> document to reflect the new API. Keep the option tables, validation section,
> and recipes in sync. See AGENTS.md for the reminder.
