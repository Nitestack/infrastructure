# ╭──────────────────────────────────────────────────────────╮
# │ HOME MANAGER CONFIGURATION                               │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  meta,
  config,
  ...
}:
{
  # ── Imports ───────────────────────────────────────────────────────────
  imports = [
    ./bat.nix
    ./browser.nix
    ./dunst.nix
    ./eza.nix
    ./fzf.nix
    ./git.nix
    ./hyprland
    ./kitty.nix
    ./rofi.nix
    ./theme.nix
    # ./wezterm.nix

    ./scripts
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
    desktopEntries =
      let
        googleChrome = "${pkgs.google-chrome}/bin/google-chrome-stable";
      in
      {
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
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
      };
    };
  };

  news.display = "show";

  # ── Programs ──────────────────────────────────────────────────────────
  programs = {
    btop.enable = true;
    fastfetch.enable = true;
    fd.enable = true;
    home-manager.enable = true;
    jq.enable = true;
    less.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
    };
    ripgrep.enable = true;
    vscode.enable = true;
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  # ── Services ──────────────────────────────────────────────────────────
  services = {
    cliphist.enable = true;
    easyeffects.enable = true;
  };
}
