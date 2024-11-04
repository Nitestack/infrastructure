# ╭──────────────────────────────────────────────────────────╮
# │ AGS                                                      │
# ╰──────────────────────────────────────────────────────────╯
{ inputs, ... }:
{
  # add the home manager module
  imports = [ inputs.ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;
    configDir = ../ags;
    systemd.enable = true;
  };
}
