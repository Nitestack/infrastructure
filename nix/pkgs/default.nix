# ╭──────────────────────────────────────────────────────────╮
# │ CUSTOM PACKAGES                                          │
# ╰──────────────────────────────────────────────────────────╯
pkgs: {
  hyprshade = pkgs.callPackage ./hyprshade { };
  tmux-sessionx = pkgs.callPackage ./tmux-sessionx { };
  tokyo-night-tmux = pkgs.callPackage ./tokyo-night-tmux { };
}
