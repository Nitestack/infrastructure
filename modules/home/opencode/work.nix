{
  plugin = [ "opencode-models-discovery@1.5.3" ];

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
              match = "^(US-)?(gpt-4|gpt-5|o3-|o4-)";
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
              match = "^(gpt-5\\.6)";
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
        modelsDiscovery.enabled = false;
      };
      models = builtins.listToAttrs (
        map
          (id: {
            name = id;
            value = { };
          })
          [
            "claude-opus-5"
            "claude-sonnet-5"
            "claude-opus-4-8"
            "claude-sonnet-4-6"
            "claude-haiku-4-5"
          ]
      );
    };
  };

  agent = {
    build = {
      model = "litellm-responses/gpt-5.6-luna";
      reasoningEffort = "max";
    };
    plan = {
      model = "litellm-anthropic/claude-opus-5";
      reasoningEffort = "high";
      textVerbosity = "medium";
    };
    general = {
      model = "litellm-responses/gpt-5.6-terra";
      reasoningEffort = "high";
    };
    explore = {
      model = "litellm-chat/deepseek-v4-flash-sovereign";
      reasoningEffort = "high";
    };
    compaction = {
      model = "litellm-responses/gpt-5.6-terra";
      reasoningEffort = "medium";
      textVerbosity = "medium";
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
