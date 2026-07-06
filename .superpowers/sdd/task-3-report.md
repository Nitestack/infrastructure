Task 3 report

Commit
- `0fbcd6f1` `refactor(homelab): validate normalized service graph`

Scope completed
- Rebuilt [modules/nixos/homestation-homelab/validation.nix](/home/nhan/nix-config/modules/nixos/homestation-homelab/validation.nix) around `config.homestation.homelab._internal` instead of the legacy container graph.
- Replaced container-form assertions with app/service assertions for:
  - app exposure host requirements
  - resolved route presence and `expose.service` fallback rules
  - route upstream service and port validation
  - service `dependsOn` existence checks
  - service volume `type/source/name` validation
- Preserved the still-valid top-level/global checks that fit the normalized model:
  - SMTP all-or-nothing config
  - Docker backend requirement
  - generated Caddy vs native `services.caddy`
  - duplicate exposed host detection
  - non-empty network prefix
  - wildcard ingress prerequisites

Verification
- `nix flake check --no-build --no-write-lock-file`
  Result: failed before reaching this module's evaluation.
  Failure:
  - `error: path 'wyvvqshiam1w483dpxif4cl9a98sy5sm-b5znmvyi362n69x9h980777a7kd35k1g-source' is not valid`
- `nix-instantiate --parse modules/nixos/homestation-homelab/validation.nix`
  Result: passed.
- `git diff --check -- modules/nixos/homestation-homelab/validation.nix`
  Result: passed.

Notes
- I did not edit any homelab module files outside the owned file.
- The brief snippet used boolean implication syntax for `app.routes == [ ] -> ...`; the implemented assertion uses the equivalent valid Nix form:
  - `app.routes != [ ] || app.expose.service != null`

Self-review
- The file now consumes only `_internal.enabledApps`, `_internal.enabledServicesForApp`, `_internal.effectiveHost`, and `_internal.resolvedRoutesForApp` for graph-aware validation.
- Legacy container-only assertions for listeners, generated container names, container DNS records, mixed container forms, and old per-container fields were removed because they no longer match the normalized app/service model required by Tasks 1-2.
- Remaining verification is blocked by the flake input/store-path issue above, not by a syntax error in `validation.nix`.

Fix wave

Scope completed
- Restored the per-app runtime assertion in [modules/nixos/homestation-homelab/validation.nix](/home/nhan/nix-config/modules/nixos/homestation-homelab/validation.nix) so `apps.<name>.expose.mode = "public"` requires `homestation.homelab.cloudflared.wildcardIngress = true`.
- Updated the Validation section in [docs/homelab-services.md](/home/nhan/nix-config/docs/homelab-services.md) to document the current runtime assertions, including the restored public-ingress requirement and the normalized app/service graph checks.

Verification
- `nix flake check --no-build --no-write-lock-file`
  Result: retried after the fix and still failed before module evaluation with the same external flake/store-path class of blocker.
  Failure:
  - `error: path '2s7yn529m0yy2nwngfg3b2vz890rwwmp-4ahvrb9d6dgmv6xw1j9b8sjzgiqdws05-source' is not valid`
- `nix-instantiate --parse modules/nixos/homestation-homelab/validation.nix`
  Result: passed.
- `git diff --check -- modules/nixos/homestation-homelab/validation.nix docs/homelab-services.md`
  Result: passed.

Notes
- The required flake check was attempted both before and after the fix; both runs were blocked before reaching module evaluation by an invalid external store path, so there is still no end-to-end module-evaluation evidence from `nix flake check`.
