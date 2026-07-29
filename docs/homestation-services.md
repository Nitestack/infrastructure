# Homestation Service Inventory

This inventory is a human-oriented map of the services currently configured for
`homestation`. The Nix configuration is authoritative; update this table in the
same change whenever an app is added, removed, renamed, or its exposure changes.

`Public` means the homelab module includes the app in Cloudflare Tunnel ingress.
It does not imply anonymous access: each service may still require its own
authentication. `Private` apps are available through the local HTTPS ingress
but are excluded from generated tunnel ingress. `Internal` apps have no app
hostname.

| Service | Exposure | Purpose | Configuration |
| --- | --- | --- | --- |
| AdGuard Home | Special Caddy host `dns.npham.de` | LAN DNS and filtering | [`adguard-home.nix`](../configurations/nixos/homestation/homelab/adguard-home.nix) |
| AdventureLog | Public `travel.npham.de` | Travel journal | [`adventure-log.nix`](../configurations/nixos/homestation/homelab/adventure-log.nix) |
| AudioMuse-AI | Private `muse.npham.de` | Music analysis and processing | [`audiomuse-ai.nix`](../configurations/nixos/homestation/homelab/audiomuse-ai.nix) |
| Beets | Internal | Music-library management | [`beets/default.nix`](../configurations/nixos/homestation/homelab/beets/default.nix) |
| Beszel | Public `status.npham.de` | Host and container monitoring | [`beszel.nix`](../configurations/nixos/homestation/homelab/beszel.nix) |
| Calibre-Web Automated | Public `lib.npham.de` | E-book library and ingestion | [`calibre-web-automated.nix`](../configurations/nixos/homestation/homelab/calibre-web-automated.nix) |
| Ente | Public `2fa.npham.de` | Ente web application; Museum uses an additional Caddy host | [`ente/default.nix`](../configurations/nixos/homestation/homelab/ente/default.nix) |
| FreshRSS | Public `feed.npham.de` | Feed reader | [`freshrss.nix`](../configurations/nixos/homestation/homelab/freshrss.nix) |
| Glance | Public `dash.npham.de` | Dashboard | [`glance/default.nix`](../configurations/nixos/homestation/homelab/glance/default.nix) |
| Immich | Public `media.npham.de` | Photo and video management | [`immich.nix`](../configurations/nixos/homestation/homelab/immich.nix) |
| IT-Tools | Public `it.npham.de` | Browser-based technical utilities | [`it-tools.nix`](../configurations/nixos/homestation/homelab/it-tools.nix) |
| Navidrome | Public `music.npham.de` | Music streaming | [`navidrome.nix`](../configurations/nixos/homestation/homelab/navidrome.nix) |
| Nextcloud AIO | Public `cloud.npham.de` | File collaboration and sync | [`nextcloud.nix`](../configurations/nixos/homestation/homelab/nextcloud.nix) |
| Obsidian LiveSync | Public `obsidian.npham.de` | CouchDB endpoint for Obsidian sync | [`obsidian-livesync.nix`](../configurations/nixos/homestation/homelab/obsidian-livesync.nix) |
| Pocket ID | Public `id.npham.de` | Identity provider | [`pocket-id.nix`](../configurations/nixos/homestation/homelab/pocket-id.nix) |
| Prowlarr | Public `index.npham.de` | Indexer management | [`prowlarr.nix`](../configurations/nixos/homestation/homelab/prowlarr.nix) |
| RdtClient | Public `magnets.npham.de` | Download-client bridge | [`rdtclient.nix`](../configurations/nixos/homestation/homelab/rdtclient.nix) |
| Shelfmark | Public `books.npham.de` | Book discovery and download workflow | [`shelfmark.nix`](../configurations/nixos/homestation/homelab/shelfmark.nix) |
| Vaultwarden | Public `vault.npham.de` | Password-manager server | [`vaultwarden.nix`](../configurations/nixos/homestation/homelab/vaultwarden.nix) |
| Vikunja | Public `tasks.npham.de` | Task management | [`vikunja.nix`](../configurations/nixos/homestation/homelab/vikunja.nix) |
| Wealthfolio | Public `wealth.npham.de` | Portfolio tracking | [`wealthfolio.nix`](../configurations/nixos/homestation/homelab/wealthfolio.nix) |
| Yamtrack | Public `track.npham.de` | Media tracking | [`yamtrack.nix`](../configurations/nixos/homestation/homelab/yamtrack.nix) |

Glance also links to `backup.npham.de`, but no corresponding homelab app is
declared in this repository. Its ownership and operation are therefore outside
this inventory.
