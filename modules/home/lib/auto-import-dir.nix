# ╭──────────────────────────────────────────────────────────╮
# │ Auto-import every *.nix file in a directory (non-recursive) │
# ╰──────────────────────────────────────────────────────────╯
{ lib, dir }:
let
  dirEntries = builtins.readDir dir;
in
builtins.map (name: dir + "/${name}") (
  builtins.filter (
    name: name != "default.nix" && dirEntries.${name} == "regular" && lib.hasSuffix ".nix" name
  ) (builtins.attrNames dirEntries)
)
