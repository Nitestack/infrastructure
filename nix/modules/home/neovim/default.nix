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
    # LSP's
    angular-language-server
    ansible-language-server
    bash-language-server
    dockerfile-language-server-nodejs
    docker-compose-language-service
    emmet-language-server
    lua-language-server
    marksman
    nixd
    nushell
    pyright
    rust-analyzer
    tailwindcss-language-server
    taplo
    tinymist
    vscode-langservers-extracted
    vtsls
    yaml-language-server
    # cssmodules-language-server
    # markdown-toc
    # prisma-language-server

    # Debuggers
    python312Packages.debugpy
    vscode-js-debug

    # Linters
    ansible-lint
    eslint_d
    hadolint
    markdownlint-cli2
    ruff
    selene
    shellcheck

    # Formatters
    black
    prettierd
    nixfmt-rfc-style
    nufmt
    shfmt
    stylua

    gcc
    ghostscript
    imagemagick
    tree-sitter
    typst
  ];
}
