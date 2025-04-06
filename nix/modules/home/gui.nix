# ╭──────────────────────────────────────────────────────────╮
# │ GUI Configuration                                        │
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
    self.homeModules.wezterm
    self.homeModules.zen-browser
  ];

  # Configuration
  shells.zsh.enable = true;

  # ── Programs ──────────────────────────────────────────────────────────
  home.packages =
    # Fonts
    [
      font.sans.package
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
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
