# Cloudflare Domains

Manual steps around the domains managed in
[`opentofu/cloudflare/`](../opentofu/cloudflare/README.md). Everything inside
Cloudflare (records, zone settings, DNSSEC signing, redirects) is declarative;
the steps here happen at the registrar, in the Cloudflare dashboard, or in sops,
where OpenTofu cannot reach.

## Add a new domain

1. **Check the registrar for old DNSSEC.** If DNSSEC is enabled at the
   registrar, disable it and remove any DS record **before** changing
   nameservers. A stale DS record that does not match Cloudflare's keys makes
   the domain fail on every validating resolver. Confirm the parent zone no
   longer publishes one:

   ```sh
   dig +short DS <domain> @1.1.1.1   # must be empty
   ```

2. **Add the zone in the Cloudflare dashboard** (Free plan) and set the two
   assigned Cloudflare nameservers at the registrar. Wait until the zone shows
   `active`.
3. **Grant the OpenTofu token access** to the new zone (see [API token](#opentofu-api-token)).
   If Caddy should issue certificates for it, its DNS-01 token on homestation
   also needs `DNS: Edit` on the zone.
4. **Declare the zone** in a new `opentofu/cloudflare/zone-<name>.tf`: zone ID
   and name, a `*_records` map, and the `zone-baseline` module. Look up the zone
   ID with the API call in the OpenTofu README. Existing records must be
   imported first, with a plan that shows no changes for them.
5. **If the domain sends no mail,** publish the lockdown records used for
   `nhanph.am`: null MX (`MX 0 .`), `v=spf1 -all`, DMARC
   `p=reject; sp=reject`, and an empty `*._domainkey` record. Replace them when
   mail moves to the domain.
6. `tofu plan`, review, `tofu apply`, then complete [DNSSEC](#dnssec).

## OpenTofu API token

OpenTofu uses its own Cloudflare token, separate from Caddy's DNS-01 token.
Create a **custom token** under *My Profile → API Tokens*:

| Permission | Level |
|---|---|
| Zone → Zone | Read |
| Zone → Zone Settings | Edit |
| Zone → DNS | Edit |
| Zone → Single Redirect | Edit |

Zone resources: *Include → Specific zone* once per managed zone, never *All
zones*. When adding a zone later, edit the token and add it there.

Store it in `secrets/operator/opentofu.yaml` under `cloudflare.api-token`.
Paste it into the sops editor so plaintext never touches disk or the shell
history:

```sh
sops secrets/operator/opentofu.yaml
```

To rotate, create the new token, replace the value the same way, run a
`tofu plan` to confirm it works, then revoke the old token in the dashboard.

## DNSSEC

`modules/zone-baseline` signs each zone unless the zone sets `dnssec = false`.
Signing becomes effective only after the registrar publishes Cloudflare's DS
record in the parent zone. Until then Cloudflare reports `pending`, and every
plan shows `status: "pending" -> "active"`; do not apply just for that drift.

### Publish the DS record

1. Read the values:

   ```sh
   tofu output dnssec_ds_records
   ```

   The output has the form `<zone>. 3600 IN DS <key tag> <algorithm> <digest type> <digest>`.

2. In the registrar's domain settings, find the form for **DS records** (often
   called DNSSEC control, custom DNSSEC, or secure DNS) and fill in one row:

   | Field | Value | Cloudflare default |
   |---|---|---|
   | Key tag | first number | changes per zone |
   | Algorithm | second number | `13 – ECDSAP256SHA256` |
   | Digest type | third number | `2 – SHA-256` |
   | Digest | the hex string | changes per zone |

   Tick the row's enable or validity checkbox if the form has one, then apply.
   Do **not** use a plain "enable DNSSEC" toggle without such fields: that is
   the registrar signing with its own nameservers and keys, which does not work
   with Cloudflare's nameservers.

3. If the registrar asks for the **DNSKEY** (public key, flags `257`) instead
   of a DS, fetch it from the Cloudflare API
   (`/zones/<ZONE_ID>/dnssec`, fields `public_key`, `flags`, `algorithm`).
   Some registries accept only DNSKEY material.

4. If the registrar cannot submit DNSSEC data for the TLD at all, set
   `dnssec = false` on that zone's `zone-baseline` module and apply. This
   applies to `npham.de` today. Without a DS record there is no outage risk;
   the zone is simply unsigned.

### Verify

Publication takes minutes to hours depending on the registry.

```sh
dig +short DS <domain> @1.1.1.1            # parent publishes the DS
dig +dnssec A <domain> @1.1.1.1 | grep flags  # "ad" flag = validated
```

DNSViz (`https://dnsviz.net/d/<domain>/dnssec/`) shows the full chain. Once the
DS is live, `tofu plan` reports no changes.

### Before moving a zone away from Cloudflare

Remove the DS record at the registrar first and wait at least a day (the DS
TTL plus resolver caches) before changing nameservers or setting
`dnssec = false`. Changing nameservers while the DS is still published takes the
domain offline for every validating resolver.
