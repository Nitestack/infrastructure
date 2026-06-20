---
title: Flakes Configuration Structure
impact: CRITICAL
impactDescription: Foundation of flake-based NixOS configurations
tags: flakes,special-args,inputs,multiple-hosts
---


## Why This Matters

A well-structured flake.nix makes it easy to manage multiple hosts, share common configurations, and maintain the codebase. Poor structure leads to duplication and confusion.

## Core Structure

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

## Special Args Pattern

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

Then use in modules:

```nix
# hosts/myhost/default.nix
{ inputs, pkgs, ... }:
{
  # Can now use inputs.*
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
}
```

## Input Following

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

## Multiple Hosts Pattern

```nix
outputs = { self, nixpkgs, home-manager, ... }@inputs: {
  # Define multiple hosts
  nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [ ./hosts/laptop ];
  };

  nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [ ./hosts/desktop ];
  };

  nixosConfigurations.server = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [ ./hosts/server ];
  };
};
```

## System-Specific Packages

Pass system-specific args like `pkgs-stable`:

```nix
outputs = { self, nixpkgs, nixpkgs-stable, home-manager, ... }@inputs:
let
  system = "x86_64-linux";
in
{
  nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs system;
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
    };
    modules = [ ./hosts/myhost ];
  };
};
```

Usage in host config:

```nix
# hosts/myhost/default.nix
{ inputs, pkgs, pkgs-stable, system, ... }:
{
  environment.systemPackages = with pkgs; [
    unstable-package  # From nixos-unstable
  ];

  # Or use stable version
  environment.systemPackages = with pkgs-stable; [
    stable-package
  ];
}
```

## Common Mistakes

1. **Not using @inputs pattern**: Forgetting to capture all inputs in a set makes it impossible to reference new inputs without updating the function signature.

2. **Missing specialArgs**: Inputs won't be available in modules without `specialArgs = { inherit inputs; }`.

3. **Hardcoded system**: Avoid hardcoding `x86_64-linux` multiple times. Define once and reuse.

4. **Not following nixpkgs**: Leads to multiple nixpkgs evaluations, slower builds, and potential inconsistencies.

## Quick Template

```nix
{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Add more inputs here
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        system = "x86_64-linux";
        pkgs-stable = import inputs.nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      modules = [ ./hosts/myhost ];
    };
  };
}
```
