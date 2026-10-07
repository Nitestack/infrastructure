# Configuration Entry Points

This subtree defines host choices and Home Manager profiles. Keep reusable
behaviour in `modules/`.

## Ownership

- `configurations/nixos/<host>/` owns NixOS host wiring, hardware references,
  host-specific services, storage, and packages.
- `configurations/home/*.nix` contains profiles imported by host entries. A
  profile change can affect every host that imports it, so trace its imports
  before editing.
- `hardware-configuration.nix` files are generated inputs. Change them only
  for an intentional hardware or filesystem update.
- Host `sops.nix` files declare secret paths and templates; secret values stay
  in encrypted files under `secrets/`.

## Verification

Run checks from the repository root. For a NixOS target, evaluate the exact
host rather than relying only on a generic flake check:

```sh
nix run .#check
nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath --no-write-lock-file
```

Read the deeper NixOS and host guides before changing `configurations/nixos/`.
