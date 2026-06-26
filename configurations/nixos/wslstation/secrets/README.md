This directory is for `wslstation` secrets only.

The active Anthropic profile is selected in [default.nix](/home/nhan/nix-config/configurations/nixos/wslstation/default.nix:1) through `wslstation.anthropic.profile`.

Create the encrypted secrets file from this directory so `sops` picks up the local [.sops.yaml](/home/nhan/nix-config/configurations/nixos/wslstation/.sops.yaml:1):

```bash
cd /home/nhan/nix-config/configurations/nixos/wslstation
nix shell nixpkgs#sops -c sops secrets/anthropic.yaml
```

Use this YAML shape:

```yaml
anthropic:
  base_url: https://example.invalid
  p: sk-...
  adp: sk-...
  swtb: sk-...
```

Then rebuild:

```bash
sudo nixos-rebuild switch --flake /home/nhan/nix-config#wslstation
```
