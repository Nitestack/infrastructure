# ╭──────────────────────────────────────────────────────────╮
# │ Nix Home Manager Configuration                           │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  pkgs,
  meta,
  ...
}:
let
  inherit (flake.inputs) self;
in
{
  # ── Imports ───────────────────────────────────────────────────────────
  imports = [
    self.homeModules.bat
    self.homeModules.direnv
    self.homeModules.eza
    self.homeModules.fzf
    self.homeModules.git
    self.homeModules.tmux
    self.homeModules.zsh

    self.homeModules.languages
  ];

  # ── Configuration ─────────────────────────────────────────────────────
  home = {
    username = meta.username;
    homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${meta.username}";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";
  };

  xdg.enable = true;

  news.display = "show";

  # ── Programs ──────────────────────────────────────────────────────────
  programs = {
    btop.enable = true;
    fastfetch.enable = true;
    fd.enable = true;
    home-manager.enable = true;
    jq.enable = true;
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
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd"
        "cd"
      ];
    };
  };
}
