# ╭──────────────────────────────────────────────────────────╮
# │ eza                                                      │
# ╰──────────────────────────────────────────────────────────╯
{
  programs.eza = {
    enable = true;
    enableZshIntegration = false; # just adds various shell aliases, already handled by Oh My Zsh
    extraOptions = [
      "--group-directories-first"
      "--octal-permissions"
    ];
    git = true;
    icons = "always";
  };
}
