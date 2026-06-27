# ╭──────────────────────────────────────────────────────────╮
# │ Pi Coding Agent                                          │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, config, flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  commonSettings = import ./_settings.nix;
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    gnupg.home = "${config.home.homeDirectory}/.gnupg";
    gnupg.sshKeyPaths = [ ];
    secrets.nim-api-key = {
      sopsFile = self + /modules/secrets/nim.yaml;
    };
  };

  programs.pi-coding-agent = {
    enable = true;

    extraPackages = [ pkgs.nodejs ];

    settings = commonSettings // {
      defaultProvider = "codex";
    };

    models = {
      providers = {
        nim = {
          baseUrl = "https://integrate.api.nvidia.com/v1";
          api = "openai-completions";
          apiKey = "!cat ${config.sops.secrets.nim-api-key.path}";
          models = [
            { id = "nvidia/nemotron-3-ultra-550b-a55b"; }
            { id = "z-ai/glm-5.1"; }
            { id = "openai/gpt-oss-120b"; }
            { id = "deepseek-ai/deepseek-v4-pro"; }
            { id = "qwen/qwen3-next-80b-a3b-instruct"; }
            { id = "moonshotai/kimi-k2.6"; }
            { id = "deepseek-ai/deepseek-v4-flash"; }
            { id = "mistralai/mistral-small-4-119b-2603"; }
          ];
        };
      };
    };

    context = ''
      # Global Preferences

      ## Task Management
      Use rpiv-todo for any multi-step task. Create tasks before starting, mark done as you go.

      ## Clarification
      Use rpiv-ask-user-question when requirements are ambiguous. One question at a time.

      ## Risky Operations
      Set a /rewind checkpoint before any destructive or hard-to-reverse action.
      Use rpiv-advisor before acting on anything architecturally significant.

      ## Side Questions
      Use /btw for tangential questions that don't belong in the main thread.

      ## Memory
      Save project decisions, architecture notes, and preferences to pi-hermes-memory.
      Retrieve relevant memories at the start of each session.

      ## Web & Research
      Use pi-web-access for documentation, API references, and research needs.

      ## Code Quality
      Run pi-simplify after significant changes. Use pi-lens diagnostics proactively.
      Use plannotator for large plans or PR reviews.

      ## Skills
      Caveman, bigpowers, and rpiv-pi skills are available — invoke them proactively when relevant.

      ## Communication
      Be concise. Token efficiency matters.
    '';
  };
}
