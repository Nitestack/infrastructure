# ╭──────────────────────────────────────────────────────────╮
# │ ZSH                                                      │
# ╰──────────────────────────────────────────────────────────╯
{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.shells.zsh;
in
{
  options.shells.zsh = {
    enable = mkEnableOption "ZSH Config";
    enablePerformanceMode = mkEnableOption "performance mode";
  };
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = mkIf cfg.enablePerformanceMode false;
      defaultKeymap = "viins";
      history = {
        append = true;
        expireDuplicatesFirst = true;
        ignoreAllDups = true;
        save = 5000;
        size = 5000;
      };
      oh-my-zsh = {
        enable = true;
        plugins = [
          "aliases"
          "command-not-found"
          "eza"
          "git"
          "tmux"
          "vi-mode"
        ];
        extraConfig = ''
          zstyle ":completion:*" matcher-list 'm:{a-z}={A-Za-z}'
          zstyle ":completion:*" list-colors "$\{(s.:.)LS_COLORS}"
          zstyle ":completion:*" menu no
          zstyle ":fzf-tab:complete:cd:*" fzf-preview 'ls --color $realpath'
          zstyle ":fzf-tab:complete:__zoxide_z:*" fzf-preview 'ls --color $realpath'
        '';
      };
      plugins = [
        {
          name = "fzf-tab";
          file = "fzf-tab.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "Aloxaf";
            repo = "fzf-tab";
            rev = "6aced3f35def61c5edf9d790e945e8bb4fe7b305";
            sha256 = "1brljd9744wg8p9v3q39kdys33jb03d27pd0apbg1cz0a2r1wqqi";
          };
        }
        {
          name = "zsh-history-substring-search";
          file = "zsh-history-substring-search.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-history-substring-search";
            rev = "87ce96b1862928d84b1afe7c173316614b30e301";
            sha256 = "0qk4hxc5l4qgjwk58mijw8bag1wn6w4mg3cq5d2fvdj9wl0k9v6p";
          };
        }
      ];
      initExtra =
        let
          fastfetch = "${pkgs.fastfetch}/bin/fastfetch";
          oh-my-posh = "${pkgs.oh-my-posh}/bin/oh-my-posh";
        in
        ''
          bindkey "^p" history-substring-search-up
          bindkey "^n" history-substring-search-down
          bindkey "^[w" kill-region

          if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
            eval "$(${oh-my-posh} init zsh --config "${config.xdg.configHome}/oh-my-posh/config.yml")"
          fi

          # fastfetch
          if [[ $(tty) == *"pts"* ]]; then
            ${fastfetch}
          fi
        '';
    };
    home = {
      sessionPath = [
        "${config.home.homeDirectory}/.local/bin"
      ];
      shellAliases = {
        v = "nvim";
        lg = "lazygit";
        lzd = "lazydocker";
        proton-mail = "XDG_SESSION_TYPE=x11 proton-mail";
      };
      packages = with pkgs; [
        oh-my-posh
      ];
    };
  };
}
