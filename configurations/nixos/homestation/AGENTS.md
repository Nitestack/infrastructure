# homestation

`homestation` is the NixOS server and the only host wiring the reusable
`modules/nixos/homelab/` API. App definitions live under `homelab/`; the
generated Arion projects, Caddy ingress, DNS rewrites, and Cloudflare Tunnel
configuration are outputs of that source.

## Service Changes

- Add or change an app in its focused file under `homelab/`, not in generated
  Compose state or a running container.
- When an app is added, removed, renamed, or its exposure changes, update
  `docs/homestation-services.md` in the same change.
- When the reusable module API or its validation/networking behaviour changes,
  read `modules/nixos/homelab/AGENTS.md` and update
  `docs/homelab-services.md`.
- Keep persistent data and recovery assumptions explicit. Relative bind mounts
  resolve under `/var/lib/homelab/<app>/`; absolute mounts and named volumes
  need service-specific care.

## Verification

Use [`docs/operations.md`](../../../docs/operations.md) for validation and
activation, then follow
[`docs/homestation-operations.md`](../../../docs/homestation-operations.md) for
systemd, container, ingress, and storage checks. Cloudflare DNS and zone changes
belong to
`opentofu/cloudflare/`, not to a manual edit on the server.
