---
title: Package Installation Best Practices
impact: HIGH
impactDescription: Avoids conflicts and confusion about where to install packages
tags: packages,system,user,home-manager
---


## Why This Matters

Knowing where and how to install packages prevents conflicts, ensures proper updates, and maintains separation between system and user packages.

## System vs User Packages

### System Packages (NixOS)

Use for:
- System services (servers, daemons)
- Packages needed by all users
- Hardware-related packages (drivers, firmware)
- System-wide utilities

```nix
# hosts/base.nix or host-specific default.nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim          # Available to all users
    git
    wget
    tmux
  ];
}
```

### User Packages (Home Manager)

Use for:
- User-specific applications
- Desktop applications
- Development tools (user-specific)
- Shell configurations

```nix
# home-manager/home.nix or sub-configs
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    vscode       # User-specific
    chrome
    slack
  ];
}
```

## Installing from Different Nixpkgs Channels

### Using unstable packages

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

### Using overlays for custom packages

```nix
# hosts/home/default.nix
{
  nixpkgs.overlays = [
    inputs.custom-overlay.overlays.default
  ];
}

# Now packages from overlay are available
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    custom-package  # From overlay
  ];
}
```

## Conditional Package Installation

### Based on host

```nix
# hosts/laptop/default.nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    powertop        # Laptop-specific
  ];
}
```

### Based on GUI environment

```nix
# hosts/base.nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs;
    (if config.services.xserver.enable then [
      firefox
      dmenu
    ] else [
      tmux
      htop
    ]);
}
```

### Based on architecture

```nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs;
    (if pkgs.system == "x86_64-linux" then [
      docker-compose
    ] else [
      podman
    ]);
}
```

## Wrapper Scripts

Modify package behavior with wrappers:

```nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (symlinkJoin {
      name = "google-chrome-with-flags";
      paths = [ google-chrome ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/google-chrome-stable \
          --add-flags "--disable-gpu" \
          --add-flags "--disable-features=UseChromeOSDirectVideoDecoder"
      '';
    })
  ];
}
```

## Common Mistakes

### Installing user packages system-wide

```nix
# ❌ WRONG: User-specific package in system config
environment.systemPackages = with pkgs; [
  vscode       # Should be in Home Manager
  slack        # Should be in Home Manager
];

# ✅ CORRECT: User packages in Home Manager
# home-manager/home.nix
home.packages = with pkgs; [
  vscode
  slack
];
```

### Installing packages in wrong location

```nix
# ❌ WRONG: System package in Home Manager
# home-manager/home.nix
home.packages = with pkgs; [
  docker       # Should be system package (needs service)
];

# ✅ CORRECT: System package in system config
# hosts/base.nix
environment.systemPackages = with pkgs; [
  docker
];
virtualisation.docker.enable = true;
```

### Not using lists for multiple packages

```nix
# ❌ WRONG: Individual statements
environment.systemPackages = [ pkgs.vim ];
environment.systemPackages = [ pkgs.git ];  # Overwrites previous!

# ✅ CORRECT: Single list
environment.systemPackages = with pkgs; [
  vim
  git
];
```

## Package Updates

### Update all packages

```bash
nix flake update
nixos-rebuild switch --flake .#hostname
```

### Update specific input

```bash
nix flake lock update-input nixpkgs
nixos-rebuild switch --flake .#hostname
```

### Pin to specific version

```nix
# flake.nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";  # Pinned to release
  # Or specific commit:
  # nixpkgs.url = "github:nixos/nixpkgs/a1b2c3d...";
};
```

## Finding Packages

```bash
# Search for package
nix search nixpkgs package-name

# Get package info
nix eval nixpkgs#legacyPackages.x86_64-linux.package-name.meta.description

# Check what package provides a file
nix-locate bin/vim
```

## Quick Reference

| Package Type | Location | Example |
|-------------|----------|---------|
| System service | system config | `virtualisation.docker.enable = true` |
| System utility | system config | `environment.systemPackages = [ vim ]` |
| User app | Home Manager | `home.packages = [ vscode ]` |
| Development tool | Either (user usually) | `home.packages = [ nodejs ]` |
| Driver/firmware | system config | `hardware.graphics.enable = true` |
