<div align="center">
<h1>
  📂 Personal Infrastructure as Code
</h1>
<h2>
  Nix system configs, a self-hosted homelab, and DNS/edge managed declaratively
  <br/>
  <sup>
    <sub>Powered by <a href="https://nixos.org" target="_blank">Nix</a>, <a href="https://nix-community.github.io/home-manager" target="_blank">Home Manager</a>, and <a href="https://opentofu.org" target="_blank">OpenTofu</a></sub>
  </sup>
</h2>

![Latest commit](https://img.shields.io/github/last-commit/Nitestack/infrastructure?style=for-the-badge)
![GitHub Repo stars](https://img.shields.io/github/stars/Nitestack/infrastructure?style=for-the-badge)
![Github Created At](https://img.shields.io/github/created-at/Nitestack/infrastructure?style=for-the-badge)

[What's in here](#-whats-in-here) • [Requirements](#️-requirements) • [Getting Started](#-getting-started) • [Documentation](#-documentation) • [License](#-license)

![NixOS](https://github.com/user-attachments/assets/e3e520d4-79e7-48d9-b744-5f0f5cec378a)

_This repository is my personal infrastructure, managed as code: reproducible [Nix](https://nixos.org)/[Home Manager](https://nix-community.github.io/home-manager) system configurations for [NixOS](https://nixos.org) (including [NixOS via WSL](https://nix-community.github.io/NixOS-WSL)) and [macOS](https://apple.com/macos), a self-hosted homelab of containerized services, and the [OpenTofu](https://opentofu.org)/Cloudflare edge that fronts them — all declarative, all version-controlled._

<p>
  <strong>Be sure to <a href="#" title="star">⭐️</a> or fork this repo if you find it useful!</strong>
</p>
</div>

## 📦 What's in here

- **System & user configs** — `configurations/` and `modules/` define NixOS, nix-darwin, and Home Manager setups for every host (desktop, laptop, server, WSL), wired together via [nixos-unified](https://github.com/srid/nixos-unified).
- **Homelab services** — `modules/nixos/homelab/` is a small module API for declaring self-hosted apps, their containers, and how traffic reaches them (Caddy, DNS, Cloudflare Tunnel). See [`docs/homelab-services.md`](docs/homelab-services.md).
- **Edge/DNS as code** — `opentofu/cloudflare/` manages Cloudflare-side DNS and zone settings with OpenTofu. See [`opentofu/cloudflare/README.md`](opentofu/cloudflare/README.md).
- **Secrets** — encrypted with [sops-nix](https://github.com/Mic92/sops-nix) (`secrets/`), scoped per host via `.sops.yaml`.
- **Automation** — GitHub Actions CI (`.github/workflows/`) and Renovate keep the flake and container images up to date; see [`docs/renovate-setup.md`](docs/renovate-setup.md).

## ⚙️ Requirements

Ensure you have [`git`](https://git-scm.com) available when needed in the installation section.

### NixOS

Ensure you have the latest version of [NixOS](https://nixos.org/download) installed.

Either run the graphical installer or manually install NixOS on your system.

### WSL (NixOS)

Ensure you have the latest version of [WSL](https://learn.microsoft.com/windows/wsl) installed.

Download `nixos.wsl` from [the latest release](https://github.com/nix-community/NixOS-WSL/releases/latest).

Either open the file by double-clicking or run:

```nu
wsl --install --from-file nixos.wsl # wherever nixos.wsl was downloaded
```

#### Post-Install

After the initial installation, update your channels to use `nixos-rebuild`:

```nu
sudo nix-channel --update
```

If you want to make NixOS your default distribution, you can do so with

```nu
wsl -s NixOS
```

### macOS

Ensure you have the latest version of [macOS](https://apple.com/macos) and [Nix](https://nixos.org) installed.

Install `Nix` with the [Nix Installer from Determinate Systems](https://determinate.systems):

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

## 🏁 Getting Started

Clone the repository:

```nu
git clone https://github.com/Nitestack/infrastructure.git
```

### NixOS

Before continuing with the installation, initialize the Nix system:

```sh
sudo nixos-rebuild boot --flake ~/infrastructure#nixstation
```

Please reboot the system.

### Server (NixOS)

Before continuing with the installation, initialize the Nix system:

```sh
sudo nixos-rebuild boot --flake ~/infrastructure#homestation
```

Please reboot the system.

### macOS

Before continuing with the installation, initialize the Nix system:

```sh
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/infrastructure#macstation
```

Please reboot the system.

### WSL (NixOS)

Initialize the Nix system inside of NixOS-WSL:

```sh
sudo nixos-rebuild boot --flake ~/infrastructure#wslstation
```

Execute the following commands on Windows to correctly apply the custom username:

```nu
wsl -t NixOS
wsl -d NixOS --user root exit
wsl -t NixOS
```

Restart WSL.

## 📚 Documentation

- [`docs/homelab-services.md`](docs/homelab-services.md) — the `homelab` NixOS module: options, recipes, validation
- [`docs/adguard-home-client-caveats.md`](docs/adguard-home-client-caveats.md) — AdGuard Home client-config gotchas
- [`docs/renovate-setup.md`](docs/renovate-setup.md) — one-time Renovate GitHub App setup
- [`opentofu/cloudflare/README.md`](opentofu/cloudflare/README.md) — managing Cloudflare DNS/edge state

## 📝 License

This project is licensed under the Apache-2.0 license.
