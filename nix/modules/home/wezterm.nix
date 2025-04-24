# ╭──────────────────────────────────────────────────────────╮
# │ WezTerm                                                  │
# ╰──────────────────────────────────────────────────────────╯
{
  programs.wezterm.enable = true;
  # handled by chezmoi
  xdg.configFile."wezterm/wezterm.lua".enable = false;
}
