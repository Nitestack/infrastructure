# ╭──────────────────────────────────────────────────────────╮
# │ Neovim                                                   │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
  xdg.configFile."nvim/after".source = ./after;
  xdg.configFile."nvim/lua".source = ./lua;
  xdg.configFile."nvim/init.lua".source = ./init.lua;

  home.packages = with pkgs; [
    gcc
    ghostscript
    imagemagick
    nixd
    typst
  ];
}
