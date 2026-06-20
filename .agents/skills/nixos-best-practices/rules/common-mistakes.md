---
title: Common Configuration Mistakes
impact: HIGH
impactDescription: Prevents the most frequently made configuration errors
tags: mistakes,pitfalls,errors,checklist
---


## Why This Matters

Understanding common mistakes helps avoid them, saving time and preventing configuration errors.

## Mistake 1: Overlay in Wrong Location

### Symptom
Package not found even though overlay is defined.

### Cause
Overlay defined in `home.nix` when `useGlobalPkgs = true`.

### Solution
Move overlay to host's home-manager configuration block.

```nix
# ❌ WRONG
# home-manager/home.nix
{
  nixpkgs.overlays = [ inputs.overlay.overlays.default ];
}

# ✅ CORRECT
# hosts/home/default.nix
{
  home-manager.nixpkgs.overlays = [ inputs.overlay.overlays.default ];
}
```

**See:** [overlay-scope.md](overlay-scope.md)

## Mistake 2: Forgetting specialArgs

### Symptom
`undefined variable 'inputs'` error.

### Cause
Not passing `inputs` via `specialArgs`.

### Solution
Add `specialArgs = { inherit inputs; }`.

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

**See:** [flakes-structure.md](flakes-structure.md)

## Mistake 3: Editing hardware-configuration.nix

### Symptom
Hardware changes lost after running `nixos-generate-config`.

### Cause
Manually editing generated file.

### Solution
Put custom config in `default.nix`, not `hardware-configuration.nix`.

```nix
# ❌ WRONG: Editing hardware-configuration.nix
# hosts/laptop/hardware-configuration.nix
{ config, lib, pkgs, modulesPath, ... }:
{
  # My custom kernel parameters (will be lost!)
  boot.kernelParams = [ "intel_iommu=on" ];

  # Generated hardware config...
}

# ✅ CORRECT: Custom config in default.nix
# hosts/laptop/default.nix
{
  imports = [ ./hardware-configuration.nix ];

  # Custom kernel parameters (safe!)
  boot.kernelParams = [ "intel_iommu=on" ];
}
```

**See:** [host-organization.md](host-organization.md)

## Mistake 4: Duplicate Package Declarations

### Symptom
Package installed multiple times or conflicts.

### Cause
Same package in both system and Home Manager config.

### Solution
Install in appropriate location only.

```nix
# ❌ WRONG: Same package in both places
# hosts/base.nix
environment.systemPackages = with pkgs; [ firefox ];

# home-manager/home.nix
home.packages = with pkgs; [ firefox ];  # Duplicate!

# ✅ CORRECT: Choose one location
# User apps in Home Manager
home.packages = with pkgs; [ firefox ];
```

**See:** [package-installation.md](package-installation.md)

## Mistake 5: Not Following nixpkgs

### Symptom
Slow builds, inconsistent packages.

### Cause
Multiple independent nixpkgs instances.

### Solution
Use `.follows` for dependency inputs.

```nix
# ❌ WRONG: Independent nixpkgs
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  home-manager.url = "github:nix-community/home-manager/release-25.05";
  # home-manager will use its own nixpkgs!
};

# ✅ CORRECT: Follow nixpkgs
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  home-manager.url = "github:nix-community/home-manager/release-25.05";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";
};
```

**See:** [flakes-structure.md](flakes-structure.md)

## Mistake 6: Mixing System and User Concerns

### Symptom
User-specific config in system files or vice versa.

### Cause
Not understanding NixOS vs Home Manager responsibilities.

### Solution
System config in NixOS, user config in Home Manager.

```nix
# ❌ WRONG: User config in system
# hosts/base.nix
{
  # User's git config (should be in Home Manager)
  programs.git = {
    enable = true;
    userName = "john";
    userEmail = "john@example.com";
  };
}

# ✅ CORRECT: User config in Home Manager
# home-manager/home.nix
{
  programs.git = {
    enable = true;
    userName = "john";
    userEmail = "john@example.com";
  };
}
```

**See:** [package-installation.md](package-installation.md)

## Mistake 7: Forgetting to Rebuild

### Symptom
Changes don't appear after editing config.

### Cause
Editing config but not running rebuild.

### Solution
Always rebuild after config changes.

```bash
# After editing NixOS config
sudo nixos-rebuild switch --flake .#hostname

# After editing Home Manager config (standalone)
home-manager switch --flake .#hostname

# When using NixOS-integrated Home Manager
sudo nixos-rebuild switch --flake .#hostname
```

## Mistake 8: Overriding systemPackages Multiple Times

### Symptom
Some packages disappear after adding others.

### Cause
Multiple `environment.systemPackages` assignments.

### Solution
Use single list or mkBefore/mkAfter.

```nix
# ❌ WRONG: Multiple assignments
environment.systemPackages = with pkgs; [ vim git ];
environment.systemPackages = with pkgs; [ htop ];  # Overwrites!

# ✅ CORRECT: Single list
environment.systemPackages = with pkgs; [
  vim
  git
  htop
];

# ✅ ALSO CORRECT: Use mkBefore/mkAfter
environment.systemPackages = with pkgs; [ vim git ];
environment.systemPackages = mkAfter [ pkgs.htop ];
```

## Mistake 9: Hardcoding Paths

### Symptom
Config breaks on different machines.

### Cause
Using absolute paths instead of Nix paths.

### Solution
Use relative paths or Nix constructs.

```nix
# ❌ WRONG: Absolute path
{ pkgs, ... }:
{
  environment.systemPackages = [
    "/home/john/my-app/bin/my-app"  # Only works for john!
  ];
}

# ✅ CORRECT: Use Nix package
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.my-app ];
}

# ✅ OR: Use path from flake
{ ... }:
{
  environment.systemPackages = [
    (pkgs.callPackage ./local-packages/my-app { })
  ];
}
```

## Mistake 10: Not Using Flake References

### Symptom
Can't use packages from flake inputs.

### Cause
Not passing inputs or using wrong reference.

### Solution
Use `inputs.*` syntax.

```nix
# ❌ WRONG: Trying to use input package
{ pkgs, ... }:
{
  environment.systemPackages = [
    unfire-overlay  # Where does this come from?
  ];
}

# ✅ CORRECT: Use input reference
{ pkgs, inputs, ... }:
{
  environment.systemPackages = [
    inputs.unfire-overlay.packages.${pkgs.system}.default
  ];
}
```

## Mistake 11: Confusing Module Import Paths

### Symptom
`error: path '.../module-name' does not exist`

### Cause
Using wrong import syntax for file vs directory in `imports` list.

### Solution
Use `./module-name.nix` for files, `./module-name/` for directories.

```nix
# ❌ WRONG: File imported as directory
# hosts/home/default.nix
{
  imports = [
    ./hardware-configuration.nix
    ./agent-browser  # Looks for agent-browser/default.nix, not agent-browser.nix!
  ];
}

# ✅ CORRECT: Include file extension
{
  imports = [
    ./hardware-configuration.nix
    ./agent-browser.nix  # Imports agent-browser.nix file
  ];
}

# ✅ ALSO CORRECT: Directory import
# Directory structure:
# modules/
#   agent-browser/
#     default.nix
{
  imports = [
    ./modules/agent-browser  # Imports modules/agent-browser/default.nix
  ];
}
```

**Rule**: In Nix `imports`:
- `./name` → looks for `name/default.nix`
- `./name.nix` → looks for `name.nix` file

## Mistake 12: Using Non-Existent Home Manager Options

### Symptom
`error: The option 'programs.xxx' does not exist` or similar.

### Cause
Assuming an option exists without checking nixpkgs/Home Manager documentation.

### Solution
**ALWAYS verify options exist before using them:**

```bash
# Check if option exists in Home Manager
nix eval nixpkgs#home-manager.options.programs.npm.enable

# Search for available options
nix search nixpkgs home-manager programs

# Check package attributes
nix eval nixpkgs#pkgs.hello.outputs
```

**Common non-existent options to avoid:**
- `programs.npm` - doesn't exist, use `home.file.".npmrc"` instead
- `buildFHSUserEnv` in Home Manager pkgs - not available, use system-level or different approach

### Correct Approach

```nix
# ❌ WRONG: Using non-existent option
{
  programs.npm.enable = true;  # Error!
}

# ✅ CORRECT: Use home.file for config files
{
  home.file.".npmrc".text = ''
    prefix=$HOME/.npm-global
  '';
}

# ✅ CORRECT: Check what's available first
# Run: nix search nixpkgs home-manager programs
```

**Rule:** Before using ANY option or function:
1. Check if it exists in nixpkgs/Home Manager
2. Read examples from official docs
3. Look at working configurations in the codebase

## Quick Checklist

Before committing config changes:

- [ ] Overlay in correct location for useGlobalPkgs setting
- [ ] inputs passed via specialArgs if needed
- [ ] Not editing hardware-configuration.nix
- [ ] No duplicate package declarations
- [ ] Following nixpkgs for dependency inputs
- [ ] System config separate from user config
- [ ] Tested with rebuild
- [ ] Using Nix paths, not absolute paths
- [ ] Correct input references for flake packages
- [ ] Import paths match file/directory structure (include .nix for files)
- [ ] Verified options exist in nixpkgs/Home Manager before using
- [ ] Checked for missing libraries with `ldd` before rebuilding
