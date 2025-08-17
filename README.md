<div align="center">
<h1>
  📂 Cross-Platform Nix Configuration
</h1>
<h2>
  For NixOS (including WSL) and macOS (with nix-darwin)
  <br/>
  <sup>
    <sub>Powered by <a href="https://nixos.org" target="_blank">Nix</a> and <a href="https://nix-community.github.io/home-manager" target="_blank">Home Manager</a></sub>
  </sup>
</h2>

![Latest commit](https://img.shields.io/github/last-commit/Nitestack/nix-config?style=for-the-badge)
![GitHub Repo stars](https://img.shields.io/github/stars/Nitestack/nix-config?style=for-the-badge)
![Github Created At](https://img.shields.io/github/created-at/Nitestack/nix-config?style=for-the-badge)

[Requirements](#️-requirements) • [Getting Started](#-getting-started) • [License](#-license)

![NixOS](https://github.com/user-attachments/assets/9a244fe9-b5a2-415d-9414-c246b36f51e7)

_A comprehensive, cross-platform [Nix](https://nixos.org) configuration repository managing system settings and user environments across multiple operating systems. This repository provides reproducible, declarative configurations for [NixOS](https://nixos.org) (including [NixOS via WSL](https://nix-community.github.io/NixOS-WSL)) and [macOS](https://apple.com/macos)._

<p>
  <strong>Be sure to <a href="#" title="star">⭐️</a> or fork this repo if you find it useful!</strong>
</p>
</div>

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
git clone https://github.com/Nitestack/nix-config.git
```

### NixOS

Before continuing with the installation, initialize the Nix system:

```sh
sudo nixos-rebuild boot --flake ~/nix-config#nixstation
```

Please reboot the system.

### macOS

Before continuing with the installation, initialize the Nix system:

```sh
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/nix-config#macstation
```

Please reboot the system.

### WSL (NixOS)

Initialize the Nix system inside of NixOS-WSL:

```sh
sudo nixos-rebuild boot --flake ~/nix-config#wslstation
```

Execute the following commands on Windows to correctly apply the custom username:

```nu
wsl -t NixOS
wsl -d NixOS --user root exit
wsl -t NixOS
```

Restart WSL.

## 📝 License

This project is licensed under the Apache-2.0 license.
