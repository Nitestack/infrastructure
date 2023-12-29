# Nitestack/dotfiles

This repo contains my dotfiles. To manage my dotfiles across different devices and operating systems, I use [`chezmoi`](https://chezmoi.io/).

It is currently aimed for Windows, Ubuntu and WSL (Ubuntu), as they are the most common platforms I use.

## Getting started

You can use the convenience scripts to install the dotfiles. Simply run the following command in your terminal:

#### Bash

```sh
sh -c "$(wget -qO- https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/install_dotfiles.sh)"
```

> We use `wget` here because it comes preinstalled with most Ubuntu versions. But you can also use `curl`:
>
> ```sh
> sh -c "$(curl -fsSL https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/install_dotfiles.sh)"
> ```

#### PowerShell Core

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

#### Bash

```sh
DOTFILES_BRANCH="beta" sh -c "$(wget -qO- https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/install_dotfiles.sh)"
```

#### PowerShell Core

```pwsh
pwsh -c { $env:DOTFILES_BRANCH="beta"; iwr https://raw.githubusercontent.com/Nitestack/dotfiles/HEAD/scripts/install_dotfiles.ps1 -UseBasicParsing | iex }
```

### Installing without the convenience script

If you prefer not to use the convenience script to install the dotfiles, you can also do it manually:

#### Bash

```bash
git clone https://github.com/Nitestack/dotfiles "$HOME/.dotfiles"

"$HOME/.dotfiles/install.sh"
```

#### PowerShell Core

```pwsh
git clone https://github.com/Nitestack/dotfiles "$env:USERPROFILE\.dotfiles"

iex "$env:USERPROFILE\.dotfiles\install.ps1"
```

### Update

To update my dotfiles, run:

#### Bash

```bash
chezmoi update --source="$HOME/.dotfiles"
```

#### PowerShell Core

```pwsh
chezmoi update --source="$env:USERPROFILE\.dotfiles"
```

To force a refresh the downloaded external archives, use the `--refresh-externals` or `-R` flag:

#### Bash

```bash
chezmoi update --source="$HOME/.dotfiles" -R
```

#### PowerShell Core

```pwsh
chezmoi update --source="$env:USERPROFILE\.dotfiles" -R
```

---

## Credits

- [Felipe Santos](https://github.com/felipecrs) - take a look at his [dotfiles](https://github.com/felipecrs/dotfiles)
  - parts of his README are used
  - the install scripts for Ubuntu are used
