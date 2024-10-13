# ╭──────────────────────────────────────────────────────────╮
# │ CUSTOM PACKAGES                                          │
# ╰──────────────────────────────────────────────────────────╯
pkgs: {
  hyprshade = pkgs.callPackage ./hyprshade { };
  tokyo-night-tmux = pkgs.callPackage ./tokyo-night-tmux { };
}
