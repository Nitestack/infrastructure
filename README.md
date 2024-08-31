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

![image](https://github.com/Nitestack/dotfiles/assets/74626967/154b824c-42f2-4ec0-818b-f244f8c91f4b)

_Elevate your computing experience across platforms with this curated collection of configuration files and setup scripts. From [NixOS](https://nixos.org) to [macOS](https://apple.com/macos) and [Windows](https://microsoft.com/windows), personalize your environment effortlessly, managed securely across multiple diverse machines using [chezmoi](https://chezmoi.io). Leverage advanced features like templates, password manager support, file encryption, and script execution for seamless deployment and synchronization._

<p>
  <strong>Be sure to <a href="#" title="star">⭐️</a> or fork this repo if you find it useful!</strong>
</p>
</div>

## 🚀 Features

### Cross-Platform (NixOS, macOS, Windows)

- **Neovim Configuration**: Powered by [LazyVim](http://www.lazyvim.org), ensuring a robust and efficient text editing experience

- **WezTerm Configuration**: Integrated Neovim workflow for a seamless terminal and text editing setup

- **Visual Studio Code Configuration**: Settings and extensions for an optimized development environment

- **Oh My Posh Configuration**: Customized prompt for a visually appealing and informative shell experience

- **Fastfetch Configuration**: Customized settings for a fast and efficient system information display

- **bat Configuration**: Themed with the [Catppuccin Mocha](https://github.com/catppuccin/bat) theme

- **Lazygit Configuration**: Themed with the [Catppuccin Mocha](https://github.com/catppuccin/lazygit) theme for a cohesive look and feel

- **Spicetify Configuration**: Add extensibility and customization to Spotify

- **Git Configuration**: Customized settings for version control

- **ShellCheck Configuration**: Setup for shell script analysis

- **SSH Configuration**: Consistent and secure SSH setup across systems

- **Package & App Management**: Consistent management of common apps and packages across all systems, including system-specific packages and apps

- **Font Management**: Ensuring a uniform look and feel across different platforms, with support for Nerd icons ([Symbols Nerd Font](https://www.nerdfonts.com/font-downloads)) and emojis ([Noto Color Emoji](https://fonts.google.com/noto))

- **Performance Always in Mind**: Optimized configurations to ensure efficient and smooth performance

### UNIX

- **tmux Configuration**: Themed with the [Catppuccin Mocha](https://github.com/catppuccin/tmux) theme, featuring session management and an integrated Neovim workflow

- **Zed Configuration**: Settings for the new lightweight code editor

- **Zsh Configuration**: Powered by [Oh My Zsh](https://ohmyz.sh), this configuration includes styled prompts, shell completions, optimized history settings, and useful aliases for a seamless command-line experience

### macOS

- **Dependency Management**: Managed with [Homebrew](https://brew.sh), including [formulae](https://formulae.brew.sh), [casks](https://formulae.brew.sh/cask), fonts, and Mac App Store applications (via [mas](https://github.com/mas-cli/mas)), all bundled using [`brew bundle`](https://github.com/Homebrew/homebrew-bundle)

- **System Settings**: Configured using `defaults` to set macOS system preferences and settings

### Windows

- **WSL Configuration**: Optimized settings for Windows Subsystem for Linux (WSL) to ensure seamless integration and performance

- **PowerShell Profile**: Customized PowerShell profile with a styled prompt, optimized history settings, aliases, and various Linux utilities ported over to PowerShell for enhanced productivity

- **Komorebi Configuration**: Customizations and tweaks for the tiling window manager (extension to the [Desktop Window Manager](https://docs.microsoft.com/windows/win32/dwm/dwm-overview))

---

And more to discover.

## ⚙️ Requirements

Ensure you have the latest stable release of [NixOS](https://nixos.org), [macOS](https://apple.com/macos) or [Windows](https://microsoft.com/windows) installed.

### Dependencies

[**Homebrew**](https://brew.sh) (**macOS only**)

```sh
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | /bin/bash
```

[**Git**](https://www.git-scm.com)

macOS:

```sh
brew install git
```

Windows:

```pwsh
winget install -e --accept-package-agreements --accept-source-agreements --id Git.Git
```

[**chezmoi**](https://chezmoi.io)

macOS:

```sh
brew install chezmoi
```

Windows:

```pwsh
winget install -e --accept-package-agreements --accept-source-agreements --id twpayne.chezmoi
```

[**Wget**](https://www.gnu.org/software/wget) or [**curl**](https://curl.se) (**UNIX only**)

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

### Bindings

| Modifiers | Key | Description | OS | Flags |
| --- | --- | --- | --- | --- |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> | <kbd>R</kbd> | Reload `ags` | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>Tab</kbd> | Toggle Workspaces Overview | `L` | - |
| <kbd>Alt</kbd> | <kbd>Space</kbd> | Toggle App Launcher | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>V</kbd> | Open Clipboard History | `L`, `W` | - |
| - | <kbd>PowerOff Button</kbd> | Toggle Power Menu | `L`, `W` | - |
| - | <kbd>Print</kbd> | Take Screenshot (Select Area) | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>Print</kbd> | Take Fullscreen Screenshot | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Alt</kbd> | <kbd>Print</kbd> | Start Screen Recording | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>Backslash</kbd> | Open Terminal | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>E</kbd> | Open File Manager | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>W</kbd> | Open Browser | `L`, `W` | - |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> | <kbd>Escape</kbd> | Open System Monitor | `L`, `W` | - |
| - | <kbd>AudioLowerVolume Button</kbd> | Decrease Volume | `L`, `W` | `l`, `e` |
| - | <kbd>AudioRaiseVolume Button</kbd> | Increase Volume | `L`, `W` | `l`, `e` |
| - | <kbd>AudioMute Button</kbd> | Mute/Unmute Volume | `L`, `W` | `l` |
| - | <kbd>AudioMicMute Button</kbd> | Mute/Unmute Microphone | `L`, `W` | `l` |
| - | <kbd>AudioPlay Button</kbd> | Play/Pause | `L`, `W` | `l` |
| - | <kbd>AudioPause Button</kbd> | Play/Pause | `L`, `W` | `l` |
| - | <kbd>AudioNext Button</kbd> | Skip to Next Track | `L`, `W` | `l` |
| - | <kbd>AudioPrev Button</kbd> | Return to Previous Track | `L`, `W` | `l` |
| - | <kbd>MonBrightnessDown Button</kbd> | Decrease Screen Brightness | `L`, `W` | `l`, `e` |
| - | <kbd>MonBrightnessUp Button</kbd> | Increase Screen Brightness | `L`, `W` | `l`, `e` |
| <kbd>Win</kbd> | <kbd>H</kbd> | Move Focus to Left Window | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>L</kbd> | Move Focus to Right Window | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>K</kbd> | Move Focus to Upper Window | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>J</kbd> | Move Focus to Lower Window | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>Right Mouse Button</kbd> | Resize Window | `L` | - |
| <kbd>Win</kbd> | <kbd>F</kbd> | Toggle Fullscreen | `L` | - |
| <kbd>Win</kbd> | <kbd>M</kbd> | Maximize/Restore Window | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>←</kbd> | Resize Window to the Left | `L`, `W` | `e` |
| <kbd>Win</kbd> | <kbd>→</kbd> | Resize Window to the Right | `L`, `W` | `e` |
| <kbd>Win</kbd> | <kbd>↑</kbd> | Resize Window Upwards | `L`, `W` | `e` |
| <kbd>Win</kbd> | <kbd>↓</kbd> | Resize Window Downwards | `L`, `W` | `e` |
| <kbd>Win</kbd> | <kbd>Left Mouse Button</kbd> | Move Window | `L` | - |
| <kbd>Win</kbd> + <kbd>Alt</kbd> | <kbd>H</kbd> | Move Window Left | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Alt</kbd> | <kbd>L</kbd> | Move Window Right | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Alt</kbd> | <kbd>K</kbd> | Move Window Upwards | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Alt</kbd> | <kbd>J</kbd> | Move Window Downwards | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>Q</kbd> | Close Active Window | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>C</kbd> | Center Window | `L` | - |
| <kbd>Win</kbd> | <kbd>P</kbd> | Toggle Focused Window's Pseudo Mode | `L` | - |
| <kbd>Win</kbd> | <kbd>R</kbd> | Toggle Split Orientation | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>T</kbd> | Toggle Active Window Floating | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Shift</kbd> | <kbd>T</kbd> | Toggle All Windows Floating | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>1</kbd> | Switch to Workspace 1 | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>2</kbd> | Switch to Workspace 2 | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>3</kbd> | Switch to Workspace 3 | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>4</kbd> | Switch to Workspace 4 | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>5</kbd> | Switch to Workspace 5 | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>6</kbd> | Switch to Workspace 6 | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>7</kbd> | Switch to Workspace 7 | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>8</kbd> | Switch to Workspace 8 | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>9</kbd> | Switch to Workspace 9 | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>0</kbd> | Switch to Workspace 10 | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Ctrl</kbd> | <kbd>H</kbd> | Switch to Previous Workspace | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Ctrl</kbd> | <kbd>L</kbd> | Switch to Next Workspace | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>Mouse Wheel Down</kbd> | Switch to Previous Workspace | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>Mouse Wheel Up</kbd> | Switch to Next Workspace | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Shift</kbd> | <kbd>1</kbd> | Move Active Window to Workspace 1 | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Shift</kbd> | <kbd>2</kbd> | Move Active Window to Workspace 2 | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Shift</kbd> | <kbd>3</kbd> | Move Active Window to Workspace 3 | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Shift</kbd> | <kbd>4</kbd> | Move Active Window to Workspace 4 | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Shift</kbd> | <kbd>5</kbd> | Move Active Window to Workspace 5 | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Shift</kbd> | <kbd>6</kbd> | Move Active Window to Workspace 6 | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Shift</kbd> | <kbd>7</kbd> | Move Active Window to Workspace 7 | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Shift</kbd> | <kbd>8</kbd> | Move Active Window to Workspace 8 | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Shift</kbd> | <kbd>9</kbd> | Move Active Window to Workspace 9 | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Shift</kbd> | <kbd>0</kbd> | Move Active Window to Workspace 10 | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Shift</kbd> | <kbd>H</kbd> | Move Active Window to Previous Workspace | `L`, `W` | - |
| <kbd>Win</kbd> + <kbd>Shift</kbd> | <kbd>L</kbd> | Move Active Window to Next Workspace | `L`, `W` | - |
| <kbd>Win</kbd> | <kbd>S</kbd> | Toggle Scratchpad | `L` | - |
| <kbd>Win</kbd> + <kbd>Shift</kbd> | <kbd>S</kbd> | Move Active Window to Scratchpad | `L` | - |

#### OS Compatibility

- `L` - Linux
- `W` - Windows
- `M` - macOS

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
- [Pratik Gayen](https://github.com/FireDrop6000/hyprland-mydots)
  - Hyprlock config is used

## 📝 License

This project is licensed under the Apache-2.0 license.
