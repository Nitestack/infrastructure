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
    ./rofi.nix
    ./theme.nix
    ./wezterm.nix
    ./zsh.nix

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
        whatsapp = {
          name = "WhatsApp";
          comment = "Quickly send and receive WhatsApp messages right from your computer.";
          categories = [
            "Network"
          ];
          exec = "${googleChrome} --app=https://web.whatsapp.com --name=WhatsApp";
          icon = "${pkgs.fetchurl {
            url = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/WhatsApp.svg/240px-WhatsApp.svg.png";
            sha256 = "15spvy9w3aj3nx161z60wkhqswrp13j5kp4v2sijbmd36myg38xj";
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
    # Module is not supporting custom path, so using it manually
    # oh-my-posh = {
    #   enable = true;
    #   enableZshIntegration = true;
    # };
    ripgrep.enable = true;
    vscode.enable = true;
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd"
        "cd"
      ];
    };
  };

  # ── Services ──────────────────────────────────────────────────────────
  services = {
    cliphist.enable = true;
    easyeffects.enable = true;
  };
}
