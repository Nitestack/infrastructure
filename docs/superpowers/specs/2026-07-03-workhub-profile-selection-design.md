# Workhub Profile Selection Design

## Goal

Allow `claude` and `pi` to run against different Workhub profiles on a per-process basis so multiple terminals can use different credentials at the same time.

## Problem

The current setup models one globally active profile under `wslstation.anthropic.profile`. That makes the selected secret effectively machine-wide for tools that read the configured secret path, which is the wrong boundary for terminal-heavy workflows.

The naming is also misleading. The configured endpoint is an AI hub that may expose multiple model providers, so the configuration should not be described as Anthropic-specific.

## Non-Goals

- Redesign the upstream `claude-code` or `pi-coding-agent` packages
- Introduce shell aliases beyond the requested wrapper command
- Change the normal `claude` or `pi` commands unless needed for compatibility

## Proposed UX

Add a single wrapper command:

```bash
workhub claude
workhub pi
```

Behavior:

- `workhub claude` launches Claude Code after prompting for a Workhub profile with fuzzy selection.
- `workhub pi` launches Pi after prompting for a Workhub profile with fuzzy selection.
- `workhub claude swtb` launches Claude Code directly with the `swtb` profile.
- `workhub pi adp` launches Pi directly with the `adp` profile.
- Profile selection applies only to the spawned process and its children.
- Existing terminals and already-running tools are unaffected.

## Naming Changes

Rename the WSL secret/config terminology from Anthropic-specific names to Workhub-specific names.

Initial rename:

- `wslstation.anthropic.profile` -> `wslstation.workhub.profile`
- `wslstation.anthropic.secretName` -> `wslstation.workhub.secretName`
- `anthropic/<profile>` secret keys -> `workhub/<profile>`
- `anthropic-base-url` -> `workhub/base-url`

To avoid a brittle migration, the implementation may continue to read the current secret file layout if the renamed keys are not moved in the same change. The public option names in Nix should still use `workhub`.

## Architecture

### 1. WSL secret module

Update the WSL SOPS module so it exposes Workhub-oriented options and secret paths rather than Anthropic-oriented ones.

Responsibilities:

- Define the allowed profile names
- Expose the selected/default profile
- Materialize secret files for profile API keys and the shared base URL

### 2. Home Manager wrapper script

Add a small script, installed into `home.packages`, named `workhub`.

Responsibilities:

- Accept a target command: `claude` or `pi`
- Accept an optional profile argument
- If no profile is supplied, present a fuzzy selector
- Read the correct Workhub API key and base URL from the secret files
- Export only the environment variables needed by the spawned command
- `exec` into the selected command so the wrapper does not linger

### 3. Tool command mapping

The wrapper needs a small internal mapping from logical target to executable and env variables.

Expected initial mapping:

- `claude` -> Claude Code executable
- `pi` -> Pi executable

The exact environment variable names should match what each tool already supports for overriding endpoint and key at runtime. The wrapper should avoid editing permanent config files for profile switching.

## Interaction Model

For interactive selection:

- Prefer `fzf` if it is already available in the user environment.
- If `fzf` is unavailable, fall back to a simple numbered prompt in POSIX shell.

This keeps the wrapper usable in minimal environments and avoids taking a hard dependency on a fuzzy finder unless the repo already wants one.

## Error Handling

The wrapper should fail clearly when:

- The target command is not one of the supported tools
- The requested profile name is unknown
- The required secret file is missing or unreadable
- The base URL secret is missing
- Interactive selection is requested in a non-interactive context without `fzf`

Errors should be one-line actionable messages on stderr with a non-zero exit code.

## Testing and Verification

Because this repo uses evaluation as its test boundary, verification should cover:

- Nix evaluation of the affected Home Manager and WSL modules
- Smoke-check that the wrapper script is generated
- Manual command checks:
  - `workhub claude <profile>`
  - `workhub pi <profile>`
  - `workhub claude` interactive selection

## Open Decisions Resolved

- Naming uses `workhub`, not `anthropic`.
- No extra aliases are added.
- The primary UX is one `workhub` wrapper with optional direct profile argument.

## Implementation Outline

1. Rename the WSL option namespace from `anthropic` to `workhub`.
2. Update secret names or add compatibility handling for the existing SOPS key layout.
3. Add a generated `workhub` wrapper script in Home Manager.
4. Wire the script to launch `claude` and `pi` with per-process credentials.
5. Evaluate the affected configurations.
