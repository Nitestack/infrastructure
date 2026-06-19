# ╭──────────────────────────────────────────────────────────╮
# │ Development Profile                                      │
# ╰──────────────────────────────────────────────────────────╯
{ flake, ... }:
let
  inherit (flake.inputs) self;
in
{
  imports = [
    self.homeModules.languages
  ];
}
