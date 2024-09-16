# ╭──────────────────────────────────────────────────────────╮
# │ CUSTOM PACKAGES                                          │
# ╰──────────────────────────────────────────────────────────╯
pkgs: {
  hyprshade = pkgs.callPackage ./hyprshade { };
  sddm-astronaut-theme = pkgs.callPackage ./sddm-astronaut-theme { };
}
