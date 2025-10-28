# ╭──────────────────────────────────────────────────────────╮
# │ Dank Material Shell                                      │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  config,
  ...
}:
let
  inherit (flake) inputs;
  inherit (config) meta;
in
{
  imports = [
    inputs.dankMaterialShell.nixosModules.greeter
  ];

  programs.dankMaterialShell.greeter = {
    enable = true;
    compositor.name = "hyprland";
    configHome = config.users.users.${meta.username}.home;
  };
}
