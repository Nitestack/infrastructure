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
  gns3-gui = prev.gns3-gui.overrideAttrs (oldAttrs: rec {
    version = "2.2.54";
    src = prev.fetchFromGitHub {
      owner = "GNS3";
      repo = "gns3-gui";
      rev = "refs/tags/v${version}";
      hash = "sha256-rR7hrNX7BE86x51yaqvTKGfcc8ESnniFNOZ8Bu1Yzuc=";
    };
  });
}
