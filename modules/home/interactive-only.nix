# ╭──────────────────────────────────────────────────────────╮
# │ Interactive Only Home Manager Configuration              │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  ...
}:
let
  inherit (flake.inputs) self;
in
{
  imports = [
    self.homeModules.ai
    self.homeModules.languages
  ];

  programs = {
    java.enable = true;
    zathura.enable = true;
  };
}
