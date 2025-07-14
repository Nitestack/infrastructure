# ╭──────────────────────────────────────────────────────────╮
# │ Overlays                                                 │
# ╰──────────────────────────────────────────────────────────╯
{ ... }:
final: prev: {
  tmuxPlugins = prev.tmuxPlugins // {
    tokyo-night-tmux = prev.tmuxPlugins.tokyo-night-tmux.overrideAttrs (oldAttrs: {
      version = "1.6.5";
      src = prev.fetchFromGitHub {
        owner = "janoamaral";
        repo = "tokyo-night-tmux";
        rev = "caf6cbb4c3a32d716dfedc02bc63ec8cf238f632";
        hash = "sha256-TOS9+eOEMInAgosB3D9KhahudW2i1ZEH+IXEc0RCpU0=";
      };
    });
  };
  lib = prev.lib // {
    scss = import ../lib/scss.nix {
      pkgs = final;
      lib = prev.lib;
    };
  };
}
