<div align="center">
<h1>
  ~/.dotfiles&nbsp;📂
  <br/>
  For NixOS and Windows (including WSL)
  <br/>
  <sup>
    <sub>Powered by <a href="https://chezmoi.io" target="_blank">chezmoi</a></sub>
  </sup>
</h1>

![Latest commit](https://img.shields.io/github/last-commit/Nitestack/dotfiles?style=for-the-badge)
![GitHub Repo stars](https://img.shields.io/github/stars/Nitestack/dotfiles?style=for-the-badge)
![Github Created At](https://img.shields.io/github/created-at/Nitestack/dotfiles?style=for-the-badge)

[Features](#-features) • [Requirements](#️-requirements) • [Getting Started](#-getting-started) • [Credits](#-credits) • [License](#-license)

![image](https://github.com/user-attachments/assets/2d4c126b-b499-400e-9922-43a92badabae)

_Elevate your computing experience across platforms with this curated collection of configuration files and setup scripts. From [NixOS](https://nixos.org) to [Windows](https://microsoft.com/windows) and [WSL](https://learn.microsoft.com/windows/wsl) ([NixOS](https://nix-community.github.io/NixOS-WSL)), personalize your environment effortlessly. Securely manage diverse machines using [chezmoi](https://chezmoi.io) and leverage seamless deployment and synchronization._

<p>
  <strong>Be sure to <a href="#" title="star">⭐️</a> or fork this repo if you find it useful!</strong>
</p>
</div>

## 🚀 Features

### NixOS (Full System)

This setup operates on the [Wayland](https://wayland.freedesktop.org) protocol, utilizing [Hyprland](https://hyprland.org) as the compositor for smooth and visually pleasing window management. For login management, [SDDM](https://github.com/sddm/sddm) is employed with a custom theme, providing a refined interface. The system uses [GRUB](https://www.gnu.org/software/grub) as the bootloader, enhanced with a theme and `os-prober` for seamless dual-booting with Windows or other operating systems.

Everything is built using a [Nix Flake](https://nix.dev/concepts/flakes.html), ensuring the system is reproducible. It also includes features listed in the [Cross-Platform](#cross-platform-nixos-windows) and [UNIX](#unix-nixos) sections, making it a complete and functional environment.

### Cross-Platform (NixOS, Windows)

- **Neovim Configuration (with WSL)**: Powered by [LazyVim](http://www.lazyvim.org), ensuring a robust text editing experience.

- **WezTerm Configuration**: Integrated Neovim workflow for a seamless terminal and text editing setup.

- **Oh My Posh Configuration (with WSL)**: Customized prompt for a visually appealing and informative shell experience.

- **Fastfetch Configuration (with WSL)**: Customized settings for efficient system information display.

- **Lazygit Configuration (with WSL)**: Themed with the [Catppuccin Mocha](https://github.com/catppuccin/lazygit) theme for a cohesive look and feel.

- **Git Configuration (with WSL)**: Customized settings for version control.

- **ShellCheck Configuration (with WSL)**: Setup for shell script analysis.

- **SSH Configuration (with WSL)**: Consistent and secure SSH setup across systems.

---

And more to discover.

## ⚙️ Requirements

Ensure you have the latest stable release of [NixOS](https://nixos.org), [Windows](https://microsoft.com/windows), or [WSL](https://learn.microsoft.com/windows/wsl) installed.

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

### NixOS (including WSL)

Ensure you have `git` and `chezmoi` available when needed in the installation section.

```sh
nix-shell -p git chezmoi
```

### Windows

Ensure you have `git`, `chezmoi`, and `pwsh` installed.

```pwsh
winget install -e --accept-package-agreements --accept-source-agreements Git.Git twpayne.chezmoi Microsoft.PowerShell
```

> [!IMPORTANT]
> All versions of Windows come with PowerShell 5.1 pre-installed. However, this repository requires PowerShell 7.x or higher. PowerShell 7.x+ does not replace or upgrade PowerShell 5.1; it is installed alongside it.

#### Fonts

- [Geist Sans](https://vercel.com/font)
- [Geist Mono Nerd Font](https://nerdfonts.com/font-downloads)
- [Symbols Nerd Font](https://nerdfonts.com/font-downloads)
- [Noto Color Emoji](https://fonts.google.com/noto)

## 🏁 Getting Started

Clone the dotfiles repository:

```sh
git clone https://github.com/Nitestack/dotfiles.git ~/.dotfiles
# or with SSH
git clone git@github.com:Nitestack/dotfiles.git ~/.dotfiles
```

### NixOS

Before continuing with the installation, initialize the NixOS system:

```sh
sudo nixos-rebuild boot --flake "$HOME/.dotfiles/nix#nixstation" --impure
```

Please reboot the system and then continue with the [Final Steps](#final-steps).

### WSL (NixOS)

Before continuing with the installation, initialize the NixOS WSL system:

```sh
sudo nixos-rebuild boot --flake "$HOME/.dotfiles/nix#wslstation" --impure
```

Execute the following commands in PowerShell to correctly apply the custom username:

```pwsh
wsl -t NixOS
wsl -d NixOS --user root exit
wsl -t NixOS
```

Start WSL and then continue with the [Final Steps](#final-steps).

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
