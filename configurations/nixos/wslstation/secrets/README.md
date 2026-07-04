This directory is for `wslstation` secrets only.

The WSL Home Manager config reads `aix` credentials from `/run/secrets/aix/*` and configures `programs.aix` directly.

Create the encrypted secrets file from this directory so `sops` picks up the local [.sops.yaml](/home/nhan/nix-config/configurations/nixos/wslstation/.sops.yaml:1):

```bash
cd /home/nhan/nix-config/configurations/nixos/wslstation
nix shell nixpkgs#sops -c sops secrets/aix.yaml
```

Use this YAML shape:

```yaml
aix:
  base_url: https://example.invalid
  p:
    label: Personal
    key: sk-...
  adp:
    label: Work ADP
    key: sk-...
  swtb:
    label: Work SWTB
    key: sk-...
  p-t:
    label: Personal Temp
    key: sk-...
```

Then rebuild:

```bash
sudo nixos-rebuild switch --flake /home/nhan/nix-config#wslstation
```
