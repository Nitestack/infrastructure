<div align="center">
<h1>
  ~/.dotfiles&nbsp;📂
  <br/>
  For NixOS, macOS (with Nix) and Windows (including WSL)
  <br/>
  <sup>
    <sub>Powered by <a href="https://nixos.org" target="_blank">Nix</a>, <a href="https://nix-community.github.io/home-manager" target="_blank">Home Manager</a> and <a href="https://chezmoi.io" target="_blank">chezmoi</a></sub>
  </sup>
</h1>

![Latest commit](https://img.shields.io/github/last-commit/Nitestack/dotfiles?style=for-the-badge)
![GitHub Repo stars](https://img.shields.io/github/stars/Nitestack/dotfiles?style=for-the-badge)
![Github Created At](https://img.shields.io/github/created-at/Nitestack/dotfiles?style=for-the-badge)

[Requirements](#️-requirements) • [Getting Started](#-getting-started) • [Credits](#-credits) • [License](#-license)

![image](https://github.com/user-attachments/assets/e828afb0-3cf3-4da5-af66-b1a0d344af3c)

_Elevate your computing experience across platforms with this curated collection of configuration files and setup scripts. From [NixOS](https://nixos.org) to [macOS](https://apple.com/macos) with [Nix](https://nixos.org) and [Windows](https://microsoft.com/windows) including [WSL](https://learn.microsoft.com/windows/wsl) ([NixOS](https://nix-community.github.io/NixOS-WSL)), personalize your environment effortlessly. Securely manage diverse machines using [chezmoi](https://chezmoi.io) and leverage seamless deployment and synchronization._

<p>
  <strong>Be sure to <a href="#" title="star">⭐️</a> or fork this repo if you find it useful!</strong>
</p>
</div>

> [!WARNING]
> This repository is primarily intended for NixOS, NixOS WSL and macOS. While I could have included more features on Windows, they may not perform as well as they do on NixOS (WSL). Tools like Neovim and others are technically functional on Windows, but they are slower. As a result, I've excluded them on Windows. If you want to use these tools on Windows, I recommend using NixOS WSL, it's just a better developer experience.

## ⚙️ Requirements

### NixOS

Ensure you have the latest release of [NixOS](https://nixos.org/download) installed. 

Please run either the graphical installer or manually install NixOS on your system.

### WSL (NixOS)

Ensure you have the latest release of [NixOS-WSL](https://github.com/nix-community/NixOS-WSL/releases/latest) downloaded.

Open PowerShell and run:

```pwsh
wsl --import NixOS --version 2 $env:USERPROFILE\NixOS\ nixos-wsl.tar.gz
```

#### Post-Install

After the initial installation, update your channels to use `nixos-rebuild`:

```sh
sudo nix-channel --update
```

Then rebuild the system:

```sh
sudo nixos-rebuild switch
```

To make NixOS your default distribution, use:

```pwsh
wsl -s NixOS
```

### macOS

Ensure you have the latest version of [macOS](https://apple.com/macos) and [Nix](https://nixos.org) installed.

Install `Nix` with the [Nix Installer from Determinate Systems](https://determinate.systems):

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
  sh -s -- install
```

### Nix (including macOS and WSL)

Ensure you have `git` and `chezmoi` available when needed in the installation section.

```sh
nix-shell -p git chezmoi
```

### Windows

Ensure you have the latest version of [Windows](https://www.microsoft.com/software-download) as well as `git`, `chezmoi`, and `pwsh` installed.

```pwsh
winget install -e --accept-package-agreements --accept-source-agreements Git.Git twpayne.chezmoi Microsoft.PowerShell
```

> [!IMPORTANT]
> All versions of Windows come with PowerShell 5.1 pre-installed. However, this repository requires PowerShell 7.x or higher. PowerShell 7.x+ does not replace or upgrade PowerShell 5.1; it is installed alongside it.

## 🏁 Getting Started

Clone the dotfiles repository:

```sh
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

Before continuing with the installation, initialize the Nix system:

```sh
sudo nixos-rebuild boot --flake "$HOME/.dotfiles/nix#wslstation"
```

Execute the following commands in PowerShell to correctly apply the custom username:

```pwsh
wsl -t NixOS
wsl -d NixOS --user root exit
wsl -t NixOS
```

Restart WSL and then continue with the [Final Steps](#final-steps).

### Windows

Continue with the [Final Steps](#final-steps).

### Final Steps

Initialize chezmoi:

#### UNIX

```sh
chezmoi init --source="$HOME/.dotfiles" --apply
```

#### Windows

```pwsh
chezmoi init --source="$env:USERPROFILE\.dotfiles" --apply
```

## 🙌 Credits

- [Tom Payne](https://github.com/twpayne): Creator of [chezmoi](https://chezmoi.io). Parts of his dotfiles are used.
- [Folke Lemaitre](https://github.com/folke): Creator of [LazyVim](https://github.com/LazyVim/LazyVim). Parts of his dotfiles are used.
- [Aylur](https://github.com/Aylur): Creator of [Ags](https://aylur.github.io/ags-docs) and [Astal](https://aylur.github.io/astal). Parts of his Nix configuration were used.
- [end-4](https://github.com/end-4): Parts of his dotfiles are used.
- [Pratik Gayen](https://github.com/FireDrop6000/hyprland-mydots): Hyprlock config is used.
- [Elliott Minns](https://github.com/elliottminns) ([Dreams of Code](https://www.youtube.com/@dreamsofcode)): Parts of his Nix configuration were used.

## 📝 License

This project is licensed under the Apache-2.0 license.
