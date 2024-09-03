# ╭──────────────────────────────────────────────────────────╮
# │ HOME MANAGER CONFIGURATION                               │
# ╰──────────────────────────────────────────────────────────╯

{
  # ── Imports ───────────────────────────────────────────────────────────
  imports = [
    ./ags.nix
    ./browser.nix
    ./git.nix
    ./hyprland.nix
    ./theme.nix
  ];

  # ── Configuration ─────────────────────────────────────────────────────
  home = {
    username = "nhan";
    homeDirectory = "/home/nhan";

    packages = [ ];

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";
  };

  # ── Programs ──────────────────────────────────────────────────────────
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    home-manager.enable = true;
  };
}
