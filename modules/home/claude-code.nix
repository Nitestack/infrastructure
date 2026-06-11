# ╭──────────────────────────────────────────────────────────╮
# │ Claude Code                                              │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
let
  caveman-plugin = pkgs.fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    rev = "655b7d9c5431f822264b7732e9901c5578ac84cf";
    sha256 = "1chxccncngr0syc39ykjlmzxgj669vnzkfa3xvijsspgvw9529q7";
  };
  superpowers-plugin = pkgs.fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "6fd4507659784c351abbd2bc264c7162cfd386dc";
    sha256 = "0fjbbnzsf3vk3wc64rpsqjry6sxzfvq07dy7phry8fyhfkq47w9z";
  };
in
{
  programs.claude-code = {
    enable = true;
    settings = {
      includeCoAuthoredBy = false;
      permissions.defaultMode = "acceptEdits";
      env = {
        CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS = "1";
      };
      model = "sonnet[1m]";
      statusLine = {
        type = "command";
        command = "bash \"${caveman-plugin}/src/hooks/caveman-statusline.sh\"";
      };
    };
    plugins = [
      caveman-plugin
      superpowers-plugin
    ];
  };
}
