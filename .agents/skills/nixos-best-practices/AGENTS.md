# NixOS Configuration Best Practices

Complete guide for configuring NixOS systems with flakes, managing overlays, and structuring configurations.

## Table of Contents

- [Overview](#overview)
- [When to Use](#when-to-use)
- [Essential Pattern](#essential-pattern-overlay-scope-and-useglobalpkgs)
- [Flakes Structure](#flakes-configuration-structure)
- [Host Organization](#host-configuration-organization)
- [Package Installation](#package-installation-best-practices)
- [Common Mistakes](#common-configuration-mistakes)
- [Troubleshooting](#troubleshooting-configuration-issues)
- [Real-World Impact](#real-world-impact)

---

## Overview

**Core principle:** Understand the interaction between NixOS system configuration and Home Manager overlays.

When `useGlobalPkgs = true`, overlays must be defined at the NixOS configuration level, not in Home Manager configuration files.

---

## When to Use

**Use when:**
- Configuring NixOS with flakes and Home Manager
- Adding overlays that don't seem to apply
- Using `useGlobalPkgs = true` with custom overlays
- Structuring NixOS configurations across multiple hosts
- Package changes not appearing after rebuild
- Confused about where to define overlays

**Don't use for:**
- Packaging new software (use nix-packaging-best-practices)
- Simple package installation without overlays
- NixOS module development (see NixOS module documentation)

---

## Essential Pattern: Overlay Scope and useGlobalPkgs

### Why This Matters

When using Home Manager with NixOS, the `useGlobalPkgs` setting determines where overlay definitions must be placed. Defining overlays in the wrong location means they simply don't apply, leading to "package not found" errors even when the overlay syntax is correct.

### The Problem

When `useGlobalPkgs = true`, Home Manager uses NixOS's global `pkgs` instance. Overlays defined in `home.nix` are ignored because Home Manager isn't creating its own `pkgs` - it's using the system one.

### Incorrect: Overlay in home.nix with useGlobalPkgs=true

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

### Correct: Overlay in host home-manager block

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

### Alternative: Set useGlobalPkgs=false

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

### Decision Matrix

| Your Need | useGlobalPkgs | Overlay Location |
|-----------|---------------|------------------|
| Single-user system, efficiency | `true` | Host home-manager block |
| Multi-user, different packages per user | `false` | User's home.nix |
| Custom packages system-wide | `true` | System nixpkgs.overlays |
| Quick prototype | `false` | User's home.nix |

---

## Flakes Configuration Structure

### Core Structure

```nix
{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Add other flake inputs here
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ ./hosts/hostname ];
    };
  };
}
```

### Special Args Pattern

Pass `inputs` via `specialArgs` to make flake inputs available in modules:

```nix
# ❌ WRONG: Forgetting specialArgs
outputs = { self, nixpkgs, home-manager }:
{
  nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
    modules = [ ./hosts/myhost ];  # inputs not available!
  };
}

# ✅ CORRECT: Using specialArgs
outputs = { self, nixpkgs, home-manager, ... }@inputs:
{
  nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [ ./hosts/myhost ];  # inputs available!
  };
}
```

### Input Following

Set `inputs.nixpkgs.follows` to avoid duplicate nixpkgs instances:

```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  # ❌ WRONG: Doesn't follow, creates duplicate nixpkgs
  home-manager.url = "github:nix-community/home-manager/release-25.05";

  # ✅ CORRECT: Follows nixpkgs, uses same instance
  home-manager.url = "github:nix-community/home-manager/release-25.05";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";
};
```

---

## Host Configuration Organization

### Directory Structure

```
nixos-config/
├── flake.nix                    # Top-level flake
├── hosts/
│   ├── laptop/
│   │   ├── default.nix          # Host-specific config
│   │   ├── hardware-configuration.nix  # Generated (don't edit)
│   │   └── home.nix             # Home Manager config
│   ├── desktop/
│   │   ├── default.nix
│   │   ├── hardware-configuration.nix
│   │   └── home.nix
│   └── base.nix                 # Shared by all hosts (optional)
├── modules/                     # Reusable NixOS modules
├── overlays/                    # Custom overlays
├── home-manager/                # Shared Home Manager configs
│   ├── shell/
│   ├── applications/
│   └── common.nix
└── secrets/                     # Age-encrypted secrets
```

### Host Configuration Pattern

```nix
# hosts/laptop/default.nix
{ inputs, pkgs, pkgs-stable, system, ... }:
{
  imports = [
    ./hardware-configuration.nix  # Import hardware config
    ../base.nix                  # Import shared config
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.john = import ./home.nix;
      home-manager.extraSpecialArgs = {
        inherit inputs pkgs-stable system;
      };
      nixpkgs.overlays = [ inputs.some-overlay.overlays.default ];
    }
  ];

  # Host-specific config only
  networking.hostName = "laptop";
}
```

### Shared Base Configuration

```nix
# hosts/base.nix
{ config, pkgs, inputs, ... }:
{
  # Network
  networking.networkmanager.enable = true;

  # Time and locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Users (shared across all hosts)
  users.users.john = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Common packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    tmux
  ];

  # Common services
  services.openssh.enable = true;

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

**Important:** Don't edit `hardware-configuration.nix` manually. It's generated by `nixos-generate-config` and should be replaced when hardware changes.

---

## Package Installation Best Practices

### System vs User Packages

**System Packages (NixOS)** - Use for:
- System services (servers, daemons)
- Packages needed by all users
- Hardware-related packages (drivers, firmware)

```nix
# hosts/base.nix or host-specific default.nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim          # Available to all users
    git
    wget
  ];
}
```

**User Packages (Home Manager)** - Use for:
- User-specific applications
- Desktop applications
- Development tools (user-specific)

```nix
# home-manager/home.nix or sub-configs
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    vscode       # User-specific
    chrome
  ];
}
```

### Installing from Different Nixpkgs Channels

```nix
# flake.nix - default is unstable
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
};

# Host config
{ pkgs, pkgs-stable, ... }:
{
  environment.systemPackages = with pkgs; [
    vim              # From unstable (default)
  ];

  environment.systemPackages = with pkgs-stable; [
    vim             # From stable
  ];
}
```

---

## Common Configuration Mistakes

### Mistake 1: Overlay in Wrong Location

**Symptom:** Package not found even though overlay is defined.

**Solution:** Move overlay to host's home-manager configuration block.

```nix
# ❌ WRONG: home-manager/home.nix
{
  nixpkgs.overlays = [ inputs.overlay.overlays.default ];
}

# ✅ CORRECT: hosts/home/default.nix
{
  home-manager.nixpkgs.overlays = [ inputs.overlay.overlays.default ];
}
```

### Mistake 2: Forgetting specialArgs

**Symptom:** `undefined variable 'inputs'` error.

**Solution:** Add `specialArgs = { inherit inputs; }`.

```nix
# ❌ WRONG
outputs = { self, nixpkgs, home-manager }:
{
  nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
    modules = [ ./hosts/myhost ];
  };
}

# ✅ CORRECT
outputs = { self, nixpkgs, home-manager, ... }@inputs:
{
  nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [ ./hosts/myhost ];
  };
}
```

### Mistake 3: Editing hardware-configuration.nix

**Symptom:** Hardware changes lost after running `nixos-generate-config`.

**Solution:** Put custom config in `default.nix`, not `hardware-configuration.nix`.

### Mistake 4: Duplicate Package Declarations

**Symptom:** Same package in both system and Home Manager config.

**Solution:** Install in appropriate location only.

```nix
# ❌ WRONG
# hosts/base.nix
environment.systemPackages = with pkgs; [ firefox ];

# home-manager/home.nix
home.packages = with pkgs; [ firefox ];  # Duplicate!

# ✅ CORRECT: Choose one location
home.packages = with pkgs; [ firefox ];
```

### Mistake 5: Not Following nixpkgs

**Symptom:** Slow builds, inconsistent packages.

**Solution:** Use `.follows` for dependency inputs.

```nix
# ❌ WRONG
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  home-manager.url = "github:nix-community/home-manager/release-25.05";
};

# ✅ CORRECT
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  home-manager.url = "github:nix-community/home-manager/release-25.05";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";
};
```

---

## Troubleshooting Configuration Issues

### General Approach

1. **Read error messages completely** - They usually tell you exactly what's wrong
2. **Verify syntax** - Check for missing brackets, quotes, commas
3. **Validate config** - Use `nixos-rebuild test` first
4. **Check scope** - Is overlay/module in correct location?
5. **Trace dependencies** - Are required inputs/imports present?

### Common Error Patterns

**"undefined variable 'inputs'"**

Add to flake.nix:
```nix
specialArgs = { inherit inputs; };
```

**"attribute 'package-name' not found"**

Check if overlay is defined in correct location based on `useGlobalPkgs` setting.

**"error: The option 'some.option' does not exist"**

Search for option:
```bash
nixos-options | grep some-option
```

**"infinite recursion"**

Use --show-trace:
```bash
nixos-rebuild build --flake .#hostname --show-trace
```

### Configuration Changes Not Applying

```bash
# Verify rebuild succeeded
sudo nixos-rebuild switch --flake .#hostname

# Check current generation
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Verify new generation is active
nixos-version
```

### Useful Verification Commands

```bash
# Check configuration without building
nix flake check
nixos-rebuild build --flake .#hostname --dry-run

# Evaluate specific option
nix eval .#nixosConfigurations.myhost.config.environment.systemPackages

# Test configuration safely
nixos-rebuild test --flake .#hostname  # Rollback on reboot
nixos-rebuild switch --flake .#hostname  # Persistent
```

---

## Real-World Impact

Following these best practices prevents the most common NixOS configuration issues:

**Before:**
- Users spend hours debugging why overlays don't apply
- Configuration is duplicated across hosts
- Changes don't apply after editing files
- Confusion about where to define overlays

**After:**
- Clear understanding of overlay scope
- Modular, maintainable configuration structure
- Predictable behavior
- Easy debugging when issues arise

The overlay scope issue alone accounts for ~80% of NixOS + Home Manager configuration problems encountered by users.
