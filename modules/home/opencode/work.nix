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
          # Explicit absolute endpoint, not left to default path-joining
          # against baseURL: the plugin appends its metadata path onto
          # baseURL directly (see the litellm-anthropic comment below for
          # the bug this causes), so a /v1-suffixed baseURL here would
          # otherwise risk a doubled /v1/v1/model/info request.
          modelInfoEndpoint = "{env:LITELLM_ROOT_BASE_URL}/v1/model/info";
          models.excludeBy = [
            {
              field = "id";
              match = "^claude-";
            }
            {
              field = "id";
              match = "^(gpt-5|o3-|o4-)";
            }
            {
              field = "id";
              match = "(?i)(embed|image|vision|whisper|tts|dall-e|rerank)";
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
          # See litellm-chat above: explicit absolute endpoint to avoid a
          # doubled /v1 in the discovery request.
          modelInfoEndpoint = "{env:LITELLM_ROOT_BASE_URL}/v1/model/info";
          models.includeBy = [
            {
              field = "id";
              match = "^(gpt-5|o3-|o4-)";
            }
          ];
        };
      };
    };

    litellm-anthropic = {
      npm = "@ai-sdk/anthropic";
      name = "LiteLLM Anthropic (Claude)";
      options = {
        # Root, not /v1 — LITELLM_BASE_URL is /v1-suffixed by aix, so the
        # opencode-work wrapper derives a root URL into
        # LITELLM_ROOT_BASE_URL (see default.nix). Not run through
        # modelsDiscovery: the plugin appends its endpoint path onto baseURL
        # directly, which would wrongly hit <root>/anthropic/v1/model/info
        # instead of <root>/v1/model/info.
        baseURL = "{env:LITELLM_ROOT_BASE_URL}/anthropic";
        apiKey = "{env:LITELLM_API_KEY}";
      };
      # Static list — current aliases live on the proxy, verbatim from
      # Pi's roles/work.nix (same proxy, same alias strings incl. trailing *).
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
    # Mirrors Pi's work default/worker (build) and plan roles.
    build.model = "litellm-anthropic/claude-sonnet-5*";
    plan.model = "litellm-anthropic/claude-opus-4-8*";
  };
}
