# ╭──────────────────────────────────────────────────────────╮
# │ ZSH                                                      │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, config, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
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
          rev = "cf57116eb2410139b8bd78fcb793dd84db79e28f";
          sha256 = "082x8al08ywkv7p4gf46161md1i8lj3iy4rm266d744amfhwj3i0";
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
    initExtra = ''
      bindkey "^p" history-substring-search-up
      bindkey "^n" history-substring-search-down
      bindkey "^[w" kill-region

      if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
        eval "$(oh-my-posh init zsh --config "''${XDG_CONFIG_HOME:-''${HOME}/.config}/oh-my-posh/config.yml")"
      fi

      # fastfetch
      if [[ $(tty) == *"pts"* ]]; then
        fastfetch
      fi
    '';
  };
  home = {
    sessionVariables = {
      PNPM_HOME = "$HOME/.local/share/pnpm";
      VOLTA_HOME = "$HOME/.volta";
    };
    sessionPath = [
      "$HOME/.cargo/bin"
      "$HOME/.local/bin"
      config.home.sessionVariables.PNPM_HOME
      "${config.home.sessionVariables.VOLTA_HOME}/bin"
    ];
    shellAliases = {
      v = "nvim";
      lg = "lazygit";
      lzd = "lazydocker";
    };
  };
}
