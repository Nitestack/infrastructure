{
  plugins = [ "opencode-models-discovery@1.10.0" ];
  experimental.quotaToast.enabled = false;
  warming = false;

  # Deny inherited private providers; only the LiteLLM providers below are allowed.
  experimental.policies = [
    {
      action = "provider.use";
      resource = "*";
      effect = "deny";
    }
    {
      action = "provider.use";
      resource = "litellm-chat";
      effect = "allow";
    }
    {
      action = "provider.use";
      resource = "litellm-responses";
      effect = "allow";
    }
    {
      action = "provider.use";
      resource = "litellm-anthropic";
      effect = "allow";
    }
  ];

  providers = {
    litellm-chat = {
      package = "@opencode/ai/providers/openai-compatible";
      name = "LiteLLM";
      env = [ "LITELLM_API_KEY" ];
      settings = {
        baseURL = "{env:LITELLM_BASE_URL}";
        apiKey = "{env:LITELLM_API_KEY}";
        modelsDiscovery = {
          enabled = true;
          modelInfoFormat = "litellm";
          smartModelName = true;
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
      package = "@opencode/ai/providers/openai-compatible/responses";
      name = "OpenAI";
      env = [ "LITELLM_API_KEY" ];
      settings = {
        baseURL = "{env:LITELLM_BASE_URL}";
        apiKey = "{env:LITELLM_API_KEY}";
        modelsDiscovery = {
          enabled = true;
          modelInfoFormat = "litellm";
          smartModelName = true;
          models.includeBy = [
            {
              field = "id";
              match = "^(?:US-)?(?:gpt-6-astra|gpt-6[.]1-(?:sol|terra)|gpt-6-luna)$";
            }
          ];
        };
      };
    };

    litellm-anthropic = {
      package = "@opencode/ai/providers/anthropic-compatible";
      name = "Anthropic";
      env = [ "LITELLM_API_KEY" ];
      settings = {
        baseURL = "{env:LITELLM_BASE_URL}";
        apiKey = "{env:LITELLM_API_KEY}";
        modelsDiscovery = {
          enabled = true;
          endpoint = "/v1/models?return_wildcard_routes=true";
          modelInfoEndpoint = "/v2/model/info";
          modelInfoFormat = "litellm";
          smartModelName = true;
          models.includeBy = [
            {
              field = "id";
              match = "^claude-(?:.*-5-5|fable-5-1)\\*?$";
            }
          ];
        };
      };
    };
  };

  agents = {
    build.model = "litellm-responses/gpt-6-luna#max";
    plan.model = "litellm-responses/gpt-6.1-sol#high";
    general.model = "litellm-responses/gpt-6-luna#max";
    explore.model = "litellm-responses/gpt-6-luna#medium";
    title.model = "litellm-chat/deepseek-v4-flash-sovereign#none";
    summary.model = "litellm-chat/qwen-3.6-35b-sovereign#low";
  };
}
