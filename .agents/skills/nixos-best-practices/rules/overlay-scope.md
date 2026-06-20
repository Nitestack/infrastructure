---
title: Overlay Scope and useGlobalPkgs
impact: CRITICAL
impactDescription: The most common issue: overlays don't apply with useGlobalPkgs=true
tags: overlay,useglobalpkgs,home-manager,scope
---


## Why This Matters

When using Home Manager with NixOS, the `useGlobalPkgs` setting determines where overlay definitions must be placed. Defining overlays in the wrong location means they simply don't apply, leading to "package not found" errors even when the overlay syntax is correct.

## The Problem

When `useGlobalPkgs = true`, Home Manager uses NixOS's global `pkgs` instance. Overlays defined in `home.nix` are ignored because Home Manager isn't creating its own `pkgs` - it's using the system one.

## Incorrect: Overlay in home.nix with useGlobalPkgs=true

```nix
# hosts/home/default.nix
{
  home-manager.useGlobalPkgs = true;  # Using system pkgs
  home-manager.useUserPackages = true;
  home-manager.users.chumeng = import ./home.nix;
}

# home-manager/home.nix
{ config, pkgs, inputs, ... }:
{
  # ❌ This overlay is IGNORED when useGlobalPkgs = true!
  nixpkgs.overlays = [ inputs.claude-code.overlays.default ];

  home.packages = with pkgs; [
    claude-code  # Error: attribute 'claude-code' not found
  ];
}
```

**Why it fails:** When `useGlobalPkgs = true`, the `nixpkgs.overlays` line in `home.nix` has no effect. Home Manager isn't creating its own `pkgs`, so it can't apply overlays to one.

## Correct: Overlay in host home-manager block

```nix
# hosts/home/default.nix
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.chumeng = import ./home.nix;
  home-manager.extraSpecialArgs = { inherit inputs pkgs-stable system; };
  # ✅ Overlay defined HERE affects the global pkgs
  nixpkgs.overlays = [ inputs.claude-code.overlays.default ];
}

# home-manager/home.nix
{ config, pkgs, ... }:
{
  # No overlay definition needed here
  home.packages = with pkgs; [
    claude-code  # ✅ Works! Found via overlay
  ];
}
```

**Why it works:** The overlay is defined where Home Manager configures the `pkgs` instance it will use. When `useGlobalPkgs = true`, this means the overlay is applied to the system's package set.

## Alternative: Set useGlobalPkgs=false

If you want to define overlays in `home.nix`, set `useGlobalPkgs = false`:

```nix
# hosts/home/default.nix
{
  home-manager.useGlobalPkgs = false;  # Home Manager creates own pkgs
  home-manager.useUserPackages = true;
  home-manager.users.chumeng = import ./home.nix;
}

# home-manager/home.nix
{ pkgs, inputs, ... }:
{
  # ✅ This works when useGlobalPkgs = false
  nixpkgs.overlays = [ inputs.claude-code.overlays.default ];

  home.packages = with pkgs; [
    claude-code  # ✅ Works! Found via overlay
  ];
}
```

**Trade-off:** This creates a separate package set for Home Manager, which means packages are built twice (once for system, once for Home Manager). Only use this when you truly need separate package sets.

## Decision Matrix

| Your Need | useGlobalPkgs | Overlay Location |
|-----------|---------------|------------------|
| Single-user system, efficiency | `true` | Host home-manager block |
| Multi-user, different packages per user | `false` | User's home.nix |
| Custom packages system-wide | `true` | System nixpkgs.overlays |
| Quick prototype | `false` | User's home.nix |

## Verification

After adding an overlay, verify it works:

```bash
# Build the configuration
nixos-rebuild build --flake .#hostname

# Check if package is available
./result/sw/bin/package-name --version

# Or use nix repl to verify
nix repl
nix-repl> :l flake.nix
nix-repl> homeConfigs.hostname.config.home-manager.users.username.pkgs.package-name
```

## Common Mistakes

1. **Adding overlay both places**: Don't define the same overlay in both host config AND home.nix. It will apply twice and may cause conflicts.

2. **Forgetting to pass inputs**: If your overlay needs `inputs.*`, ensure `inputs` is in `extraSpecialArgs`:
   ```nix
   home-manager.extraSpecialArgs = { inherit inputs; };
   ```

3. **Not rebuilding system**: Overlays defined in host config require full system rebuild, not just `home-manager switch`.

## References

- [Home Manager Manual - useGlobalPkgs](https://nix-community.github.io/home-manager/options.html#opt-home-manager.useGlobalPkgs)
- [NixOS Manual - Overlays](https://nixos.org/manual/nixos/stable/options#opt-nixpkgs.overlays)
