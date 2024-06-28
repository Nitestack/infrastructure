<div align="center">
<h1>
  ~/.dotfiles&nbsp;📂
  <br/>
  Cross-Platform & Cross-Shell Dotfiles
  <br/>
  <sup>
    <sub>Powered by <a href="https://chezmoi.io" target="_blank">chezmoi</a></sub>
  </sup>
</h1>

![Latest commit](https://img.shields.io/github/last-commit/Nitestack/dotfiles?style=for-the-badge)
![GitHub Repo stars](https://img.shields.io/github/stars/Nitestack/dotfiles?style=for-the-badge)
![Github Created At](https://img.shields.io/github/created-at/Nitestack/dotfiles?style=for-the-badge)

[Features](#-features) • [Requirements](#️-requirements) • [Getting Started](#-getting-started) • [Documentation](#-documentation) • [Credits](#-credits) • [License](#-license)

![2024-06-27_19-06-06](https://github.com/Nitestack/dotfiles/assets/74626967/c419ca64-d908-4bdd-8bf2-bf44d59fd9fb)

_Elevate your computing experience across platforms with this curated collection of configuration files and setup scripts. From [Arch Linux](https://archlinux.org) to [macOS](https://apple.com/macos) and [Windows](https://microsoft.com/windows), personalize your environment effortlessly, managed securely across multiple diverse machines using [chezmoi](https://chezmoi.io) Leverage advanced features like templates, password manager support, file encryption, and script execution for seamless deployment and synchronization._

<p>
  <strong>Be sure to <a href="#" title="star">⭐️</a> or fork this repo if you find it useful!</strong>
</p>
</div>

## 🚀 Features

### Cross-Platform (Arch Linux, macOS, Windows)

- **Neovim Configuration**: Powered by [LazyVim](http://www.lazyvim.org), ensuring a robust and efficient text editing experience

- **WezTerm Configuration**: Integrated Neovim workflow for a seamless terminal and text editing setup

- **Visual Studio Code Configuration**: Settings and extensions for an optimized development environment

- **Oh My Posh Configuration**: Customized prompt for a visually appealing and informative shell experience

- **Fastfetch Configuration**: Customized settings for a fast and efficient system information display

- **bat Configuration**: Themed with the [Catppuccin Mocha](https://github.com/catppuccin/bat) theme

- **Lazygit Configuration**: Themed with the [Catppuccin Mocha](https://github.com/catppuccin/lazygit) theme for a cohesive look and feel

- **Git Configuration**: Customized settings for version control

- **ShellCheck Configuration**: Setup for shell script analysis

- **SSH Configuration**: Consistent and secure SSH setup across systems

- **Package & App Management**: Consistent management of common apps and packages across all systems, including system-specific packages and apps

- **Font Management**: Ensuring a uniform look and feel across different platforms, with support for Nerd icons ([Symbols Nerd Font](https://www.nerdfonts.com/font-downloads)) and emojis ([Noto Color Emoji](https://fonts.google.com/noto))

- **Performance Always in Mind**: Optimized configurations to ensure efficient and smooth performance

### UNIX

- **tmux Configuration**: Themed with the [Catppuccin Mocha](https://github.com/catppuccin/tmux) theme, featuring session management and an integrated Neovim workflow

- **Zsh Configuration**: Powered by [Oh My Zsh](https://ohmyz.sh), this configuration includes styled prompts, shell completions, optimized history settings, and useful aliases for a seamless command-line experience

### Arch Linux

This repository provides a comprehensive setup for Arch Linux, including:

- **Hyprland Configuration**: Customized settings and tweaks for the Wayland compositor

- **AGS Configuration**: Beautiful and functional Wayland widgets configuration using [ags](https://aylur.github.io/ags-docs)

- **GRUB Setup**: Configured GRUB options and themed with [Hyperfluent Arch](https://github.com/Coopydood/HyperFluent-GRUB-Theme/tree/main)

- **SDDM Theme**: Aesthetic display manager theme using [Astronaut Theme](https://github.com/Keyitdev/sddm-astronaut-theme)

- **System Services**: Automatic setup for essential services like [Bluetooth](https://wiki.archlinux.org/title/bluetooth)

- **Synced Theming**: Consistent theming across different applications and system components

- **Pacman Configuration**: Enhanced pacman settings for faster downloads and updated servers using [reflector](https://wiki.archlinux.org/title/reflector), along with efficient package cache management ([paccache](https://wiki.archlinux.org/title/Pacman#Cleaning_the_package_cache))

- **AUR Helper**: Inclusion of [paru](https://github.com/Morganamilo/paru) for seamless access to AUR packages

- **Zsh**: Zsh shell configuration for an improved command-line experience

After installing Arch Linux on a new machine, this repository can set up the rest of the system to work properly, ensuring a smooth and efficient workflow.

### macOS

- **Dependency Management**: Managed with [Homebrew](https://brew.sh), including [formulae](https://formulae.brew.sh), [casks](https://formulae.brew.sh/cask), fonts, and Mac App Store applications (via [mas](https://github.com/mas-cli/mas)), all bundled using [`brew bundle`](https://github.com/Homebrew/homebrew-bundle)

- **System Settings**: Configured using `defaults` to set macOS system preferences and settings

### Windows

- **WSL Configuration**: Optimized settings for Windows Subsystem for Linux (WSL) to ensure seamless integration and performance

- **PowerShell Profile**: Customized PowerShell profile with a styled prompt, optimized history settings, aliases, and various Linux utilities ported over to PowerShell for enhanced productivity

---

And more to discover.

## ⚙️ Requirements

Ensure you have the latest stable release of [Arch Linux](https://archlinux.org), [macOS](https://apple.com/macos) or [Windows](https://microsoft.com/windows) installed.

### Dependencies

[**Homebrew**](https://brew.sh) (**macOS only**)

```sh
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | /bin/bash
```

[**Git**](https://www.git-scm.com)

Arch Linux:

```sh
sudo pacman -S --needed --noconfirm git
```

macOS:

```sh
brew install git
```

Windows:

```pwsh
winget install -e --accept-package-agreements --accept-source-agreements --id Git.Git
```

[**chezmoi**](https://chezmoi.io)

Arch Linux:

```sh
sudo pacman -S --needed --noconfirm chezmoi
```

macOS:

```sh
brew install chezmoi
```

Windows:

```pwsh
winget install -e --accept-package-agreements --accept-source-agreements --id twpayne.chezmoi
```

[**Wget**](https://www.gnu.org/software/wget) or [**curl**](https://curl.se) (**UNIX only**)

Arch Linux:

```sh
sudo pacman -S --needed --noconfirm wget curl
```

macOS (`curl` is pre-installed, but if you want to use `wget`):

```sh
brew install wget
```

[**PowerShell**](https://microsoft.com/PowerShell) (**Windows only**)

> All versions of Windows come with PowerShell 5.1 pre-installed. However, please note that this repository requires PowerShell 7.x or higher. PowerShell 7.x+ does not replace or upgrade PowerShell 5.1; instead, it is installed alongside PowerShell 5.1.

```pwsh
winget install -e --accept-package-agreements --accept-source-agreements --id Microsoft.PowerShell
```

**Fonts** (**Windows only**)

- [Rubik Font](https://fonts.google.com/specimen/Rubik)
- [MonaspiceNe Nerd Font](https://nerdfonts.com/font-downloads)
- [Symbols Nerd Font](https://nerdfonts.com/font-downloads)
- [Noto Color Emoji](https://fonts.google.com/noto)

## 🏁 Getting Started

### Installation

#### UNIX

To install on UNIX systems, run the following command in your terminal:

```sh
curl -fsSL https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/install.sh | bash
```

Or, using `wget`:

```sh
wget -qO- https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/install.sh | bash
```

#### Windows

To install on Windows, run the following command in PowerShell:

```pwsh
iwr https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/install.ps1 | iex
```

### Environment Variables

You can customize the installation by passing environment variables to the installation script:

- `BRANCH` (for Bash) or `-Branch` (for PowerShell): Specify the branch you want to install. Defaults to `master`.
- `SSH` (for Bash) or `-SSH` (for PowerShell): Set to `true` if you want to install the dotfiles with SSH. Defaults to `false`.
- `ONE_SHOT` (for Bash) or `-OneShot` (for PowerShell): Set to `true` to install your dotfiles and then remove all traces of chezmoi from the system. Useful for setting up temporary environments (e.g., Docker containers). Defaults to `false`.

For example, to install using a specific branch:

```sh
curl -fsSL https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/install.sh | BRANCH="dev" bash
```

```pwsh
iwr https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/install.ps1 | iex -Branch "dev"
```

## 📖 Documentation

### Hyprland Bindings

| Modifiers | Key | Dispatcher | Params | Flags | Description |
| --- | --- | --- | --- | --- | --- |
| Ctrl + Shift | R | exec | `ags -b hypr quit; ags -b hypr` | - | - |
| Alt | Tab | exec | `ags -b hypr -t overview` | - | - |
| Alt | Space | exec | `ags -b hypr -t launcher` | - | - |
| Super | V | exec | `ags -b hypr -r 'launcher.open(":ch ")'` | - | - |
|  | XF86PowerOff | exec | `ags -b hypr -t powermenu` | - | - |
|  | Print | exec | `ags -b hypr -r 'recorder.screenshot()'` | - | - |
| Super | Print | exec | `ags -b hypr -r 'recorder.screenshot(true)'` | - | - |
| Super + Alt | Print | exec | `ags -b hypr -r 'recorder.start()'` | - | - |
| Super | Backslash | exec | `wezterm start -- tmux` | - | - |
| Super | E | exec | `nautilus --new-window` | - | - |
| Super | W | exec | `firefox-developer-edition` | - | - |
|  | XF86AudioLowerVolume | exec | `wpctl set-volume @DEFAULT_AUDIO_SINK@ -l 1 2%-` | `l`, `e` | - |
|  | XF86AudioRaiseVolume | exec | `wpctl set-volume @DEFAULT_AUDIO_SINK@ -l 1 2%+` | `l`, `e` | - |
|  | XF86AudioMute | exec | `wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle` | `l` | - |
|  | XF86AudioMicMute | exec | `wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle` | `l` | - |
|  | XF86AudioPlay | exec | `playerctl play-pause` | `l` | - |
|  | XF86AudioPause | exec | `playerctl play-pause` | `l` | - |
|  | XF86AudioNext | exec | `playerctl next` | `l` | - |
|  | XF86AudioPrev | exec | `playerctl previous` | `l` | - |
|  | XF86MonBrightnessDown | exec | `brightnessctl set 5%-` | `l`, `e` | - |
|  | XF86MonBrightnessUp | exec | `brightnessctl set +5%` | `l`, `e` | - |
| Super | H | movefocus | `l` | - | - |
| Super | L | movefocus | `r` | - | - |
| Super | K | movefocus | `u` | - | - |
| Super | J | movefocus | `d` | - | - |
| Super | Mouse:273 | resizewindow | `-` | `m` | - |
| Super | F | fullscreen | `0` | - | - |
| Super | M | fullscreen | `1` | - | - |
| Super | Left | resizeactive | `-20 0` | `e` | - |
| Super | Right | resizeactive | `20 0` | `e` | - |
| Super | Up | resizeactive | `0 -20` | `e` | - |
| Super | Down | resizeactive | `0 20` | `e` | - |
| Super | Mouse:272 | movewindow | `-` | `m` | - |
| Super + Alt | H | movewindow | `l` | - | - |
| Super + Alt | L | movewindow | `r` | - | - |
| Super + Alt | K | movewindow | `u` | - | - |
| Super + Alt | J | movewindow | `d` | - | - |
| Super | Q | killactive | `-` | - | - |
| Super | C | centerwindow | `1` | - | - |
| Super | P | pseudo | `-` | - | - |
| Super | R | togglesplit | `-` | - | - |
| Super | T | togglefloating | `-` | - | - |
| Super + Shift | T | exec | `hyprctl dispatch workspaceopt allfloat` | - | - |
| Super | 1 | workspace | `1` | - | - |
| Super | 2 | workspace | `2` | - | - |
| Super | 3 | workspace | `3` | - | - |
| Super | 4 | workspace | `4` | - | - |
| Super | 5 | workspace | `5` | - | - |
| Super | 6 | workspace | `6` | - | - |
| Super | 7 | workspace | `7` | - | - |
| Super | 8 | workspace | `8` | - | - |
| Super | 9 | workspace | `9` | - | - |
| Super | 0 | workspace | `10` | - | - |
| Super + Ctrl | H | workspace | `e-1` | - | - |
| Super + Ctrl | L | workspace | `e+1` | - | - |
| Super | Mouse_down | workspace | `e+1` | - | - |
| Super | Mouse_up | workspace | `e-1` | - | - |
| Super + Shift | 1 | movetoworkspace | `1` | - | - |
| Super + Shift | 2 | movetoworkspace | `2` | - | - |
| Super + Shift | 3 | movetoworkspace | `3` | - | - |
| Super + Shift | 4 | movetoworkspace | `4` | - | - |
| Super + Shift | 5 | movetoworkspace | `5` | - | - |
| Super + Shift | 6 | movetoworkspace | `6` | - | - |
| Super + Shift | 7 | movetoworkspace | `7` | - | - |
| Super + Shift | 8 | movetoworkspace | `8` | - | - |
| Super + Shift | 9 | movetoworkspace | `9` | - | - |
| Super + Shift | 0 | movetoworkspace | `10` | - | - |
| Super + Shift | H | movetoworkspace | `e-1` | - | - |
| Super + Shift | L | movetoworkspace | `e+1` | - | - |
| Super | S | togglespecialworkspace | `magic` | - | - |
| Super + Shift | S | movetoworkspace | `special:magic` | - | - |

## 🙌 Credits

- [Tom Payne](https://github.com/twpayne)
  - creator of [chezmoi](https://chezmoi.io)
  - parts of his dotfiles are used
- [Folke Lemaitre](https://github.com/folke)
  - creator of [LazyVim](https://github.com/LazyVim/LazyVim)
  - parts of his dotfiles are used
- [Felipe Santos](https://github.com/felipecrs)
  - parts of his README are used
- [René-Marc Simard](https://github.com/renemarc)
  - the header section of his dotfiles README is used
- [Aylur](https://github.com/Aylur)
  - creator of [ags](https://aylur.github.io/ags-docs)
  - his ags configuration was used as a base
- [end-4](https://github.com/end-4)
  - parts of his dotfiles are used

## 📝 License

This project is licensed under the Apache-2.0 license.
