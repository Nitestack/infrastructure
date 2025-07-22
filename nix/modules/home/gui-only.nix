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
      pairdrop
    ]);

  programs = {
    cava.enable = true;
    vscode.enable = true;
  };
}
