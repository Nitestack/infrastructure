{
  "$schema" = "https://opencode.ai/config.json";

  plugin = [ "opencode-models-discovery@1.1.0" ];

  provider = {
    litellm-chat = {
      npm = "@ai-sdk/openai-compatible";
      name = "LiteLLM Chat";
      options = {
        baseURL = "{env:LITELLM_BASE_URL}";
        apiKey = "{env:LITELLM_API_KEY}";
        modelsDiscovery = {
          enabled = true;
          modelInfoFormat = "litellm";
          modelInfoEndpoint = "{env:LITELLM_ROOT_BASE_URL}/v1/model/info";
          models.excludeBy = [
            {
              field = "id";
              match = "^claude-";
            }
            {
              field = "id";
              match = "^(US-)?(gpt-5|o3-|o4-)";
            }
            {
              field = "id";
              match = "(embed|image|vision|whisper|tts|dall-e|rerank)";
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
      name = "LiteLLM Responses (GPT-5/o3/o4)";
      options = {
        baseURL = "{env:LITELLM_BASE_URL}";
        apiKey = "{env:LITELLM_API_KEY}";
        modelsDiscovery = {
          enabled = true;
          modelInfoFormat = "litellm";
          modelInfoEndpoint = "{env:LITELLM_ROOT_BASE_URL}/v1/model/info";
          models.includeBy = [
            {
              field = "id";
              match = "^(US-)?(gpt-5|o3-|o4-)";
            }
          ];
        };
      };
    };

    litellm-anthropic = {
      npm = "@ai-sdk/anthropic";
      name = "LiteLLM Anthropic (Claude)";
      options = {
        baseURL = "{env:LITELLM_ROOT_BASE_URL}/anthropic";
        apiKey = "{env:LITELLM_API_KEY}";
      };
      models = builtins.listToAttrs (
        map
          (id: {
            name = id;
            value = { };
          })
          [
            "claude-opus-4-5*"
            "claude-sonnet-4-5*"
            "claude-haiku-4-5*"
            "claude-opus-4-6*"
            "claude-sonnet-4-6*"
            "claude-sonnet-5*"
            "claude-opus-4-7*"
            "claude-opus-4-8*"
          ]
      );
    };
  };

  agent = {
    build.model = "litellm-anthropic/claude-sonnet-5*";
    plan.model = "litellm-anthropic/claude-opus-4-8*";
  };
}
