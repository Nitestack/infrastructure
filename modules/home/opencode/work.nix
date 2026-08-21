{
  plugin = [ "opencode-models-discovery@1.4.0" ];

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
          modelInfoEndpoint = "/v1/model/info";
          models.excludeBy = [
            {
              field = "id";
              match = "^claude-";
            }
            {
              field = "id";
              match = "^(US-)?(gpt-4|gpt-5|o3-|o4-)";
            }
            {
              field = "id";
              match = "image";
            }
            {
              field = "id";
              match = "e5-mistral";
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
          modelInfoEndpoint = "/v1/model/info";
          models.includeBy = [
            {
              field = "id";
              match = "^(gpt-5\\.6|gpt-5-(mini|nano))";
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
      model = "litellm-anthropic/claude-sonnet-5";
      effort = "max";
    };
    plan = {
      model = "litellm-anthropic/claude-opus-5";
      effort = "high";
    };
    general = {
      model = "litellm-anthropic/claude-sonnet-5";
      effort = "high";
    };
    explore = {
      model = "litellm-responses/gpt-5-mini";
      reasoningEffort = "medium";
    };
    compaction = {
      model = "litellm-responses/gpt-5-mini";
      reasoningEffort = "high";
      textVerbosity = "medium";
    };
    title = {
      model = "litellm-chat/deepseek-v4-flash-sovereign";
    };
    summary = {
      model = "litellm-chat/qwen-3.6-35b-sovereign";
    };
  };
}
