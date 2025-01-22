# ╭──────────────────────────────────────────────────────────╮
# │ NixOS WSL Home Manager Configuration                     │
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
