# ╭──────────────────────────────────────────────────────────╮
# │ NIXOS FULL HOME MANAGER CONFIGURATION                    │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  config,
  ...
}:
{
  # ── Imports ───────────────────────────────────────────────────────────
  imports = [
    ./shared-home.nix

    ./browser.nix
    ./hyprland
    ./rofi.nix
    ./swaync.nix
    ./theme.nix
    ./waybar.nix
    ./wezterm.nix
  ];

  xdg.desktopEntries =
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

  # Nautilus
  gtk.gtk3.bookmarks =
    let
      home = config.home.homeDirectory;
    in
    [
      "file://${home}/Programming"
      "file://${home}/Studium"
    ];

  # ── Programs ──────────────────────────────────────────────────────────
  programs = {
    cava.enable = true;
    vscode.enable = true;
  };

  # ── Services ──────────────────────────────────────────────────────────
  services = {
    cliphist.enable = true;
    easyeffects.enable = true;
  };
}
