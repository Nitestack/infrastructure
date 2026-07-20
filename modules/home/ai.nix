# ╭──────────────────────────────────────────────────────────╮
# │ AI                                                       │
# ╰──────────────────────────────────────────────────────────╯
{ flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;

  # Matt Pocock's skills are organized into category folders (e.g.
  # `engineering/implement`), so agent-skills discovers them with nested
  # ids. Codex walks the skills tree recursively and finds them fine, but
  # Claude Code only looks for `SKILL.md` one level deep (`skills/<name>/`),
  # so nested skills silently don't show up for it. Flatten them via
  # `rename` so every agent sees them at the top level.
  mattPocockSource = {
    path = inputs.matt-pocock-skills;
    subdir = "skills";
  };
  mattPocockCatalog = inputs.agent-skills.lib.agent-skills.discoverCatalog {
    matt-pocock-skills = mattPocockSource;
  };
  mattPocockExplicitSkills = builtins.listToAttrs (
    map (id: {
      name = baseNameOf id;
      value = {
        from = "matt-pocock-skills";
        path = mattPocockCatalog.${id}.relPath;
        rename = baseNameOf id;
      };
    }) (builtins.attrNames mattPocockCatalog)
  );
in
{
  imports = [
    inputs.agent-skills.homeManagerModules.default

    self.homeModules.oh-my-pi
  ];
  programs = {
    agent-skills = {
      enable = true;
      sources = {
        caveman = {
          path = inputs.caveman;
          subdir = "skills";
        };
        humanizer.path = inputs.humanizer;
        matt-pocock-skills = mattPocockSource;
      };
      skills = {
        enableAll = [
          "caveman"
          "humanizer"
        ];
        explicit = mattPocockExplicitSkills;
      };
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
      };
    };
  };
}
