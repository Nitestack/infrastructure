Task 1 report

Status: completed with one controller-approved deviation.

Changes made:
- Replaced the public app schema in `modules/nixos/homestation-homelab/options.nix` with:
  - `apps.<app>.services.<service>`
  - app-level `apps.<app>.expose`
  - app-level `apps.<app>.routes`
- Added the new public service sub-options required by the brief:
  - `healthcheck`
  - `dependsOn`
  - `runtime`
  - `privileges`
  - explicit volume kinds via `volumes[*].type = "bind" | "library" | "volume"`
- Kept `expose.port` out of the new public app-level schema.

Controller-resolved contradiction:
- The brief required `default.nix` to import future `normalize.nix` and `arion.nix` entrypoints, but those files do not exist yet and importing them would fail this task's required eval.
- Controller instruction was to optimize for passing Task 1 evaluation.
- Result: `modules/nixos/homestation-homelab/default.nix` was left valid for today's tree and future imports were not added yet.

Compatibility note:
- Current `homestation` configuration and downstream module files still consume the old OCI `apps.<app>.container` / `apps.<app>.containers` paths.
- To keep the focused eval passing without editing other files, I retained temporary internal compatibility declarations for those legacy paths in `options.nix`.
- They are marked `visible = false; internal = true;`, but they still exist as compatibility shims until later tasks migrate the backend readers.

Validation run:
- `nix eval .#nixosConfigurations.homestation.options.homestation.homelab --json --no-write-lock-file`
- Result: passed

Self-review:
- Public option surface for new work is present under `apps -> expose/routes/services`.
- `default.nix` was intentionally not switched to nonexistent future modules.
- Known follow-up for later tasks: remove the temporary legacy compatibility declarations once backend readers stop depending on them.
