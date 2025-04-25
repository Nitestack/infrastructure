# ╭──────────────────────────────────────────────────────────╮
# │ eza                                                      │
# ╰──────────────────────────────────────────────────────────╯
{
  programs.eza = {
    enable = true;
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
