# ╭──────────────────────────────────────────────────────────╮
# │ Nix Home Manager Configuration                           │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  pkgs,
  meta,
  config,
  ...
}:
let
  inherit (flake.inputs) self;
in
{
  imports = [
    self.homeModules.ai
    self.homeModules.bat
    self.homeModules.direnv
    self.homeModules.eza
    self.homeModules.git
    self.homeModules.lazygit
    self.homeModules.neovim
    self.homeModules.nh
    self.homeModules.nushell
    self.homeModules.oh-my-posh
    self.homeModules.tmux
  ];

  home = {
    inherit (meta) username;
    homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${meta.username}";
    stateVersion = "26.05";

    shellAliases = {
      v = "nvim";
      cp = "cp -iv";
      mv = "mv -iv";
    };
    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
    ];
  };

  xdg.enable = true;

  news.display = "show";

  programs = {
    btop.enable = true;
    carapace.enable = true;
    fd.enable = true;
    home-manager.enable = true;
    nix-your-shell.enable = true;
    ripgrep.enable = true;
    zoxide = {
      enable = true;
      options = [
        "--cmd"
        "cd"
      ];
    };
    zsh.enable = true;
  };
}
