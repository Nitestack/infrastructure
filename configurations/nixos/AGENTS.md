# NixOS Hosts

The NixOS targets are:

| Host | Role |
| --- | --- |
| `nixstation` | Bare-metal interactive desktop |
| `homestation` | Bare-metal homelab server |
| `wslstation` | NixOS under WSL with Docker Desktop integration |

Host files are the right place for machine-specific imports, device and
filesystem choices, networking, and service selection. Put behaviour shared by
multiple hosts in `modules/nixos/` or `modules/shared/`, with platform guards
where necessary.

Use [`docs/operations.md`](../../docs/operations.md) for validation, activation,
and rollback. The [WSL guide](wslstation/AGENTS.md) and [homestation guide](homestation/AGENTS.md)
add host-specific checks and service rules.
