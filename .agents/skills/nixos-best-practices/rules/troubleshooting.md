---
title: Troubleshooting Configuration Issues
impact: MEDIUM
impactDescription: Systematic debugging approach for configuration issues
tags: debugging,errors,troubleshooting,verification
---


## Why This Matters

Knowing how to systematically debug NixOS configurations saves hours of frustration and prevents making random changes hoping something works.

## General Approach

Follow this order when debugging:

1. **Read error messages completely** - They usually tell you exactly what's wrong
2. **Verify syntax** - Check for missing brackets, quotes, commas
3. **Validate config** - Use `nixos-rebuild test` first
4. **Check scope** - Is overlay/module in correct location?
5. **Trace dependencies** - Are required inputs/imports present?

## Common Error Patterns

### "undefined variable 'inputs'"

**Cause:** `inputs` not passed via `specialArgs`.

**Fix:**
```nix
# flake.nix
outputs = { self, nixpkgs, ... }@inputs:
{
  nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };  # Add this
    modules = [ ./hosts/myhost ];
  };
};
```

### "attribute 'package-name' not found"

**Cause:** Package doesn't exist, or overlay not applied.

**Debug:**
```bash
# Check if package exists in nixpkgs
nix search nixpkgs package-name

# Check if overlay is defined
nix eval .#nixosConfigurations.myhost.config.nixpkgs.overlays

# Verify package in your config's pkgs
nix repl
nix-repl> :l flake.nix
nix-repl> myhost.config.environment.systemPackages
```

**Fix:**
- If overlay issue: Move to correct location (see [overlay-scope.md](overlay-scope.md))
- If missing package: Use correct package name or add overlay

### "error: The option 'some.option' does not exist"

**Cause:** Typo in option name, or option not available in your nixpkgs version.

**Debug:**
```bash
# Search for option
nixos-options | grep some-option

# Check option in current config
nix eval .#nixosConfigurations.myhost.config.some.option
```

**Fix:**
- Check option name spelling
- Verify nixpkgs version has this option
- Read option documentation for correct usage

### "infinite recursion"

**Cause:** Circular dependency in config.

**Debug:**
```bash
# Use --show-trace to see where
nixos-rebuild build --flake .#hostname --show-trace
```

**Fix:**
- Look for mutual dependencies
- Use `mkBefore`/`mkAfter` for ordering
- Break circular reference

### "hash mismatch" in flake.lock

**Cause:** Local changes or outdated lock file.

**Fix:**
```bash
# Update flake lock
nix flake update

# Or update specific input
nix flake lock update-input nixpkgs
```

### "path '.../module-name' does not exist"

**Cause:** Import path doesn't match actual file/directory structure.

**Debug:**
```bash
# Check what files exist
ls -la home-manager/shell/

# Verify import syntax
grep "imports" home-manager/shell/default.nix
```

**Fix:**
```nix
# ❌ WRONG if agent-browser.nix is a file
{
  imports = [ ./agent-browser ];  # Looks for agent-browser/default.nix
}

# ✅ CORRECT for file
{
  imports = [ ./agent-browser.nix ];  # Imports the file
}

# ✅ CORRECT for directory with default.nix
# agent-browser/
#   default.nix
{
  imports = [ ./agent-browser ];  # Imports agent-browser/default.nix
}
```

**Rule:** In `imports` list:
- `./name` → directory `name/default.nix`
- `./name.nix` → file `name.nix`

## Third-Party Tools on NixOS (Playwright, Electron, etc.)

### Systematic Debugging for Missing Libraries

**Symptom:** `error while loading shared libraries: libxxx.so: not found`

**Common mistake:** Adding packages one at a time and repeatedly rebuilding.

**Correct approach:**

```bash
# 1. Check ALL missing libraries at once
ldd /path/to/binary 2>&1 | grep "not found"

# 2. Find which packages provide these libraries
nix-locate libxxx.so

# 3. Add ALL missing packages in a SINGLE rebuild
# Don't rebuild multiple times!
```

### Playwright/Chromium on NixOS

**Key insight:** Playwright browsers downloaded via npm don't work on NixOS due to missing libraries.

**Two solutions:**

1. **Use LD_LIBRARY_PATH** (for downloaded browsers):
```nix
home.sessionVariables = {
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [
    # Add ALL Chromium dependencies at once
    alsa-lib atk cairo cups dbus expat glib gtk3
    libdrm libgbm libxkbcommon mesa nspr nss
    pango systemd udev xorg.libX11 xorg.libXcomposite
    # ... see full list below
  ]);
};
```

2. **Use Nix-provided browsers** (recommended):
```nix
{
  home.packages = [ pkgs.playwright-driver.browsers ];
  home.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
  };
}
```

**Common Chromium dependencies reference:**
```nix
with pkgs; [
  alsa-lib at-spi2-atk at-spi2-core atk
  cairo cups dbus expat gdk-pixbuf glib gtk3
  libdrm libgbm libxkbcommon mesa nspr nss
  pango systemd udev xorg.libX11 xorg.libXcomposite
  xorg.libXdamage xorg.libXext xorg.libXfixes
  xorg.libXrandr xorg.libxcb xorg.libxshmfence
]
```

**Remember:** Check `ldd` output first, then add ALL missing libraries in one rebuild.

## Overlay Not Applied

**Symptom:** Package from overlay not found.

**Debug steps:**

1. Check overlay definition:
```bash
nix eval .#nixosConfigurations.myhost.config.nixpkgs.overlays
```

2. Check overlay location:
```bash
# If useGlobalPkgs = true, overlay should be here:
grep -r "nixpkgs.overlays" hosts/myhost/default.nix

# NOT here:
grep -r "nixpkgs.overlays" home-manager/home.nix
```

3. Verify overlay input:
```bash
nix flake metadata
# Look for your overlay input
```

**Fix:** See [overlay-scope.md](overlay-scope.md)

## Configuration Changes Not Applying

**Symptom:** Edit config, rebuild, but nothing changes.

**Debug steps:**

1. Verify rebuild ran successfully:
```bash
sudo nixos-rebuild switch --flake .#hostname
# Look for "success" message
```

2. Check current generation:
```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

3. Verify new generation is active:
```bash
sudo nixos-version
# Should show timestamp of recent rebuild
```

4. Check if option actually changed:
```bash
nix eval .#nixosConfigurations.myhost.config.some.option
```

**Fix:**
- Ensure rebuild succeeded
- Check if service needs restart: `systemctl restart service-name`
- For Home Manager: `home-manager switch` (or `sudo nixos-rebuild switch` if integrated)

## Build Fails with "store collision"

**Symptom:** Multiple packages trying to write to same path.

**Cause:** Usually duplicate package declarations or conflicting modules.

**Fix:**
- Remove duplicate package declarations
- Check for conflicting modules
- Use `--show-trace` to identify conflicting packages

## Verification Commands

### Check configuration without building

```bash
# Check syntax
nix flake check

# Dry run build
nixos-rebuild build --flake .#hostname --dry-run

# Evaluate specific option
nix eval .#nixosConfigurations.myhost.config.environment.systemPackages
```

### Test configuration safely

```bash
# Build without activating
nixos-rebuild build --flake .#hostname

# Test configuration (rollback on reboot)
nixos-rebuild test --flake .#hostname

# Switch (persistent)
nixos-rebuild switch --flake .#hostname
```

### Compare generations

```bash
# List system generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# List Home Manager generations
home-manager generations

# Compare configurations
sudo nix diff-closures /nix/var/nix/profiles/system-*-link
```

## Useful Tools

### nix repl

```bash
nix repl
nix-repl> :l flake.nix                    # Load flake
nix-repl> myhost.config.environment.systemPackages  # Access config
nix-repl> :b myhost.config.system.build.toplevel   # Build
```

### nixos-version

```bash
# Check current system version
nixos-version

# Should show something like:
# 25.05.20250123.abc1234
```

### journalctl

```bash
# Check service logs for failures
sudo journalctl -xe

# Check NixOS rebuild logs
sudo journalctl -u nixos-rebuild
```

## Getting Help

When asking for help, provide:

1. **Full error message** (not just "it doesn't work")
2. **Minimal reproducible example**
3. **NixOS version**: `nixos-version`
4. **Relevant config files**
5. **What you've tried**
6. **Expected vs actual behavior**

Useful commands:
```bash
# Show system info
nixos-version
uname -a

# Show flake info
nix flake metadata

# Export config for sharing
nixos-rebuild build --flake .#hostname
nix-store -qR result > system-closure
```

## Common Debugging Workflows

### Package not found

```bash
# 1. Search for package
nix search nixpkgs package-name

# 2. Check if it's available for your system
nix eval nixpkgs#legacyPackages.x86_64-linux.package-name

# 3. Check your overlays
nix eval .#nixosConfigurations.myhost.config.nixpkgs.overlays

# 4. Check if overlay provides it
nix eval .#packages.x86_64-linux.package-name
```

### Overlay not applying

```bash
# 1. Verify overlay is defined
grep -r "overlays" hosts/myhost/

# 2. Check useGlobalPkgs setting
grep "useGlobalPkgs" hosts/myhost/default.nix

# 3. Evaluate overlay
nix eval .#nixosConfigurations.myhost.config.nixpkgs.overlays

# 4. Test package directly
nix build .#packages.x86_64-linux.package-name
```

### Service not starting

```bash
# 1. Check service status
systemctl status service-name

# 2. View service logs
journalctl -xeu service-name

# 3. Check service config
nixos-rebuild build --flake .#hostname --show-trace

# 4. Test service manually
/path/to/service-binary --verbose
```
