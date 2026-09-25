let
  mkClaudeModel =
    {
      name,
      family,
      context,
      output,
      inputCost,
      outputCost,
    }:
    {
      inherit name family;
      attachment = true;
      reasoning = true;
      tool_call = true;
      options.thinking.blockBinding = false;
      cost = {
        input = inputCost;
        output = outputCost;
      };
      limit = {
        inherit context output;
      };
      modalities = {
        input = [
          "text"
          "image"
          "pdf"
        ];
        output = [ "text" ];
      };
    };
in
{
  plugin = [ "opencode-models-discovery@1.5.5" ];

  enabled_providers = [
    "litellm-chat"
    "litellm-responses"
    "litellm-anthropic"
  ];

  provider = {
    litellm-chat = {
      npm = "@ai-sdk/openai-compatible";
      name = "LiteLLM";
      options = {
        baseURL = "{env:LITELLM_BASE_URL}";
        apiKey = "{env:LITELLM_API_KEY}";
        modelsDiscovery = {
          enabled = true;
          modelInfoFormat = "litellm";
          smartModelName = true;
          cache = {
            enabled = true;
            ttlSeconds = 86400;
          };
          models.excludeBy = [
            {
              field = "id";
              match = "^claude-";
            }
            {
              field = "id";
              match = "^(?:US-)?(?:gpt-[4-6]|o[3-4]-)";
            }
          ];
        };
      };
    };

    litellm-responses = {
      npm = "@ai-sdk/openai";
      name = "OpenAI";
      options = {
        baseURL = "{env:LITELLM_BASE_URL}";
        apiKey = "{env:LITELLM_API_KEY}";
        modelsDiscovery = {
          enabled = true;
          modelInfoFormat = "litellm";
          smartModelName = true;
          cache = {
            enabled = true;
            ttlSeconds = 86400;
          };
          models.includeBy = [
            {
              field = "id";
              match = "^(?:US-)?gpt-6-.+$";
            }
          ];
        };
      };
    };

    litellm-anthropic = {
      npm = "@ai-sdk/anthropic";
      name = "Anthropic";
      options = {
        baseURL = "{env:LITELLM_BASE_URL}";
        apiKey = "{env:LITELLM_API_KEY}";
      };
      models = {
        "claude-opus-5-5" = mkClaudeModel {
          name = "Claude Opus 5.5";
          family = "claude-opus";
          context = 1000000;
          output = 128000;
          inputCost = 4.4;
          outputCost = 22.0;
        };
        "claude-opus-5" = mkClaudeModel {
          name = "Claude Opus 5";
          family = "claude-opus";
          context = 1000000;
          output = 128000;
          inputCost = 5.5;
          outputCost = 27.5;
        };
        "claude-haiku-4-5" = mkClaudeModel {
          name = "Claude Haiku 4.5";
          family = "claude-haiku";
          context = 200000;
          output = 64000;
          inputCost = 1.1;
          outputCost = 5.5;
        };
        "claude-sonnet-4-6" = mkClaudeModel {
          name = "Claude Sonnet 4.6";
          family = "claude-sonnet";
          context = 1000000;
          output = 128000;
          inputCost = 3.3;
          outputCost = 16.5;
        };
        "claude-sonnet-5" = mkClaudeModel {
          name = "Claude Sonnet 5";
          family = "claude-sonnet";
          context = 1000000;
          output = 128000;
          inputCost = 2.2;
          outputCost = 11.0;
        };
        "claude-fable-5-1" = mkClaudeModel {
          name = "Claude Fable 5.1";
          family = "claude-fable";
          context = 1000000;
          output = 128000;
          inputCost = 11.0;
          outputCost = 55.0;
        };
      };
    };
  };

  agent = {
    build = {
      model = "litellm-responses/gpt-6-luna";
      reasoningEffort = "max";
    };
    plan = {
      model = "litellm-anthropic/claude-opus-5-5";
      variant = "high";
    };
    general = {
      model = "litellm-responses/gpt-6-luna";
      reasoningEffort = "max";
    };
    explore = {
      model = "litellm-responses/gpt-6-luna";
      reasoningEffort = "medium";
    };
    title = {
      model = "litellm-chat/deepseek-v4-flash-sovereign";
      reasoningEffort = "none";
    };
    summary = {
      model = "litellm-chat/qwen-3.6-35b-sovereign";
      reasoningEffort = "low";
    };
  };
}
