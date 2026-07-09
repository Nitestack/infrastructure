# AdGuard Home Client Caveats

## Persistent clients are not labels

In AdGuard Home, `clients.persistent` entries are not display-only labels for
the UI. They are per-client policy objects.

Once a query matches a persistent client, AdGuard Home may apply client-specific
behavior such as:

- custom settings
- custom filtering
- custom upstreams
- tags
- different DNS rewrite behavior

## Why this matters in this repo

This repository generates homelab LAN DNS rewrites through the native AdGuard
Home configuration. Those rewrites are expected to apply globally.

However, adding persistent clients for infrastructure IPs or broad CIDR ranges
can change how AdGuard Home evaluates matching queries.

Problematic examples:

- the Fritz!Box router IP, when client DNS requests appear to come from the
  router rather than the end device
- the Tailnet CGNAT range `100.64.0.0/10`, which matches all Tailnet clients

In practice, this can make local DNS rewrites stop working for the matched
queries even though the rewrite rules still exist.

## Symptoms

Typical signs of this problem:

- local-only services stop resolving on the home network after adding the
  router as a persistent client
- Tailnet clients stop resolving homelab names after adding
  `100.64.0.0/10` as a persistent client
- the AdGuard query log shows the request under a persistent client such as
  `Router` instead of the real end device
- the query is answered by a public upstream instead of the expected local
  rewrite target

## Safe usage guidelines

- Do not use persistent clients for naming-only purposes.
- Do not add the router IP as a persistent client unless router-specific policy
  is intentionally required.
- Do not add broad CIDR ranges such as `100.64.0.0/10` as persistent clients.
- Prefer exact end-device IPs only when you actually need per-device policy.
- For friendly names only, prefer automatic reverse DNS, DHCP-derived names, or
  hosts-style naming instead of persistent clients.

## Recommended approach

For this homelab setup:

- keep DNS rewrites global
- avoid persistent clients for shared infrastructure addresses
- avoid persistent clients for whole network ranges
- use persistent clients sparingly for exact devices only

If a name is only needed for readability in the AdGuard UI, prefer a mechanism
that does not create per-client policy.
