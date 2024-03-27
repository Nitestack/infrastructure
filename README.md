# Nitestack/dotfiles

This repo contains my dotfiles. To manage my dotfiles across different devices and operating systems, I use [`chezmoi`](https://chezmoi.io/).

> It is currently aimed for Windows, Ubuntu and Arch Linux, as they are the most common platforms I use.

## Getting started

First you need to install the `dotfiles` CLI. Simply run the following command in your terminal:

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
> Use the following command to append `~/.local/bin` to your `$PATH` variable in your Bash/zsh config (`~/.bashrc` or `~/.zshrc`).

> ```sh
> echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
> ```
>
> Or manually add the following line to your Bash/zsh config:
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

## Documentation

The UNIX CLI version of `dotfiles` was created with [`Bashly`](https://bashly.dannyb.co).
The Windows CLI version of `dotfiles` was created with pure PowerShell.

Because PowerShell and Bash/zsh are different from each other, the flags are not the same.

The convention for UNIX-style CLI's is to use `-` for short flags and `--` for long flags. It uses the `kebab-case` if it is a long flag.
For example, `dotfiles -h` and `dotfiles --help` are the same command.

The convention for PowerShell is to use only `-`, but for short and long flags. It uses the `PascalCase` if it is a long flag.
For example, `dotfiles -h` and `dotfiles -Help` or even `Get-Help dotfiles` are the same command.

> :bulb: **As you might have noticed, the `-h` flag works on both Windows and UNIX!**

> :bulb: **The short flags (if any) also work on both Windows and UNIX!**

Other than these conventions, the UNIX cli version of `dotfiles` is similar to the Windows version. They use the same commands with the same flags.

## Credits

- [Folke Lemaitre](https://github.com/folke) - his popular Neovim configuration [LazyVim](https://github.com/LazyVim/LazyVim)
  - many of the plugins and their configurations are used
- [Felipe Santos](https://github.com/felipecrs) - take a look at his [dotfiles](https://github.com/felipecrs/dotfiles)
  - parts of his README are used
  - the install scripts for Ubuntu are used, modified and extended
