# wslstation

`wslstation` is the NixOS-WSL host. Its configuration also imports the WSL
Home Manager profile and enables Docker Desktop integration.

## Immediate Verification

When the current machine is the running `wslstation` instance, sudo is
passwordless. Agents can therefore apply and inspect a change immediately. Use
`sudo -n` on privileged commands so an unexpected environment fails instead of
waiting for a password prompt:

```sh
sudo -n true
nix run .#check
nix eval .#nixosConfigurations.wslstation.config.system.build.toplevel.drvPath --no-write-lock-file
nix-switch
nixos-version
systemctl --failed
docker ps
```

`nix-switch` is the ordinary-change command on this host. The Home Manager
wrapper calls `nh os switch`, detects WSL as `wslstation`, and uses the
configured `~/infrastructure` flake. If it is unavailable, use the explicit
fallback `sudo -n nixos-rebuild switch --flake .#wslstation`.

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
