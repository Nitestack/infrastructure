# ╭──────────────────────────────────────────────────────────╮
# │ Tokyo Night Tmux                                         │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
pkgs.tmuxPlugins.mkTmuxPlugin rec {
  name = "tokyo-night-tmux";
  pluginName = name;
  rtpFilePath = "tokyo-night.tmux";
  src = pkgs.fetchFromGitHub {
    owner = "janoamaral";
    repo = "tokyo-night-tmux";
    rev = "b45b742eb3fdc01983c21b1763594b549124d065";
    sha256 = "0dfn84ywjvvrpf49921r8np0mi8hrq9bgwny9yzvk4vjcxyrp04k";
  };
}
