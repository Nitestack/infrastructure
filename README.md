<div align="center">
<h1>
  ~/.dotfiles&nbsp;📂
  <br/>
  Cross-Platform & Cross-Shell Dotfiles
  <br/>
  <sup>
    <sub>Powered by chezmoi</sub>
  </sup>
</h1>

![Latest commit](https://img.shields.io/github/last-commit/Nitestack/dotfiles?style=for-the-badge)
![GitHub Repo stars](https://img.shields.io/github/stars/Nitestack/dotfiles?style=for-the-badge)
![Github Created At](https://img.shields.io/github/created-at/Nitestack/dotfiles?style=for-the-badge)

[Features](#-features) • [Requirements](#️-requirements) • [Getting Started](#-getting-started) • [Credits](#-credits) • [License](#-license)

_Universal command set and vibrant configurations. Compatible with [Windows](https://microsoft.com/windows), [macOS](https://apple.com/macos) and [Arch Linux](https://archlinux.org), these configurations are effortlessly managed using [chezmoi](https://chezmoi.io) for seamless synchronization._

<p>
  <strong>Be sure to <a href="#" title="star">⭐️</a> or fork this repo if you find it useful!</strong>
</p>
</div>

## 🚀 Features

The major features of this repository are:

- [**Neovim**](home/private_dot_config/exact_nvim) Configuration powered by [LazyVim](https://lazyvim.org) (cross-platform)
- [**WezTerm**](home/private_dot_config/exact_wezterm) Configuration with Neovim workflow integration (cross-platform)
- [**Visual Studio Code**](home/.chezmoitemplates/Code/User) Configuration (cross-platform)
- [**Hyprland**](home/.chezmoitemplates/hyprland) Configuration (Arch Linux)
- [**ags**](home/private_dot_config/ags) Configuration (Arch Linux)
- [**Oh My Posh**](home/private_dot_config/oh-my-posh/config.yml) Configuration (cross-platform)
- [**tmux**](home/private_dot_config/tmux/tmux.conf) Configuration with Session Management and Neovim workflow integration (UNIX)
- [**PowerShell**](home/Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl) Profile with extended Linux capabilities (Windows)
- [**Zsh**](home/dot_zshrc.tmpl) Profile powered by [Oh My Zsh](https://ohmyz.sh) including auto completions, fzf integration, syntax highlighting and more (UNIX)
- [**Scripts**](home/.chezmoiscripts) that properly ensure that system settings are set to my preference and [dependencies](home/.chezmoidata) are installed

Some of the additional features are:

- [**Git**](home/dot_gitconfig.tmpl) Configuration (cross-platform)
- [**Lazygit**](home/.chezmoitemplates/lazygit/config.yml) Configuration (cross-platform)
- [**bat**](home/.chezmoitemplates/bat/config) Configuration (cross-platform)
- [**WSL**](home/dot_wslconfig) Configuration (Windows)
- [**SSH**](home/private_dot_ssh) Configuration (cross-platform)
- [**ShellCheck**](home/dot_shellcheckrc) Configuration (cross-platform)
- **Font Management** to ensure Neovim, Neovide, WezTerm and VSCode have the same font settings (cross-platform)
- **Performance** always in mind (cross-platform)

## ⚙️ Requirements

- **Operating System (download latest stable version):**
  - [Windows](https://microsoft.com/windows)
  - [macOS](https://apple.com/macos)
  - [Arch Linux](https://archlinux.org)
- **Commands:**
  - [git](https://git-scm.com/downloads)
  - [chezmoi](https://chezmoi.io/install)
- **UNIX only:**
  - [wget](https://gnu.org/software/wget) or [curl](https://curl.se/download.html) installed
- **Windows only:**
  - [pwsh](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows)
  - **Fonts:** a Sans Font of choice, a [Nerd Font](https://nerdfonts.com/font-downloads) of choice, [Symbols Nerd Font](https://nerdfonts.com/font-downloads) and [Noto Color Emoji](https://fonts.google.com/noto) installed on your system

## 🏁 Getting Started

Use the install script to bootstrap your environment. Simply run the following command in your terminal:

#### Bash

```sh
bash -c "$(wget -qO- https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/install.sh)"
```

> We use `wget` here because it comes preinstalled with most UNIX operating systems. But you can also use `curl`:
>
> ```sh
> bash -c "$(curl -fsSL https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/install.sh)"
> ```

To pass environment variables:

```sh
BRANCH="beta" bash -c "$(wget -qO- https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/install.sh)"
```

#### PowerShell Core

```pwsh
iwr https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/install.ps1 | iex
```

To pass environment variables:

```pwsh
iwr https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/install.ps1 | iex -Branch "beta"
```

#### Environment Variables

- `BRANCH` (Bash) or `-Branch` (PowerShell) - The branch you want to install. Defaults to `master`.
- `SSH` (Bash) or `-SSH` (PowerShell) - Whether or not you want to install the dotfiles with SSH. Defaults to `false`.
- `ONE_SHOT` (Bash) or `-OneShot` (PowerShell) - Install your dotfiles and then remove all traces of chezmoi from the system. This is useful for setting up temporary environments (e.g. Docker containers). Defaults to `false`.

## 🙌 Credits

- [Tom Payne](https://github.com/twpayne)
  - creator of chezmoi
  - parts of his dotfiles are used
- [Folke Lemaitre](https://github.com/folke)
  - creator of [LazyVim](https://github.com/LazyVim/LazyVim)
  - parts of his dotfiles are used
- [Felipe Santos](https://github.com/felipecrs)
  - parts of his README are used
- [René-Marc Simard](https://github.com/renemarc)
  - the header section of his README is used

## 📝 License

This project is licensed under the Apache-2.0 license.
