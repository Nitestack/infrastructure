# ╭──────────────────────────────────────────────────────────╮
# │ WezTerm                                                  │
# ╰──────────────────────────────────────────────────────────╯
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
  };
  # handled by chezmoi
  xdg.configFile."wezterm/wezterm.lua".enable = false;
}
