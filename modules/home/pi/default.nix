# ╭──────────────────────────────────────────────────────────╮
# │ Pi                                                        │
# ╰──────────────────────────────────────────────────────────╯
#
# Personal pi distribution replacing oh-my-pi. See NOTES.md for the
# decision record and corrections made against the originating issue.
{
  pkgs,
  flake,
  config,
  osConfig,
  lib,
  ...
}:
let
  inherit (flake) inputs;

  piLib = import ./lib.nix { inherit lib; };
  extensions = import ./extensions.nix;
  privateRoles = import ./roles/private.nix;
  workRoles = import ./roles/work.nix;

  piPackage = inputs.llm-agents-nix.packages.${pkgs.stdenv.hostPlatform.system}.pi;
  theme = "catppuccin-tui-mocha";

  # Only wslstation has the sops secret wired up so far (see NOTES.md); on
  # hosts without it, NIM-routed roles just have no key until it's added.
  hasNimKey = (osConfig.sops.secrets or { }) ? "nim/api-key";

  # Only hosts wiring the pi-work-* sops templates get the work profile;
  # private-only hosts skip it entirely (same guard the old omp module used).
  hasWorkProfile =
    (osConfig.sops.templates or { }) ? "pi-work-models-json"
    && (osConfig.sops.templates or { }) ? "pi-work-litellm-base-url";
  workModelsPath = osConfig.sops.templates."pi-work-models-json".path;
  workLitellmBaseUrlPath = osConfig.sops.templates."pi-work-litellm-base-url".path;

  workConfigDir = "${config.home.homeDirectory}/.pi/agent-work";

  # Non-role-varying files shared by both profiles.
  statuslineConfig = {
    palette = "tokyo-night"; # no Catppuccin option upstream; see NOTES.md
    density = "compact";
    separator = "powerline";
    segments = [
      "brand"
      "provider"
      "model"
      "thinking"
      "cwd"
      "branch"
      "tools"
      "context"
      "tokens"
      "cost"
      "time"
    ];
  };

  slashCommands = roles: {
    "commit.md" = piLib.mkPromptTemplate {
      description = "Draft a Conventional Commit message for the currently staged changes.";
      role = roles.commit;
      body = ''
        Draft a Conventional Commit message for the currently staged changes.
        Follow this repository's commit conventions if AGENTS.md or
        CONTRIBUTING documents them. $@
      '';
    };
    # Named /think, not /plan: pi-plan-mode already owns /plan as its
    # read-only exploration toggle (see NOTES.md).
    "think.md" = piLib.mkPromptTemplate {
      description = "Switch to the strongest model at high thinking for planning or deep reasoning.";
      role = roles.plan;
      body = ''
        Think deeply and produce a plan before making any edits. Do not
        write code yet unless explicitly told to. $@
      '';
    };
    "review.md" = piLib.mkPromptTemplate {
      description = "Review a diff for correctness, spec alignment, and regressions at the strongest model.";
      role = roles.reviewer;
      body = ''
        Review the diff since $@ (default: the last commit) for
        correctness, spec alignment with any linked issue, and
        regressions. Report findings ranked by severity.
      '';
    };
  };

  subagents = roles: {
    "reviewer.md" = piLib.mkSubagent {
      name = "reviewer";
      description = "Reviews diffs and PRs for correctness, spec alignment, and regressions before you approve them.";
      role = roles.reviewer;
    };
    "oracle.md" = piLib.mkSubagent {
      name = "oracle";
      description = "Answers architecture and design judgment questions; same tier as reviewer.";
      role = roles.reviewer;
    };
    "scout.md" = piLib.mkSubagent {
      name = "scout";
      description = "Explores the codebase read-mostly to answer where-is-X / how-does-Y-work questions before implementation.";
      role = roles.scout;
    };
    "smol.md" = piLib.mkSubagent {
      name = "smol";
      description = "Cheap, fast read-mostly exploration; alias of scout for volume work.";
      role = roles.scout;
    };
    "worker.md" = piLib.mkSubagent {
      name = "worker";
      description = "Implements code changes for a well-scoped task handed to it.";
      role = roles.worker;
    };
    "vision.md" = piLib.mkSubagent {
      name = "vision";
      description = "Understands screenshots and images: UI review, error screenshots, diagrams.";
      role = roles.vision;
    };
  };

  mkProfileFiles =
    {
      configDir,
      roles,
    }:
    (lib.mapAttrs' (name: value: lib.nameValuePair "${configDir}/prompts/${name}" { text = value; }) (
      slashCommands roles
    ))
    // (lib.mapAttrs' (name: value: lib.nameValuePair "${configDir}/agents/${name}" { text = value; }) (
      subagents roles
    ))
    // {
      "${configDir}/extensions/provider-fallback.json".text = builtins.toJSON (
        piLib.mkProviderFallback { roleMap = roles; }
      );
      "${configDir}/pi-statusline.json".text = builtins.toJSON statuslineConfig;
    };
in
{
  programs.pi-coding-agent = {
    enable = true;
    package = piPackage;
    extraPackages = with pkgs; [
      nodejs
      bun
    ];
    context = ./context.md;
    settings = piLib.mkSettings {
      roleMap = privateRoles;
      inherit extensions theme;
    };
    models = piLib.mkModels {
      providers.nim = {
        baseUrl = "https://integrate.api.nvidia.com/v1";
        api = "openai-completions";
        apiKey = "\${NVIDIA_API_KEY}";
        models = map (m: { id = m; }) (
          lib.unique (
            map (r: lib.removePrefix "nim/" r) (
              lib.filter (r: lib.hasPrefix "nim/" r) (piLib.allModelRefs privateRoles)
            )
          )
        );
      };
    };
  };

  home.sessionVariables = lib.mkIf hasNimKey {
    NVIDIA_API_KEY = "$(cat ${osConfig.sops.secrets."nim/api-key".path})";
  };

  home.file =
    (mkProfileFiles {
      configDir = "${config.home.homeDirectory}/.pi/agent";
      roles = privateRoles;
    })
    // lib.optionalAttrs hasWorkProfile (
      {
        "${workConfigDir}/AGENTS.md".source = ./context.md;
        "${workConfigDir}/settings.json".text = builtins.toJSON (
          piLib.mkSettings {
            roleMap = workRoles;
            inherit extensions theme;
          }
        );
        "${workConfigDir}/models.json".source = config.lib.file.mkOutOfStoreSymlink workModelsPath;
      }
      // mkProfileFiles {
        configDir = workConfigDir;
        roles = workRoles;
      }
    );

  home.packages = lib.optionals hasWorkProfile [
    (pkgs.writeShellApplication {
      name = "pi-work";
      text = ''
        if [ -z "''${LITELLM_API_KEY:-}" ]; then
          echo "LITELLM_API_KEY is required for pi-work" >&2
          exit 1
        fi
        export PI_CODING_AGENT_DIR=${workConfigDir}
        exec ${piPackage}/bin/pi "$@"
      '';
    })
  ];

  # Best-effort: materializes packages declared in settings.json's
  # `packages` array. Versioned specs (all of ours are) are skipped by
  # `pi update --extensions` once already installed, so this only does real
  # work on a fresh machine or when the roster changes.
  home.activation.piExtensions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${piPackage}/bin/pi update --extensions || true
    ${lib.optionalString hasWorkProfile ''
      PI_CODING_AGENT_DIR=${workConfigDir} ${piPackage}/bin/pi update --extensions || true
    ''}
  '';
}
