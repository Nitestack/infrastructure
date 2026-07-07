Task 4 report: Replace OCI Generation With Arion Projects

Summary
- Added the `arion` flake input in `flake.nix`.
- Imported `flake.inputs.arion.nixosModules.arion` on `homestation`.
- Replaced `virtualisation.oci-containers.backend = "docker";` with `virtualisation.arion.backend = "docker";` on `homestation`.
- Swapped `modules/nixos/homestation-homelab/default.nix` to import `./arion.nix` instead of `./containers.nix`.
- Removed `modules/nixos/homestation-homelab/containers.nix`.
- Added `modules/nixos/homestation-homelab/arion.nix` to generate one Arion project per enabled app from `config.homestation.homelab._internal`.

Arion mapping implemented
- Project key/name: `internal.appProjectName appName`
- Service key/value shape: `settings.services.<serviceName>.service = { ... }`
- Volume mapping:
  - `bind` -> `${cfg.dataDir}/${appName}/${volume.source}` for relative sources, absolute path preserved
  - `library` -> `cfg.libraries.${volume.name}.path`
  - `volume` -> named volume
- Container naming: `internal.serviceContainerName appName serviceName service`
- Dependency mapping: `dependsOn` -> `depends_on.<service>.condition`
- Healthchecks mapped when `test != null`
- Runtime/privilege fields mapped where the real Arion typed service interface supports them
- `runtime.init` intentionally omitted per follow-up instruction
- Capabilities mapped through Arion `capabilities = { ... }`, which emits `cap_add` / `cap_drop`
- Edge network declared as an external Arion network only for apps whose exposed routes target a given service

Verification
1. Isolated Arion generation eval: passed

Command run:
`nix eval --impure --json --expr '<isolated nixosSystem expression>'`

Result highlights:
- Produced `virtualisation.arion.projects."homelab-demo".settings.out.dockerComposeYamlAttrs`
- Confirmed:
  - `networks.default.name = "homelab-demo"`
  - `networks.homelab-edge.external = true`
  - `services.web.container_name = "demo-web"`
  - `services.web.expose = [ "8080" ]`
  - `services.web.volumes = [ "/var/lib/homelab/demo/data:/data" "/srv/media:/media:ro" "cache:/cache" ]`
  - capability translation emitted compose `cap_add = [ "SYS_ADMIN" ]` and `cap_drop = [ "NET_RAW" ]`
  - `services.db.network_mode = "host"`

2. Requested host eval: still blocked by expected transitional state outside owned files

Command run:
`nix eval .#nixosConfigurations.homestation.config.virtualisation.arion.projects --json --no-write-lock-file`

Result:
- Failed before Arion project output due existing unmigrated app definitions such as:
  - `configurations/nixos/homestation/homelab/adguard-home.nix`
  - error: `The option homestation.homelab.apps.adguard-home.container does not exist`
- This matches the task brief warning that old `container` / `containers` usage outside the owned set may still block full host eval.

Additional blocker outside owned files
- `modules/nixos/homestation-homelab/validation.nix` still asserts:
  - `config.virtualisation.oci-containers.backend == "docker"`
- Task 4 intentionally replaced the homestation host backend setting with:
  - `virtualisation.arion.backend = "docker"`
- I did not edit `validation.nix` because it is outside the owned file set.

Self-review
- Confirmed only owned code files were committed.
- Confirmed `flake.lock` was not kept modified.
- Confirmed Arion integration uses the real upstream interface:
  - flake import path: `inputs.arion.nixosModules.arion`
  - service capability mapping via Arion typed `capabilities`
  - external edge network declared via Arion typed `networks`

Commit
- `f085ce0d feat(homelab): add arion projects`

Local fix wave

Scope completed
- Restored `virtualisation.oci-containers.backend = "docker";` alongside `virtualisation.arion.backend = "docker";` in `configurations/nixos/homestation/default.nix` so the still-out-of-scope backend assertion in `validation.nix` does not fail the transitional host config.
- Updated `modules/nixos/homestation-homelab/arion.nix` to carry `ports = service.ports` directly when present, while keeping `service.port` solely for internal service exposure (`expose = [ toString service.port ]`).

Verification
- `git diff --check -- modules/nixos/homestation-homelab/arion.nix configurations/nixos/homestation/default.nix`
  Result: passed.
- `nix eval .#nixosConfigurations.homestation.config.virtualisation.arion.projects --json --no-write-lock-file`
  Result: still fails in the known cross-task transitional state.
  Failure:
  - `The option homestation.homelab.apps.adguard-home.container does not exist`
  - This is the expected Task 6 blocker from unmigrated host app definitions, not the previous backend-setting mismatch.
