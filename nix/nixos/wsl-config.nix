# ╭──────────────────────────────────────────────────────────╮
# │ NIXOS WSL CONFIGURATION                                  │
# ╰──────────────────────────────────────────────────────────╯
{ meta, ... }:
{
  wsl = {
    enable = true;
    defaultUser = meta.username;
    docker-desktop.enable = true;
    startMenuLaunchers = true;
  };

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager.users.${meta.username} = import ../home-manager/shared-home.nix;
}
