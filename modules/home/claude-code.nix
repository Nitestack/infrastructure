# ╭──────────────────────────────────────────────────────────╮
# │ Claude Code                                              │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
{
  programs.claude-code = {
    enable = true;
    settings = {
      includeCoAuthoredBy = false;
      permissions.defaultMode = "acceptEdits";
      env = {
        CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS = "1";
      };
    };
    plugins = [
      (pkgs.fetchFromGitHub {
        owner = "JuliusBrussee";
        repo = "caveman";
        rev = "655b7d9c5431f822264b7732e9901c5578ac84cf";
        sha256 = "1chxccncngr0syc39ykjlmzxgj669vnzkfa3xvijsspgvw9529q7";
      })
    ];
  };
}
