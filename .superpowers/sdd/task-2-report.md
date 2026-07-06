Task 2 report

Commit
- `58adac6a` `refactor(homelab): add normalized internal graph`

Scope completed
- Updated [modules/nixos/homestation-homelab/lib.nix](/home/nhan/nix-config/modules/nixos/homestation-homelab/lib.nix) to add `appProjectName`, `serviceContainerName`, and the app-level `effectiveHost` helper from the brief.
- Added [modules/nixos/homestation-homelab/normalize.nix](/home/nhan/nix-config/modules/nixos/homestation-homelab/normalize.nix) to build `config.homestation.homelab._internal`.
- Updated [modules/nixos/homestation-homelab/default.nix](/home/nhan/nix-config/modules/nixos/homestation-homelab/default.nix) to import `./normalize.nix` and nothing else.

Verification
- `nix eval --impure --json --expr '<isolated evalModules probe>'`
  Result: passed.
  Evidence:
  - `enabledApps = ["docs","foo_bar"]`
  - `fooBarEnabledServices = ["web"]`
  - `fooBarHost = "example.com"`
  - `docsHost = "docs.example.com"`
  - `fooBarProjectName = "homelab-foo-bar"`
  - `fooBarWebContainerName = "foo-bar-web"`
  - `fooBarResolvedRoutes` fell back to the generated default route targeting `web`
  - `docsResolvedRoutes` preserved the explicit route
- `nix eval --impure --json --no-write-lock-file --expr 'let flake = builtins.getFlake (toString /home/nhan/nix-config); internal = flake.nixosConfigurations.homestation.config.homestation.homelab._internal; in { keys = builtins.attrNames internal; enabledApps = builtins.attrNames internal.enabledApps; }'`
  Result: failed in the live `homestation` config before `_internal.enabledApps` could fully evaluate.
  Blocker:
  - `The option homestation.homelab.apps.adguard-home.container does not exist`
  - This comes from the existing host configs still using the pre-Task-1 `container` / `containers` API while `options.nix` now only declares `services`, `expose`, and `routes`.

Notes
- The exact brief command with `--json` cannot serialize `config.homestation.homelab._internal` directly because `_internal` intentionally contains functions such as `appProjectName`, `serviceContainerName`, `effectiveHost`, `defaultRouteForApp`, and `resolvedRoutesForApp`.
- The brief also assumes `service.name` exists. In the current branch, `serviceType` in `options.nix` does not yet define that field, so the isolated verification added an eval-only shim for `services.*.name = null` to exercise `serviceContainerName` without changing out-of-scope files.

Self-review
- The owned-file implementation matches the Task 2 brief and keeps the `default.nix` scope expansion to a single import.
- I did not change downstream modules or public options.
- Remaining integration work is outside Task 2: migrate live host configs from `container` / `containers` to `services`, and add `service.name` to the public service schema if the controller still wants named container overrides.

Fix wave 2

Commit
- Pending local commit for the review-driven fix wave in `lib.nix`.

Findings addressed
- Restored the legacy `lib.nix` exports that unchanged downstream modules still import: `normalizedApps`, `appContainers`, `enabledApps`, `enabledContainersForApp`, `appNetworkName`, and `containerAttrName`.
- Kept `serviceContainerName` compatible with the current schema by deriving names from `appName` and `serviceName` only, without reading `service.name`.

Implementation notes
- The compatibility layer maps `app.services` to a legacy `containers` view inside `normalizedApps` so existing imports continue to resolve without editing downstream modules in this fix wave.
- `containerAttrName` preserves the old single-container naming behavior and still honors an explicit `name` only when that field is actually present on the passed attrset.

Verification
- `nix eval --impure --json --file /tmp/task2-isolated-probe.nix`
  Result: passed.
  Evidence:
  - `enabledApps = ["docs","foo_bar"]`
  - `fooBarEnabledServices = ["web"]`
  - `fooBarHost = "example.com"`
  - `docsHost = "docs.example.com"`
  - `fooBarProjectName = "homelab-foo-bar"`
  - `fooBarWebContainerName = "foo-bar-web"`
  - `fooBarResolvedRoutes` still falls back to the generated default route targeting `web`
  - `docsResolvedRoutes` still preserves the explicit route
- `nix eval --impure --json --no-write-lock-file --expr 'let flake = builtins.getFlake (toString /home/nhan/nix-config); internal = flake.nixosConfigurations.homestation.config.homestation.homelab._internal; in { keys = builtins.attrNames internal; enabledApps = builtins.attrNames internal.enabledApps; }'`
  Result: failed, unchanged broader blocker.
  Failure mode:
  - `The option homestation.homelab.apps.adguard-home.container does not exist`
  - Status change vs. previous run: no change; the live host config is still blocked before `_internal.enabledApps` can fully evaluate.
