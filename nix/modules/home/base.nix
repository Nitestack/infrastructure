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
    self.homeModules.git
    self.homeModules.neovim
    self.homeModules.nh
    self.homeModules.nushell
    self.homeModules.oh-my-posh
    self.homeModules.tmux

    self.homeModules.languages
  ];

  # ── Configuration ─────────────────────────────────────────────────────
  home = {
    inherit (meta) username;
    homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${meta.username}";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";

    # Shared across all shells
    shellAliases = {
      v = "nvim";
      proton-mail = "XDG_SESSION_TYPE=x11 proton-mail";
      cp = "cp -iv";
      mv = "mv -iv";
    };
  };

  xdg.enable = true;

  news.display = "show";

  # ── Programs ──────────────────────────────────────────────────────────
  programs = {
    btop.enable = true;
    carapace.enable = true;
    fd.enable = true;
    home-manager.enable = true;
    java.enable = true;
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
