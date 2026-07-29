# Operations

This runbook covers routine configuration changes for the machines managed by
this flake. It is for normal operations, not first installation; follow the
host-specific setup instructions in the [README](../README.md) for that.

## Before activating a change

From the repository root, format and evaluate the flake before changing a
machine:

```sh
nix fmt
nix run .#check
```

For a host-specific change, also evaluate its target. These checks evaluate
without building an entire system or modifying `flake.lock`:

```sh
nix eval .#nixosConfigurations.nixstation.config.system.build.toplevel.drvPath --no-write-lock-file
nix eval .#darwinConfigurations.macstation.system --apply 's: s.drvPath' --no-write-lock-file
```

Run configuration activation on the host being changed. Review the diff first
and make sure the intended host name is used.

## Activate a configuration

### NixOS desktop

```sh
sudo nixos-rebuild switch --flake .#nixstation
```

### Homestation

Run this on `homestation` after validating the homelab change. See
[Homestation operations](homestation-operations.md) for service checks after
activation.

```sh
sudo nixos-rebuild switch --flake .#homestation
```

### NixOS-WSL

For ordinary changes in the running WSL instance:

```sh
sudo nixos-rebuild switch --flake .#wslstation
```

The first-install flow intentionally uses `boot` and terminates the WSL
instance; retain that sequence from the [README](../README.md).

### macOS

```sh
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#macstation
```

## Update inputs deliberately

Configuration activation uses the locked inputs already in `flake.lock`.
Updating inputs is a separate, reviewable change. The shared system profile
provides `nix-flake-update`, which updates the lock file and commits that
change. It expects this repository at `~/infrastructure`:

```sh
nix-flake-update
```

Run it only when an input update is intended. Inspect the lock-file diff, run
the checks above, then activate each affected host. Container image updates are
normally proposed by Renovate; see [Renovate setup](renovate-setup.md).

## Recover from an unsuccessful activation

Do not delete generations or reset the repository while investigating a failed
activation.

For NixOS, inspect the error, correct the configuration, and rebuild. If the
new generation was activated but needs to be undone immediately, switch back to
the previous generation:

```sh
sudo nixos-rebuild switch --rollback
```

If the machine cannot boot the current generation, select a previous generation
from the boot menu. On WSL, terminate and restart the distribution after a
`boot`-based change.

For macOS, keep the last known-good nix-darwin generation available and consult
the installed `darwin-rebuild` help before rolling back; its generation commands
must be run on the Mac.

## Related runbooks

- [Secrets](secrets.md) — bootstrap and maintain encrypted configuration.
- [Homestation operations](homestation-operations.md) — inspect the server,
  its ingress, and containerized services.
- [Cloudflare edge](../opentofu/cloudflare/README.md) — manage DNS and edge
  state separately from NixOS activation.
