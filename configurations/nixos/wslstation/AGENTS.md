# wslstation

`wslstation` is the NixOS-WSL host. Its configuration also imports the WSL
Home Manager profile and enables Docker Desktop integration.

## Immediate Verification

On the running `wslstation`, verify passwordless sudo before using the
ordinary-change wrapper:

```sh
sudo -n true
nix-switch
```

Use [`docs/operations.md`](../../../docs/operations.md) for the full validation
and service-check sequence. The Home Manager wrapper calls `nh os switch`,
detects WSL as `wslstation`, and uses the configured `~/infrastructure` flake.

Do not generalize this passwordless assumption to other hosts. If `sudo -n
true` fails, stop the privileged step and report that the environment differs;
never put a password in a command, document, or secret workaround.

`switch` changes the running WSL instance. The initial installation flow uses
`boot`, and a boot-selected WSL generation may require the Windows-side restart
sequence documented in the [README](../../../README.md):

```nu
wsl -t NixOS
wsl -d NixOS --user root exit
wsl -t NixOS
```

Use the [Windows Terminal instructions](../../../docs/windows-terminal-herdr.md)
for keyboard integration changes; those are not fixed by a Nix rebuild alone.
