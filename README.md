# Nitestack/dotfiles

These repo contains my dotfiles. To manage my dotfiles across different devices and operating systems, I use [`chezmoi`](https://chezmoi.io/).

It is currently aimed for Windows, Ubuntu and WSL (Ubuntu), as they are the most common platforms I use.

## Installation

### Requirements

You need to have chezmoi installed. You can visit the [install page](https://chezmoi.io/install) to get started.

### Terminal

```bash
chezmoi init --apply Nitestack
```

## Update

To update my dotfiles, run

```bash
chezmoi update
```
