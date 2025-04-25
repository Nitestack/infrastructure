<div align="center">
<h1>
  Unified ~/.dotfiles&nbsp;📂
  <br/>
  For NixOS, macOS (with nix-darwin), Windows (and NixOS WSL)
  <br/>
  <sup>
    <sub>Powered by <a href="https://nixos.org" target="_blank">Nix</a>, <a href="https://nix-community.github.io/home-manager" target="_blank">Home Manager</a>, <a href="https://nushell.sh">Nushell</a> and <a href="https://chezmoi.io" target="_blank">chezmoi</a></sub>
  </sup>
</h1>

![Latest commit](https://img.shields.io/github/last-commit/Nitestack/dotfiles?style=for-the-badge)
![GitHub Repo stars](https://img.shields.io/github/stars/Nitestack/dotfiles?style=for-the-badge)
![Github Created At](https://img.shields.io/github/created-at/Nitestack/dotfiles?style=for-the-badge)

[Requirements](#️-requirements) • [Getting Started](#-getting-started) • [License](#-license)

![image](https://github.com/user-attachments/assets/911a04ec-8da9-4ade-9780-99c5069d554f)

_A unified, declarative dotfiles setup leveraging, [Nix](https://nixos.org), [Home Manager](https://nix-community.github.io/home-manager), [nix-darwin](https://github.com/nix-darwin/nix-darwin) and [chezmoi](https://chezmoi.io) to provide consistent shell environments across [NixOS](https://nixos.org), [macOS](https://apple.com/macos) and [Windows](https://microsoft.com/windows) (including [NixOS via WSL](https://nix-community.github.io/NixOS-WSL)). This repository uses [Nushell](https://nushell.sh) as the primary shell._

<p>
  <strong>Be sure to <a href="#" title="star">⭐️</a> or fork this repo if you find it useful!</strong>
</p>
</div>

> [!WARNING]
> This repository is primarily intended for NixOS, NixOS WSL and macOS. While I could have included more features on Windows, they may not perform as well as they do on NixOS (WSL). Tools like Neovim and others are technically functional on Windows, but they are slower. As a result, I've excluded them on Windows. If you want to use these tools on Windows, I recommend using NixOS WSL, it's just a better developer experience.

## ⚙️ Requirements

Ensure you have [`nu`](https://nushell.sh), [`git`](https://git-scm.com) and [`chezmoi`](https://chezmoi.io) available when needed in the installation section.

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
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
  sh -s -- install
```

### Windows

Ensure you have the latest version of [Windows](https://www.microsoft.com/software-download) installed.

## 🏁 Getting Started

Clone the dotfiles repository:

```nu
git clone https://github.com/Nitestack/dotfiles.git ~/.dotfiles
```

### NixOS

Before continuing with the installation, initialize the Nix system:

```sh
sudo nixos-rebuild boot --flake "$HOME/.dotfiles/nix#nixstation"
```

Please reboot the system and then continue with the [Final Steps](#final-steps).

### macOS

Before continuing with the installation, initialize the Nix system:

```sh
nix run nix-darwin/master#darwin-rebuild -- switch --flake "$HOME/.dotfiles/nix#macstation"
```

Please reboot the system and then continue with the [Final Steps](#final-steps).

### WSL (NixOS)

Initialize the Nix system inside of NixOS-WSL:

```sh
sudo nixos-rebuild boot --flake "$HOME/.dotfiles/nix#wslstation"
```

Execute the following commands on Windows to correctly apply the custom username:

```nu
wsl -t NixOS
wsl -d NixOS --user root exit
wsl -t NixOS
```

Restart WSL and then continue with the [Final Steps](#final-steps).

### Windows

Continue with the [Final Steps](#final-steps).

### Final Steps

Initialize chezmoi:

```nu
chezmoi init --source=~/.dotfiles --apply
```

## 📝 License

This project is licensed under the Apache-2.0 license.
