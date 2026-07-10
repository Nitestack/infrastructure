# ╭──────────────────────────────────────────────────────────╮
# │ AI                                                       │
# ╰──────────────────────────────────────────────────────────╯
{ flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    inputs.agent-skills.homeManagerModules.default

    self.homeModules.pi-coding-agent
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
      targets.agents.enable = true;
    };
    claude-code = {
      enable = true;
      settings = {
        includeCoAuthoredBy = false;
        permissions = {
          defaultMode = "bypassPermissions";
          skipDangerousModePermissionPrompt = true;
        };
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
        inputs.superpowers
      ];
    };
    # codex = {
    #   enable = true;
    #   settings = {
    #     commit_attribution = "";
    #     approval_policy = "never";
    #     sandbox_mode = "workspace-write";
    #     personality = "pragmatic";
    #   };
    # };
  };
}
