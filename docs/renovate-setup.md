# Renovate Setup

Dependency updates (Nix flake inputs and digest-pinned container images) are
handled by [Renovate](https://docs.renovatebot.com). The update policy itself
lives in [`renovate.json`](../renovate.json); this doc only covers the
one-time GitHub App setup.

## Install the app

Install the [Renovate GitHub App](https://github.com/apps/renovate) on this
repository (or your fork).

## Repository settings

Under the repo's **Settings > Dependencies** tab:

- **Silent Mode** — Disable, so Renovate opens PRs instead of just logging.
- **Renovate > Automated PRs** — Enable.
- **Renovate > Require config file** — Enable, so Renovate only runs because
  `renovate.json` is present, not on its own defaults.
