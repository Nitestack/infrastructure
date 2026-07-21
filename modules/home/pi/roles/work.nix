# Work profile role map (LiteLLM gateway, provider "litellm" via the
# pi-provider-litellm extension). Model IDs carried over from the old
# oh-my-pi work.config.yml's modelRoles/enabledModels — plaintext, not
# secret; only the gateway base URL is sops-templated (see
# configurations/nixos/wslstation/sops.nix).
{
  default = {
    provider = "litellm";
    model = "claude-sonnet-5*";
    fallback = [
      {
        provider = "litellm";
        model = "gpt-5.4";
      }
      {
        provider = "litellm";
        model = "qwen3-coder-480b";
      }
    ];
  };

  commit = {
    provider = "litellm";
    model = "qwen-3.6-35b-sovereign";
    fallback = [
      {
        provider = "litellm";
        model = "deepseek-v4-flash-sovereign";
      }
      {
        provider = "litellm";
        model = "gpt-5-mini";
      }
    ];
  };

  plan = {
    provider = "litellm";
    model = "claude-opus-4-8*";
    thinking = "high";
    fallback = [
      {
        provider = "litellm";
        model = "gpt-5.5";
        thinking = "high";
      }
      {
        provider = "litellm";
        model = "claude-sonnet-5*";
        thinking = "high";
      }
    ];
  };

  reviewer = {
    provider = "litellm";
    model = "gpt-5.4";
    thinking = "high";
    fallback = [
      {
        provider = "litellm";
        model = "claude-opus-4-8*";
        thinking = "high";
      }
      {
        provider = "litellm";
        model = "devstral-2-123b";
        thinking = "high";
      }
    ];
  };

  scout = {
    provider = "litellm";
    model = "deepseek-v4-flash-sovereign";
    fallback = [
      {
        provider = "litellm";
        model = "qwen-3.6-35b-sovereign";
      }
      {
        provider = "litellm";
        model = "qwen3-coder-480b";
      }
    ];
  };

  worker = {
    provider = "litellm";
    model = "claude-sonnet-5*";
    fallback = [
      {
        provider = "litellm";
        model = "gpt-5.4";
      }
      {
        provider = "litellm";
        model = "qwen3-coder-480b";
      }
      {
        provider = "litellm";
        model = "devstral-2-123b";
      }
    ];
  };

  vision = {
    provider = "litellm";
    model = "gpt-5.4";
    fallback = [
      {
        provider = "litellm";
        model = "claude-sonnet-5*";
      }
      {
        provider = "litellm";
        model = "gemini-2.5-pro";
      }
    ];
  };
}
