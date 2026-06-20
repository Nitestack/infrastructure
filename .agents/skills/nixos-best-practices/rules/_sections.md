---
title: Rule Sections and Reading Order
impact: LOW
impactDescription: Guide for reading rules in logical order
tags: sections, reading-order, guide
---

# Rule Sections

This guide defines the reading order for all rules in this skill.

## Reading Order

Read rules in this order for comprehensive understanding:

### Foundation (Read First)

1. **[overlay-scope](overlay-scope.md)** - The most common issue
   - Why overlays don't apply with useGlobalPkgs = true
   - Where to define overlays based on useGlobalPkgs setting
   - This is the issue you will encounter most frequently

2. **[flakes-structure](flakes-structure.md)** - How to organize flake.nix
   - Special args pattern for passing inputs
   - Input following to avoid duplicates
   - Multiple hosts configuration

### Core Organization

3. **[host-organization](host-organization.md)** - Structuring configurations
   - Directory structure for multiple hosts
   - Shared base configuration
   - Separating system and user config
   - Module pattern for reusable functionality

4. **[package-installation](package-installation.md)** - Installing packages correctly
   - System vs user packages (NixOS vs Home Manager)
   - Using different nixpkgs channels
   - Conditional package installation
   - Wrapper scripts

### Debugging

5. **[troubleshooting](troubleshooting.md)** - Systematic debugging approach
   - Common error patterns and fixes
   - Configuration changes not applying
   - Verification commands
   - Useful debugging tools

6. **[common-mistakes](common-mistakes.md)** - Pitfalls and how to avoid them
   - Top 10 configuration mistakes
   - Symptoms, causes, and solutions for each
   - Quick checklist before committing changes

## Quick Start

For your first NixOS configuration with flakes, read in this order:

1. overlay-scope - Understand overlay application immediately
2. flakes-structure - Set up your flake correctly
3. host-organization - Structure your configurations

Then reference other rules as needed.

## By Impact Level

### CRITICAL Rules

- overlay-scope - The #1 issue users face
- flakes-structure - Foundation of flake-based configs

### HIGH Rules

- host-organization - Prevents configuration chaos
- package-installation - Avoids conflicts and confusion
- common-mistakes - Prevents most errors

### MEDIUM Rules

- troubleshooting - For when things go wrong

### LOW Rules

- _sections - This file
