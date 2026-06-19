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
      anki
      bitwarden-desktop
      feishin
      localsend
      musescore
      obsidian
      protonmail-desktop
      signal-desktop
      spek
      vesktop
    ]);

  programs = {
    cava.enable = true;
    chromium.enable = !pkgs.stdenv.isDarwin;
    vscode.enable = true;
  };
}
