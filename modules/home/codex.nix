# ╭──────────────────────────────────────────────────────────╮
# │ Codex                                                    │
# ╰──────────────────────────────────────────────────────────╯
{ flake, ... }:
let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.codex-desktop-linux.homeManagerModules.default
  ];

  programs.codexDesktopLinux.enable = true;
}
