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

  t3codePackage = inputs.t3code.packages.${pkgs.stdenv.hostPlatform.system}.t3code-full.override {
    enableClaude = true;
    enableCodex = true;
    enableOpencode = true;
    enableGit = true;
    enableGitHub = true;
    enableGitLab = true;
    extraRuntimePackages = [ pkgs.antigravity-acp ];
  };
in
{
  imports = [
    inputs.agent-skills.homeManagerModules.default

    self.homeModules.opencode
  ];
  # The CLI is installed from the Nix store, so its self-updater cannot
  # replace it. Turn it off here, matching Claude Code's DISABLE_AUTOUPDATER.
  home.sessionVariables.AGY_CLI_DISABLE_AUTO_UPDATE = "1";
  programs = {
    claude-code = {
      enable = true;
      mutableSettings = true;
      settings = {
        attribution = {
          commit = "";
          pr = "";
        };
        autoMemoryEnabled = false;
        syncClaudeAiPlugins = false;
        env = {
          DISABLE_AUTOUPDATER = "1";
          CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
          DISABLE_FEEDBACK_COMMAND = "1";
          CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "1";
          ENABLE_PROMPT_CACHING_1H = "1";
        };
      };
    };
    codex = {
      enable = true;
      mutableSettings = true;
      settings = {
        check_for_update_on_startup = false;
        web_search = "live";
        personality = "none";
        analytics.enabled = false;
        feedback.enabled = false;
        otel = {
          exporter = "none";
          trace_exporter = "none";
          metrics_exporter = "none";
        };
        features = {
          memories = false;
          remote_plugin = false;
          skill_mcp_dependency_install = false;
        };
        memories = {
          generate_memories = false;
          use_memories = false;
        };
      };
    };
    antigravity-cli = {
      enable = true;
      mutableSettings = true;
      settings = {
        showFeedbackSurvey = false;
      };
    };
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
