# ╭──────────────────────────────────────────────────────────╮
# │ Pi                                                       │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  flake,
  config,
  lib,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;

  piLib = import ./lib.nix { inherit lib; };
  private = import ./roles/private.nix;
  work = import ./roles/work.nix;

  commonExtensions = [
    "pi-subagents"
    "@gotgenes/pi-permission-system"
    "pi-prompt-template-model"
    "pi-provider-fallback"
    "cc-safety-net"
    "@narumitw/pi-plan-mode"
    "@ayulab/pi-rewind"
    "@juicesharp/rpiv-ask-user-question"
    "pi-notify"
    "@narumitw/pi-usage"
    "@narumitw/pi-btw"
    "@sherif-fanous/pi-catppuccin"
    "pi-zentui"
    "pi-working-phrase"
    # Probation
    "pi-agent-browser-native"
    "pi-lens"
  ]
  ++ lib.optional (config.programs.tmux.enable or false) "pi-tmux-spinner";

  privateExtensions = commonExtensions ++ private.extensions;
  workExtensions = commonExtensions ++ work.extensions;
  privateRoles = private.roles;
  workRoles = work.roles;

  mkPiRunScript =
    { exportNim }:
    ''
      ${lib.optionalString exportNim ''
        export NVIDIA_NIM_API_KEY="$(cat ${config.sops.secrets.nim-api-key.path})"
      ''}
      # pi-provider-fallback hardcodes ~/.pi/agent/... and ignores
      # PI_CODING_AGENT_DIR, so redirect it here or pi-work loads the private
      # profile's fallback config instead of its own.
      export PI_PROVIDER_FALLBACK_CONFIG="''${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}/extensions/provider-fallback.json"
      exec ${lib.getExe inputs.llm-agents-nix.packages.${pkgs.stdenv.hostPlatform.system}.pi} "$@"
    '';

  piFhsTargetPkgs =
    _: with pkgs; [
      gnumake
      gcc
      binutils
      pkg-config
      jq
      nodejs
      bash
      coreutils
      findutils
      gnused
      gnugrep
      git
      curl
    ];

  mkPiPackage =
    { name, exportNim }:
    let
      runScript = mkPiRunScript { inherit exportNim; };
    in
    if pkgs.stdenv.isLinux then
      pkgs.buildFHSEnv {
        inherit name;
        targetPkgs = piFhsTargetPkgs;
        runScript = pkgs.writeShellScript "${name}-run" runScript;
      }
    else
      pkgs.writeShellScriptBin name runScript;

  piPackage = mkPiPackage {
    name = "pi";
    exportNim = true;
  };
  piWorkPackage = mkPiPackage {
    name = "pi-work";
    exportNim = false;
  };

  hasWorkProfile = config.programs.aix.enable or false;

  workConfigDir = "${config.home.homeDirectory}/.pi/agent-work";

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

  # Reviewer/oracle may want to inspect the repo themselves (diff, log,
  # status) rather than asking the main agent to hand them one; bash stays
  # restricted to that inspection surface, everything else falls back to ask.
  readOnlyInspectionPermission = {
    "*" = "ask";
    read = "allow";
    grep = "allow";
    find = "allow";
    ls = "allow";
    bash = {
      "*" = "ask";
      "git diff*" = "allow";
      "git log*" = "allow";
      "git show*" = "allow";
      "git status" = "allow";
      "rg *" = "allow";
      "grep *" = "allow";
      "find *" = "allow";
      "cat *" = "allow";
    };
  };

  subagents = roles: {
    "reviewer.md" = piLib.mkSubagent {
      name = "reviewer";
      description = "Reviews diffs and PRs for correctness, spec alignment, and regressions before you approve them.";
      role = roles.reviewer;
      tools = [
        "read"
        "grep"
        "find"
        "ls"
        "bash"
      ];
      extensions = [ ];
      permission = readOnlyInspectionPermission;
      maxSubagentDepth = 0;
    };
    "oracle.md" = piLib.mkSubagent {
      name = "oracle";
      description = "Answers architecture and design judgment questions; same tier as reviewer.";
      role = roles.reviewer;
      tools = [
        "read"
        "grep"
        "find"
        "ls"
        "bash"
      ];
      extensions = [ ];
      permission = readOnlyInspectionPermission;
      maxSubagentDepth = 0;
    };
    "scout.md" = piLib.mkSubagent {
      name = "scout";
      description = "Explores the codebase read-mostly to answer where-is-X / how-does-Y-work questions before implementation.";
      role = roles.scout;
      tools = [
        "read"
        "grep"
        "find"
        "ls"
      ];
      extensions = [ ];
      maxSubagentDepth = 0;
    };
    "smol.md" = piLib.mkSubagent {
      name = "smol";
      description = "Cheap, fast read-mostly exploration; alias of scout for volume work.";
      role = roles.scout;
      tools = [
        "read"
        "grep"
        "find"
        "ls"
      ];
      extensions = [ ];
      maxSubagentDepth = 0;
    };
    "worker.md" = piLib.mkSubagent {
      name = "worker";
      description = "Implements code changes for a well-scoped task handed to it.";
      role = roles.worker;
      tools = [
        "read"
        "grep"
        "find"
        "ls"
        "edit"
        "write"
        "bash"
      ];
      # No interactive/theme extensions are meaningful in a headless child.
      # Already trusted with edit/write at the tool-visibility layer, so
      # bash isn't gated down separately here.
      extensions = [ ];
      maxSubagentDepth = 0;
    };
    "vision.md" = piLib.mkSubagent {
      name = "vision";
      description = "Understands screenshots and images: UI review, error screenshots, diagrams.";
      role = roles.vision;
      tools = [ "read" ];
      extensions = [ ];
      maxSubagentDepth = 0;
    };
  };

  zentuiConfig = {
    separator = "dot";
    pathDisplay = {
      mode = "full";
      depth = 0;
    };
    fixedEditor.enabled = true;
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
        piLib.mkProviderFallback { role = roles.default; }
      );
      "${configDir}/zentui.json".text = builtins.toJSON zentuiConfig;
      # Starting values, not tuned optima: bound how much parallel/nested
      # work pi-subagents can generate for a personal setup.
      "${configDir}/extensions/subagent/config.json".text = builtins.toJSON {
        asyncByDefault = false;
        globalConcurrencyLimit = 4;
        maxSubagentSpawnsPerSession = 24;
      };
    };
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    gnupg.home = "${config.home.homeDirectory}/.gnupg";
    gnupg.sshKeyPaths = [ ];
    secrets.nim-api-key.sopsFile = self + /secrets/shared/nim.yaml;
  };

  programs.pi-coding-agent = {
    enable = true;
    package = piPackage;
    context = ./context.md;
    settings = piLib.mkSettings {
      roleMap = privateRoles;
      extensions = privateExtensions;
    };
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
          (piLib.mkSettings {
            roleMap = workRoles;
            extensions = workExtensions;
          })
          // {
            litellm = {
              mcp.enabled = false;
              skills.enabled = false;
            };
          }
        );
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
        exec ${piWorkPackage}/bin/pi-work "$@"
      '';
    })
  ];

  # Best-effort install of settings.json's `packages`; already-installed
  # versioned specs are skipped, so this only bites on a fresh machine or
  # roster change. Ordered after sops-nix, not just writeBoundary: pi's run
  # script reads the NIM secret that sops-nix decrypts, and two
  # writeBoundary-only entries aren't ordered relative to each other.
  home.activation.piExtensions = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
    ${piPackage}/bin/pi update --extensions || true
    ${lib.optionalString hasWorkProfile ''
      PI_CODING_AGENT_DIR=${workConfigDir} ${piWorkPackage}/bin/pi-work update --extensions || true
    ''}
  '';
}
