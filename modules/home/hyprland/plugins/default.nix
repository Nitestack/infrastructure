# ╭──────────────────────────────────────────────────────────╮
# │ Hyprland Plugins                                         │
# ╰──────────────────────────────────────────────────────────╯
{ lib, ... }:
let
  dirEntries = builtins.readDir ./.;
in
{
  imports = builtins.map (name: ./${name}) (
    builtins.filter (
      name: name != "default.nix" && dirEntries.${name} == "regular" && lib.hasSuffix ".nix" name
    ) (builtins.attrNames dirEntries)
  );
}
