# ╭──────────────────────────────────────────────────────────╮
# │ HOME MANAGER CONFIGURATION                               │
# ╰──────────────────────────────────────────────────────────╯

{ pkgs, meta, ... }:
{
  # ── Imports ───────────────────────────────────────────────────────────
  imports = [
    ./browser.nix
    ./git.nix
    ./hyprland.nix
    ./rofi.nix
    ./theme.nix
    ./wezterm.nix
  ];

  # ── Configuration ─────────────────────────────────────────────────────
  home = {
    username = meta.username;
    homeDirectory = "/home/${meta.username}";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";
  };

  xdg = {
    enable = true;
    desktopEntries = {
      snapdrop = {
        name = "Snapdrop";
        comment = "The easiest way to transfer files across devices";
        categories = [
          "Network"
          "FileTransfer"
        ];
        exec = "google-chrome-stable --app=https://snapdrop.net --name=Snapdrop";
        icon = "${pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/snapdrop/snapdrop/master/client/images/logo_transparent_512x512.png";
          sha256 = "sha256-QMgXdeaNxg+e71dKAojR1h1zcpwBCNX10JQfD0fqhes=";
        }}";
      };
    };
    userDirs = {
      enable = true;
      createDirectories = true;
    };
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
