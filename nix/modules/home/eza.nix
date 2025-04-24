# ╭──────────────────────────────────────────────────────────╮
# │ eza                                                      │
# ╰──────────────────────────────────────────────────────────╯
{
  programs.eza = {
    enable = true;
    enableZshIntegration = false;
    enableNushellIntegration = false;
    extraOptions = [
      "--group-directories-first"
      "--octal-permissions"
    ];
    git = true;
    icons = "always";
  };
  home.shellAliases = {
    ls = "eza";
    l = "eza -gla";
    ll = "eza -gl";
    lt = "eza -T";
  };
}
