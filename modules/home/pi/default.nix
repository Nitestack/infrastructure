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
    "pi-prompt-template-model"
    "pi-provider-fallback"
    "pi-web-access"
    "cc-safety-net"
    "pi-plan-mode"
    "@ayulab/pi-rewind"
    "@juicesharp/rpiv-ask-user-question"
    "pi-notify"
    "@narumitw/pi-usage"
    "pi-btw"
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

  piRunScript = ''
    export NVIDIA_NIM_API_KEY="$(cat ${config.sops.secrets.nim-api-key.path})"
    # pi-provider-fallback hardcodes ~/.pi/agent/... and ignores
    # PI_CODING_AGENT_DIR, so redirect it here or pi-work loads the private
    # profile's fallback config instead of its own.
    export PI_PROVIDER_FALLBACK_CONFIG="''${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}/extensions/provider-fallback.json"
    exec ${lib.getExe inputs.llm-agents-nix.packages.${pkgs.stdenv.hostPlatform.system}.pi} "$@"
  '';

  piFhs = pkgs.buildFHSEnv {
    name = "pi";
    targetPkgs =
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
    runScript = pkgs.writeShellScript "pi-run" piRunScript;
  };
  piPackage = if pkgs.stdenv.isLinux then piFhs else pkgs.writeShellScriptBin "pi" piRunScript;

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
        piLib.mkProviderFallback { roleMap = roles; }
      );
      "${configDir}/zentui.json".text = builtins.toJSON zentuiConfig;
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
        exec ${piPackage}/bin/pi "$@"
      '';
    })
  ];

  # Best-effort install of settings.json's `packages`; already-installed
  # versioned specs are skipped, so this only bites on a fresh machine or
  # roster change. Ordered after sops-nix, not just writeBoundary: piRunScript
  # reads the NIM secret that sops-nix decrypts, and two writeBoundary-only
  # entries aren't ordered relative to each other.
  home.activation.piExtensions = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
    ${piPackage}/bin/pi update --extensions || true
    ${lib.optionalString hasWorkProfile ''
      PI_CODING_AGENT_DIR=${workConfigDir} ${piPackage}/bin/pi update --extensions || true
    ''}
  '';
}
