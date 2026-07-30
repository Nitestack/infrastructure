# ╭──────────────────────────────────────────────────────────╮
# │ Herdr                                                    │
# ╰──────────────────────────────────────────────────────────╯
{
  lib,
  pkgs,
  ...
}:
{
  programs.herdr = {
    enable = true;
    settings = {
      onboarding = false;
      terminal.default_shell = lib.getExe pkgs.nushell;
      keys = {
        prefix = "ctrl+a";
        previous_tab = "ctrl+alt+h";
        next_tab = "ctrl+alt+l";
        previous_workspace = "ctrl+alt+k";
        next_workspace = "ctrl+alt+j";
        previous_agent = "ctrl+alt+[";
        next_agent = "ctrl+alt+]";
        copy_mode = "prefix+v";
        split_vertical = "prefix+|";
        split_horizontal = "prefix+minus";
      };
      ui = {
        pane_borders = false;
        agent_panel_sort = "priority";
        hide_tab_bar_when_single_tab = true;
        prompt_new_tab_name = false;
        toast.delivery = "system";
      };
    };
  };
}
