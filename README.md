# Nitestack/dotfiles

This repo contains my dotfiles. To manage my dotfiles across different devices and operating systems, I use [`chezmoi`](https://chezmoi.io/).

> It is currently aimed for Windows, Ubuntu and Arch Linux, as they are the most common platforms I use.

## Getting started

#### Bash

First you need to install the `dotfiles` CLI. Simply run the following command in your terminal:

```sh
wget -O ~/.local/bin/dotfiles https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/dotfiles
```

> We use `wget` here because it comes preinstalled with most Linux distros. But you can also use `curl`:
>
> ```sh
> curl -o ~/.local/bin/dotfiles https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/dotfiles
> ```

To make it executable, run:

```sh
chmod +x ~/.local/bin/dotfiles
```

> :warning: **Make sure to add the `~/.local/bin` directory to your `$PATH` variable or use another location.**

Now you can run `dotfiles download` and `dotfiles install` to download and install the dotfiles. Run `dotfiles --help` to see the available commands.

#### PowerShell Core

The CLI for Windows is not available yet. That's why you have to use the old convenience script.

```pwsh
iwr https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/install_dotfiles.ps1 -UseBasicParsing | iex
```

---

## Documentation

**If you followed the steps above so far, you already finished installing the dotfiles. Have fun!**

The below information is more for reference purposes.

### Convenience script

The [getting started](#getting-started) step used the convenience scripts to install this dotfiles. There are some extra options that you can use to tweak the installation if you need.

It supports some environment variables:

- `DOTFILES_REPO_HOST`: Defaults to `https://github.com`.
- `DOTFILES_USER`: Defaults to `Nitestack`.
- `DOTFILES_BRANCH`: Defaults to `master`.

For example, you can use it to clone and install the dotfiles repository at the `beta` branch with:

#### PowerShell Core

```pwsh
pwsh -c { $env:DOTFILES_BRANCH="beta"; iwr https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/install_dotfiles.ps1 -UseBasicParsing | iex }
```

### Installing without the convenience script

If you prefer not to use the convenience script to install the dotfiles, you can also do it manually:

#### PowerShell Core

```pwsh
git clone https://github.com/Nitestack/dotfiles "$env:USERPROFILE\.dotfiles"

iex "$env:USERPROFILE\.dotfiles\install.ps1"
```

### Update

To update the dotfiles, run:

```shell
chezmoi update
```

To force a refresh the downloaded external archives, use the `--refresh-externals` or `-R` flag:

```shell
chezmoi update -R
```

> For more information on how to use chezmoi, visit their [documentation](https://chezmoi.io).

---

## Credits

- [Felipe Santos](https://github.com/felipecrs) - take a look at his [dotfiles](https://github.com/felipecrs/dotfiles)
  - parts of his README are used
  - the install scripts for Ubuntu are used, modified and extended
