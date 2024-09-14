# ╭──────────────────────────────────────────────────────────╮
# │ eza                                                      │
# ╰──────────────────────────────────────────────────────────╯
{
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    extraOptions = [
      "--group-directories-first"
      "--octal-permissions"
    ];
    git = true;
    icons = true;
  };
}
