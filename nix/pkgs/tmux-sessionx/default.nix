# ╭──────────────────────────────────────────────────────────╮
# │ Tmux SessionX                                            │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
pkgs.tmuxPlugins.mkTmuxPlugin rec {
  name = "tmux-sessionx";
  pluginName = name;
  rtpFilePath = "sessionx.tmux";
  src = pkgs.fetchFromGitHub {
    owner = "omerxx";
    repo = "tmux-sessionx";
    rev = "264fda3f0b5a1c5a6f51961fc53f1b31e6184360";
    sha256 = "09mb84wfx2adp5i26x0x2wilngdcjs80zpwsccjw5m80djp43vrn";
  };
}
