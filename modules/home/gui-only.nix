# ╭──────────────────────────────────────────────────────────╮
# │ GUI Only Configuration                                   │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  pkgs,
  meta,
  ...
}:
let
  inherit (flake.inputs) self;
  inherit (meta) font;
in
{
  # ── Imports ───────────────────────────────────────────────────────────
  imports = [
    self.homeModules.ghostty
    self.homeModules.spicetify
  ];

  # ── Programs ──────────────────────────────────────────────────────────
  home.packages =
    # Fonts
    [
      font.sans.package
      font.serif.package
      font.emoji.package
    ]
    ++ font.nerd.packages
    # Apps
    ++ (with pkgs; [
      bitwarden-desktop
      feishin
      localsend
      musescore
      protonmail-desktop
      signal-desktop
      spek
    ]);

  programs = {
    anki.enable = true;
    cava.enable = true;
    chromium.enable = true;
    obsidian.enable = true;
    vesktop.enable = true;
  };
}
