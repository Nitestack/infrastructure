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

- **Komorebi Configuration**: Customizations and tweaks for the tiling window manager (extension to the [Desktop Window Manager](https://docs.microsoft.com/en-us/windows/win32/dwm/dwm-overview))

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

| Modifiers | Key | Description | Flags |
| --- | --- | --- | --- |
| Ctrl + Shift | R | Reload `ags` | - |
| Win | Tab | Toggle Workspaces Overview | - |
| Alt | Space | Toggle App Launcher | - |
| Win | V | Open Clipboard History | - |
| - | PowerOff Button | Toggle Power Menu | - |
| - | Print | Take Screenshot (Select Area) | - |
| Win | Print | Take Fullscreen Screenshot | - |
| Win + Alt | Print | Start Screen Recording | - |
| Win | Backslash | Open Terminal | - |
| Win | E | Open File Manager | - |
| Win | W | Open Browser | - |
| - | AudioLowerVolume Button | Decrease Volume | `l`, `e` |
| - | AudioRaiseVolume Button | Increase Volume | `l`, `e` |
| - | AudioMute Button | Mute/Unmute Volume | `l` |
| - | AudioMicMute Button | Mute/Unmute Microphone | `l` |
| - | AudioPlay Button | Play/Pause | `l` |
| - | AudioPause Button | Play/Pause | `l` |
| - | AudioNext Button | Skip to Next Track | `l` |
| - | AudioPrev Button | Return to Previous Track | `l` |
| - | MonBrightnessDown Button | Decrease Screen Brightness | `l`, `e` |
| - | MonBrightnessUp Button | Increase Screen Brightness | `l`, `e` |
| Win | H | Move Focus to Left Window | - |
| Win | L | Move Focus to Right Window | - |
| Win | K | Move Focus to Upper Window | - |
| Win | J | Move Focus to Lower Window | - |
| Win | Right Mouse Button | Resize Window | - |
| Win | F | Toggle Fullscreen | - |
| Win | M | Maximize/Restore Window | - |
| Win | Left | Resize Window to the Left | `e` |
| Win | Right | Resize Window to the Right | `e` |
| Win | Up | Resize Window Upwards | `e` |
| Win | Down | Resize Window Downwards | `e` |
| Win | Left Mouse Button | Move Window | - |
| Win + Alt | H | Move Window Left | - |
| Win + Alt | L | Move Window Right | - |
| Win + Alt | K | Move Window Upwards | - |
| Win + Alt | J | Move Window Downwards | - |
| Win | Q | Close Active Window | - |
| Win | C | Center Window | - |
| Win | P | Toggle Focused Window's Pseudo Mode | - |
| Win | R | Toggle Split Orientation | - |
| Win | T | Toggle Active Window Floating | - |
| Win + Shift | T | Toggle All Windows Floating | - |
| Win | 1 | Switch to Workspace 1 | - |
| Win | 2 | Switch to Workspace 2 | - |
| Win | 3 | Switch to Workspace 3 | - |
| Win | 4 | Switch to Workspace 4 | - |
| Win | 5 | Switch to Workspace 5 | - |
| Win | 6 | Switch to Workspace 6 | - |
| Win | 7 | Switch to Workspace 7 | - |
| Win | 8 | Switch to Workspace 8 | - |
| Win | 9 | Switch to Workspace 9 | - |
| Win | 0 | Switch to Workspace 10 | - |
| Win + Ctrl | H | Switch to Previous Workspace | - |
| Win + Ctrl | L | Switch to Next Workspace | - |
| Win | Mouse Wheel Down | Switch to Previous Workspace | - |
| Win | Mouse Wheel Up | Switch to Next Workspace | - |
| Win + Shift | 1 | Move Active Window to Workspace 1 | - |
| Win + Shift | 2 | Move Active Window to Workspace 2 | - |
| Win + Shift | 3 | Move Active Window to Workspace 3 | - |
| Win + Shift | 4 | Move Active Window to Workspace 4 | - |
| Win + Shift | 5 | Move Active Window to Workspace 5 | - |
| Win + Shift | 6 | Move Active Window to Workspace 6 | - |
| Win + Shift | 7 | Move Active Window to Workspace 7 | - |
| Win + Shift | 8 | Move Active Window to Workspace 8 | - |
| Win + Shift | 9 | Move Active Window to Workspace 9 | - |
| Win + Shift | 0 | Move Active Window to Workspace 10 | - |
| Win + Shift | H | Move Active Window to Previous Workspace | - |
| Win + Shift | L | Move Active Window to Next Workspace | - |
| Win | S | Toggle Scratchpad | - |
| Win + Shift | S | Move Active Window to Scratchpad | - |

#### Binding Flags

From the [Hyprland binding flags reference](https://wiki.hyprland.org/Configuring/Binds/#bind-flags):

- `l` - locked, will also work when an input inhibitor (e.g. a lockscreen) is active.
- `r` - release, will trigger on release of a key.
- `e` - repeat, will repeat when held.
- `n` - non-consuming, key/mouse events will be passed to the active window in addition to triggering the dispatcher.
- `t` - transparent, cannot be shadowed by other binds.
- `i` - ignore mods, will ignore modifiers.
- `s` - separate, will arbitrarily combine keys between each mod/key, see [Keysym combos](https://wiki.hyprland.org/Configuring/Binds/#keysym-combos).

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
