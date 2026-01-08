# ╭──────────────────────────────────────────────────────────╮
# │ Overlays                                                 │
# ╰──────────────────────────────────────────────────────────╯
_: final: prev: {
  lib = prev.lib // {
    scss = import ../lib/scss.nix {
      inherit (prev) lib;
      pkgs = final;
    };
  };
}
