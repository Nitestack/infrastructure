# ╭──────────────────────────────────────────────────────────╮
# │ WezTerm                                                  │
# ╰──────────────────────────────────────────────────────────╯
{ inputs, pkgs, ... }:
{
  programs.wezterm = {
    enable = true;
    package = inputs.wezterm.packages.${pkgs.system}.default;
    enableZshIntegration = true;
  };
  # handled by chezmoi
  xdg.configFile."wezterm/wezterm.lua".enable = false;
}
