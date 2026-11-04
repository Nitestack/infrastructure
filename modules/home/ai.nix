# ╭──────────────────────────────────────────────────────────╮
# │ AI                                                       │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;

  explicitSkillsFromCatalog =
    source: catalog: rename:
    builtins.listToAttrs (
      map (
        id:
        let
          name = rename id;
        in
        {
          inherit name;
          value = {
            from = source;
            path = catalog.${id}.relPath;
            rename = name;
          };
        }
      ) (builtins.attrNames catalog)
    );

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

  # Addy's skills refer to shared files in the repository's references/
  # directory. Keep the repository as the source root, then flatten each skill
  # for Claude Code's one-level discovery.
  addyAgentSkillsSource = {
    path = inputs.addy-agent-skills;
    filter.nameRegex = "^skills/.*$";
  };
  addyAgentSkillsCatalog = inputs.agent-skills.lib.agent-skills.discoverCatalog {
    addy-agent-skills = addyAgentSkillsSource;
  };
  addyAgentSkillsExplicit =
    explicitSkillsFromCatalog "addy-agent-skills" addyAgentSkillsCatalog
      baseNameOf;

  # Emil's skills are flat under skills/. Only select prototype specially
  # because its name conflicts with Matt Pocock's flattened prototype skill.
  emilSkillsSource = {
    path = inputs.emil-skills;
    subdir = "skills";
  };
  emilSkillsCatalog = inputs.agent-skills.lib.agent-skills.discoverCatalog {
    emil-skills = emilSkillsSource;
  };
  emilSkillsToEnable = builtins.filter (id: id != "prototype") (builtins.attrNames emilSkillsCatalog);
  emilPrototypeExplicit = {
    emil-prototype = {
      from = "emil-skills";
      path = emilSkillsCatalog.prototype.relPath;
      rename = "emil-prototype";
    };
  };

  tasteSkillSource = {
    path = inputs.taste-skill;
    subdir = "skills";
  };

  t3codePackage = pkgs.t3code.override {
    enableClaude = true;
    enableCodex = true;
    enableOpencode = true;
    enableGit = true;
    enableGitHub = true;
    enableGitLab = true;
    t3code-unwrapped = pkgs.t3code.unwrapped.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        # T3 Connect configuration is compiled into the client and CLI.
        cp .env.example .env
      '';
    });
  };
in
{
  imports = [
    inputs.agent-skills.homeManagerModules.default

    self.homeModules.opencode
  ];
  home.packages = with pkgs; [
    antigravity-acp
    codex
    claude-code
  ];
  programs = {
    agent-skills = {
      enable = true;
      sources = {
        addy-agent-skills = addyAgentSkillsSource;
        emil-skills = emilSkillsSource;
        humanizer.path = inputs.humanizer;
        matt-pocock-skills = mattPocockSource;
        taste-skill = tasteSkillSource;
      };
      skills = {
        enableAll = [
          "humanizer"
          "taste-skill"
        ];
        enable = emilSkillsToEnable;
        explicit = mattPocockExplicitSkills // addyAgentSkillsExplicit // emilPrototypeExplicit;
      };
      targets.agents.enable = true;
      targets.claude.enable = true;
      targets.codex.enable = true;
      targets.opencode.enable = true;
    };
    t3code = {
      enable = true;
      package = t3codePackage;
    };
  };
}
