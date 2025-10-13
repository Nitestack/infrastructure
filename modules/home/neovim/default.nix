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
  xdg.configFile = {
    "nvim/after".source = ./after;
    "nvim/lua".source = ./lua;
    "nvim/init.lua".source = ./init.lua;
  };

  home.packages = with pkgs; [
    # NOTE: LSP's (# pnpm add -g @ansible/ansible-language-server cssmodules-language-server markdown-toc)
    angular-language-server
    bash-language-server
    copilot-language-server
    dockerfile-language-server
    docker-compose-language-service
    emmet-language-server
    gopls
    lua-language-server
    marksman
    nixd
    nushell
    prisma-language-server
    pyright
    rust-analyzer
    tailwindcss-language-server
    taplo
    tinymist
    vscode-langservers-extracted
    vtsls
    yaml-language-server

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
    statix

    # Formatters
    bibtex-tidy
    black
    gofumpt
    gotools
    prettierd
    nixfmt
    nufmt
    shfmt
    stylua

    gcc
    gemini-cli-bin
    ghostscript
    github-copilot-cli
    imagemagick
    tree-sitter
    typst
  ];
}
