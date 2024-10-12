# ╭──────────────────────────────────────────────────────────╮
# │ eza                                                      │
# ╰──────────────────────────────────────────────────────────╯
{
  programs.eza = {
    enable = true;
    enableZshIntegration = false;
    extraOptions = [
      "--group-directories-first"
      "--octal-permissions"
    ];
    git = true;
    icons = true;
  };
}
