# ╭──────────────────────────────────────────────────────────╮
# │ macOS Configuration                                      │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  config,
  ...
}:
let
  inherit (flake.inputs) self;
  inherit (config) meta;
in
{
  imports = [ ];

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager.users.${meta.username} = {
    imports = [ (self + /configurations/home/mac.nix) ];
  };
}
