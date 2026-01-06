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
    inputs.dms.nixosModules.greeter
  ];

  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "hyprland";
    configHome = config.users.users.${meta.username}.home;
  };
}
