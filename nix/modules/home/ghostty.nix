# ╭──────────────────────────────────────────────────────────╮
# │ Ghostty                                                  │
# ╰──────────────────────────────────────────────────────────╯
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "catppuccin-mocha";
      font-family = [
        "CommitMono Nerd Font"
        "Symbols Nerd Font"
        "Noto Color Emoji"
      ];
      font-family-italic = "VictorMono NF";
      font-size = 14;
      adjust-cell-height = "50%";
      adjust-cursor-height = "50%";
      window-padding-x = 0;
      window-padding-y = 0;
    };
  };
}
