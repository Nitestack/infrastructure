# ╭──────────────────────────────────────────────────────────╮
# │ WSL HOME MANAGER CONFIGURATION                           │
# ╰──────────────────────────────────────────────────────────╯
{
  # ── Imports ───────────────────────────────────────────────────────────
  imports = [
    ./_base.nix

    # Modules
    ./modules/zsh.nix
  ];

  shells.zsh = {
    enable = true;
    enablePerformanceMode = true;
  };
}
