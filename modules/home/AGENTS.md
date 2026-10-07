# Home Manager Modules

Home Manager profiles under `configurations/home/` import these reusable
modules. A change here can affect several hosts, so trace the profile imports
before editing and evaluate every affected target.

- Keep cross-profile behaviour in focused modules and use the existing profile
  boundaries (`desktop`, `server`, and `wsl`).
- `ai.nix` installs the agent skill sources and enables the Codex, Claude Code,
  and OpenCode targets. Generated agent directories are outputs; edit the Nix
  source or flake input instead of editing generated files in a home directory.
- `ai.nix` deliberately flattens nested Matt Pocock skill paths for Claude Code
  discovery. Preserve the explicit `rename` mapping when changing skill
  sources; recursive discovery by another client is not enough.
- The deeper `opencode/AGENTS.md` covers profile merging, model routing, and
  runtime credentials.

For host-sensitive changes, run `nix run .#check` and evaluate the exact host
that imports the changed profile. Keep API keys and other credentials in sops
or runtime environment variables, never in Home Manager configuration text.
