# ╭──────────────────────────────────────────────────────────╮
# │ HOME MANAGER CONFIGURATION                               │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  meta,
  ...
}:
let
  googleChrome = "${pkgs.google-chrome}/bin/google-chrome-stable";
in
{
  # ── Imports ───────────────────────────────────────────────────────────
  imports = [
    ./bat.nix
    ./browser.nix
    ./easyeffects.nix
    ./git.nix
    ./hyprland
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
        exec = "${googleChrome} --app=https://snapdrop.net --name=Snapdrop";
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

  news.display = "show";

  # ── Programs ──────────────────────────────────────────────────────────
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
    home-manager.enable = true;
  };
}
