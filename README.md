<div align="center">
<h1>
  ~/.dotfiles&nbsp;📂
  <br/>
  Cross-Platform & Cross-Shell Dotfiles
  <br/>
  <sup>
    <sub>Powered by a cross-platform CLI and chezmoi
    </sub>
  </sup>
</h1>

![Latest commit](https://img.shields.io/github/last-commit/Nitestack/dotfiles?style=for-the-badge)
![GitHub Repo stars](https://img.shields.io/github/stars/Nitestack/dotfiles?style=for-the-badge)
![Github Created At](https://img.shields.io/github/created-at/Nitestack/dotfiles?style=for-the-badge)

[Features](#-features) • [Requirements](#️-requirements) • [Getting Started](#-getting-started) • [Documentation](#-documentation) • [Credits](#-credits) • [License](#-license)

_Universal command set and vibrant shell configurations for [Zsh](https://zsh.org) and [PowerShell](https://learn.microsoft.com/powershell). Compatible with [Windows](https://microsoft.com/windows), [macOS](https://apple.com/macos), and (partially) Linux, these configurations are effortlessly managed using a [cross-platform CLI](scripts) customized specifically for the needs of this repository, alongside [chezmoi](https://chezmoi.io) for seamless synchronization._

<p>
  <strong>Be sure to <a href="#" title="star">⭐️</a> or fork this repo if you find it useful!</strong>
</p>
</div>

## 🚀 Features

The major features of this repository are:

- [**CLI**](scripts) tailored to this repository with a native [PowerShell](scripts/windows/dotfiles.ps1) and [Bash](scripts/unix/dotfiles) version (cross-platform)
- [**Neovim**](home/private_dot_config/exact_nvim) Configuration powered by [LazyVim](https://lazyvim.org) (cross-platform)
- [**WezTerm**](home/private_dot_config/exact_wezterm) Configuration (cross-platform)
- [**Visual Studio Code**](home/.chezmoitemplates/Code/User) Configuration (cross-platform)
- [**Scripts**](home/.chezmoiscripts):
  - Ensures installation of all dependencies listed in [`home/.chezmoidata`](home/.chezmoidata), supporting various package managers across different operating systems: [Chocolatey](https://community.chocolatey.org) and [winget](https://learn.microsoft.com/windows/package-manager/winget) for Windows, [brew](https://brew.sh) for macOS, [apt](https://ubuntu.com/server/docs/package-management) for Ubuntu, and [pacman](https://wiki.archlinux.org/title/pacman) for Arch Linux. Additionally, supports language-specific package managers such as [npm](https://npmjs.com) and [cargo](https://crates.io).
  - Sets up the Spaceship theme (UNIX).
  - Configures the default shell to be Zsh (Linux).
  - Sets up Mirrorlist backup (Arch Linux).
  - Ensures installation of brew (macOS).
  - Sets system preferences using `defaults` (macOS).

Some of the additional features are:

- [**tmux**](home/private_dot_config/tmux/tmux.conf) Configuration with [Session Management](https://github.com/omerxx/tmux-sessionx) (UNIX)
- [**Git**](home/dot_gitconfig.tmpl) Configuration (cross-platform)
- [**ShellCheck**](home/dot_shellcheckrc) Configuration
- [**Lazygit**](home/.chezmoitemplates/lazygit/config.yml) Configuration (cross-platform)
- [**PowerShell**](home/Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl) Profile (Windows)
- [**Zsh**](home/dot_zshrc.tmpl) Profile powered by [Oh My Zsh](https://ohmyz.sh) (UNIX)
- [**WSL**](home/dot_wslconfig) Configuration (Windows)

## ⚙️ Requirements

- **Operating System:**
  - [Windows](https://microsoft.com/windows)
  - [macOS](https://apple.com/macos)
  - **Linux:**
    - [Ubuntu](https://ubuntu.com)
    - [Arch Linux](https://archlinux.org)
- **Font:** a [Nerd Font](https://nerdfonts.com/font-downloads) of choice and [Symbols Nerd Font](https://nerdfonts.com/font-downloads) installed on your system
- **Commands:**
  - [git](https://git-scm.com/downloads)
  - [chezmoi](https://chezmoi.io/install)
  - **UNIX only:** [wget](https://gnu.org/software/wget) or [curl](https://curl.se/download.html) installed
  - **Windows only:** [pwsh](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows)

## 🏁 Getting Started

First you need to install the [`dotfiles`](scripts) CLI. Simply run the following command in your terminal:

#### Bash

```sh
wget -O ~/.local/bin/dotfiles https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/unix/dotfiles
```

> We use `wget` here because it comes preinstalled with most Linux distros. But you can also use `curl`:
>
> ```sh
> curl -o ~/.local/bin/dotfiles https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/unix/dotfiles
> ```

To make it executable, run:

```sh
chmod +x ~/.local/bin/dotfiles
```

> :warning: **Make sure to add the `~/.local/bin` directory to your `$PATH` variable or use another location.**
> Use the following command to append `~/.local/bin` to your `$PATH` variable in your Bash/Zsh config (`~/.bashrc` or `~/.zshrc`).

> ```sh
> echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.zshrc
> ```
>
> Or manually add the following line to your Bash/Zsh config:
>
> ```bash
> export PATH="$PATH:$HOME/.local/bin"
> ```

#### PowerShell Core

```pwsh
iwr https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/windows/dotfiles.ps1 -OutFile $env:USERPROFILE\.local\bin\dotfiles.ps1
```

> :warning: **Make sure to add the `$env:USERPROFILE\.local\bin` directory to your `PATH` or use another location.**
> Use the following command to append `$env:USERPROFILE\.local\bin` to your `PATH` in your PowerShell config (`$PROFILE`).
>
> ```pwsh
> Add-Content -Path $PROFILE -Value "`r`n`$env:PATH += `";`$env:USERPROFILE\.local\bin`""
> ```
>
> Or manually add the following line to your PowerShell config:
>
> ```ps1
> $env:PATH += ";$env:USERPROFILE\.local\bin"
> ```
>
> Alternatively, you can use the following command to permanently add it to your `PATH` environment variable, if it's not already there (therefore you don't need to add it into your PowerShell config).
>
> ```pwsh
> if (!([System.Environment]::GetEnvironmentVariable("PATH", "User").Split(";") -contains "$env:USERPROFILE\.local\bin")) { [System.Environment]::SetEnvironmentVariable("PATH", "$([System.Environment]::GetEnvironmentVariable('PATH', 'User'));$env:USERPROFILE\.local\bin", "User") }
> ```

---

Now you can run `dotfiles download` and `dotfiles install` to download and install the dotfiles. Run `dotfiles -h` to see the available commands.

> :bulb: **The -h flag works on Windows and UNIX!**

## 📚 Documentation

### CLI

The UNIX CLI version of `dotfiles` was created with [`Bashly`](https://bashly.dannyb.co).
The Windows CLI version of `dotfiles` was created with native [PowerShell](https://learn.microsoft.com/powershell).

Because PowerShell and Bash are so different from each other, the command flags will have minor differences.

The convention for UNIX-style CLI's is to use `-` for short flags and `--` for long flags. It uses the `kebab-case` if it is a long flag.
For example, `dotfiles -h` and `dotfiles --help` are the same command.

The convention for PowerShell is to use only `-`, but for short and long flags. It uses the `PascalCase` if it is a long flag.
For example, `dotfiles -h` and `dotfiles -Help` or even `Get-Help dotfiles` are the same command.

> :bulb: **As you might have noticed, the `-h` flag works on both Windows and UNIX!**

> :bulb: **The short flags (if any) also work on both Windows and UNIX!**

Other than these conventions, the Bash version of `dotfiles` is equal to the Windows version. They come with the same commands and flags.

## 🙌 Credits

- [Folke Lemaitre](https://github.com/folke) - his popular Neovim configuration [LazyVim](https://github.com/LazyVim/LazyVim)
  - many of the plugins and their configurations are used
- [Felipe Santos](https://github.com/felipecrs) - take a look at his [dotfiles](https://github.com/felipecrs/dotfiles)
  - parts of his README are used
  - the install scripts for Ubuntu are used, modified and extended
- [René-Marc Simard](https://github.com/renemarc) - take a look at his [dotfiles](https://github.com/renemarc/dotfiles)
  - the top section of his README is used

## 📝 License

This project is licensed under the Apache-2.0 license.
