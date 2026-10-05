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
      cost = {
        input = inputCost;
        output = outputCost;
      };
      limit = {
        inherit context output;
      };
    };
in
{
  plugins = [ "opencode-models-discovery@1.7.0" ];
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
      package = "@opencode/ai/providers/openai-compatible"; # TODO: replace with `openai-compatible/responses` when fixed: https://github.com/anomalyco/opencode/issues/49670
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
              match = "^(?:US-)?(?:gpt-6-astra|gpt-6[.]1-sol|gpt-6-luna)$";
            }
          ];
        };
      };
    };

    litellm-anthropic = {
      package = "@opencode/ai/providers/openai-compatible"; # TODO: replace with `anthropic-compatible` when fixed: https://github.com/anomalyco/opencode/issues/49670
      name = "Anthropic";
      env = [ "LITELLM_API_KEY" ];
      settings = {
        baseURL = "{env:LITELLM_BASE_URL}";
        apiKey = "{env:LITELLM_API_KEY}";
      };
      models = {
        "claude-sonnet-5-5" = mkClaudeModel {
          name = "Claude Sonnet 5.5";
          family = "claude-sonnet";
          context = 1000000;
          output = 128000;
          inputCost = 2.2;
          outputCost = 11.0;
        };
        "claude-opus-5-5" = mkClaudeModel {
          name = "Claude Opus 5.5";
          family = "claude-opus";
          context = 1000000;
          output = 128000;
          inputCost = 4.4;
          outputCost = 22.0;
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

  agents = {
    build.model = "litellm-responses/gpt-6-luna#max";
    plan.model = "litellm-anthropic/gpt-6.1-sol#high";
    general.model = "litellm-responses/gpt-6-luna#max";
    explore.model = "litellm-responses/gpt-6-luna#medium";
    title.model = "litellm-chat/deepseek-v4-flash-sovereign#none";
    summary.model = "litellm-chat/qwen-3.6-35b-sovereign#low";
  };
}
