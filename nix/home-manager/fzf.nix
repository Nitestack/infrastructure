# ╭──────────────────────────────────────────────────────────╮
# │ fzf                                                      │
# ╰──────────────────────────────────────────────────────────╯
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    changeDirWidgetCommand = "fd --type d";
    defaultCommand = "fd --type f";
    fileWidgetCommand = "fd --type f";
    tmux.enableShellIntegration = true;
  };
}
