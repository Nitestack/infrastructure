# Local Host Environment

@platformDescription@ Nix flakes and the `nix-command` interface are enabled,
channels are disabled, and `nixpkgs` is available through the flake registry.
These facts describe commands run directly on this host. Inside a container,
VM, remote system, or CI image, follow that target's own environment and tooling.
If applicable instructions conflict and cannot all be satisfied, ask before
proceeding.

## Development environments and dependencies

- Before editing a Git worktree, inspect its current status.
- Reuse an active project environment. When the project defines a Nix development
  shell, use `nix develop` or
  `nix develop --command <command> <args>` instead of recreating its toolchain.
- Flake commands can update `flake.lock`. Do not keep incidental lockfile changes;
  use `--no-write-lock-file` for read-only operations when supported, and update a
  lockfile only when the task requires it.
- `direnv`, `nix-direnv`, and `nix-your-shell` are installed. A new or changed
  `.envrc` is code execution: inspect it and ask before running `direnv allow`.
  Never bypass approval by sourcing it directly.
- For a missing one-off command, use
  `nix shell nixpkgs#<package> --command <command> <args>` instead of installing
  it persistently.
- Put required project dependencies in that project's manifest or development
  environment. Use the package manager declared by the project, including inside
  project-owned containers and CI images.
- Host packages and settings are declared in `~/infrastructure`. Edit that source
  rather than generated system state or generated global instruction files under
  `~/.config/opencode`, `~/.config/opencode2`, or `~/.config/opencode-work`.
- Do not mutate the local host with imperative installers or package managers such
  as `apt`, `brew`, `curl | sh`, `npm --global`, global `pip`, or `nix profile`.
  Make requested host changes declaratively through `~/infrastructure`.
- Use non-interactive sudo (`sudo -n`) for local host privileges. If it fails,
  report the missing privilege; never wait for, request, expose, or embed a password.
<!-- WSL_ONLY -->
## WSL integration

- Docker Desktop and SSH-agent integrations are configured, but verify the
  required daemon or credential is available before relying on it.
- The Windows `PATH` is intentionally not imported. Use the configured
  `powershell.exe` and `clip.exe` wrappers when Windows interop is needed.
- Passwordless sudo is expected only on this WSL host. Verify it with
  `sudo -n true` before privileged work and stop if the check fails.
