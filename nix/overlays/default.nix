# ╭──────────────────────────────────────────────────────────╮
# │ Overlays                                                 │
# ╰──────────────────────────────────────────────────────────╯
_: final: prev: {
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
  whitesur-icon-theme = prev.whitesur-icon-theme.overrideAttrs (oldAttrs: {
    version = "2025-07-23";
    src = prev.fetchFromGitHub {
      owner = "vinceliuice";
      repo = "WhiteSur-icon-theme";
      rev = "v${oldAttrs.version}";
      hash = "sha256-spTmS9Cn/HAnbgf6HppwME63cxWEbcKwWYMMj8ajFyY=";
    };
  });
  lib = prev.lib // {
    scss = import ../lib/scss.nix {
      inherit (prev) lib;
      pkgs = final;
    };
  };
}
