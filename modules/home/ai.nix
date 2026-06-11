# ╭──────────────────────────────────────────────────────────╮
# │ AI                                                       │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, flake, ... }:
let
  inherit (flake) inputs;

  superpowers-plugin = pkgs.fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "6fd4507659784c351abbd2bc264c7162cfd386dc";
    sha256 = "0fjbbnzsf3vk3wc64rpsqjry6sxzfvq07dy7phry8fyhfkq47w9z";
  };
in
{
  imports = [
    inputs.agent-skills.homeManagerModules.default
  ];
  programs = {
    agent-skills = {
      enable = true;
      sources.caveman = {
        path = inputs.caveman;
        subdir = "skills";
      };
      skills.enableAll = true;
      targets.claude.enable = true;
      targets.codex.enable = true;
    };
    claude-code = {
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
          command = "bash \"${inputs.caveman}/src/hooks/caveman-statusline.sh\"";
        };
      };
      plugins = [
        superpowers-plugin
      ];
    };
    codex = {
      enable = true;
      settings = {
        commit_attribution = "";
        approval_policy = "never";
        sandbox_mode = "workspace-write";
        personality = "pragmatic";
      };
    };
  };
}
