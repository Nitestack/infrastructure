# Work profile role map (LiteLLM gateway, provider "litellm" via the
# pi-provider-litellm extension). Model IDs carried over from the old
# oh-my-pi work.config.yml's modelRoles/enabledModels — plaintext, not
# secret; only the gateway base URL is sops-templated (see
# configurations/nixos/wslstation/sops.nix).
{
  default = {
    provider = "litellm";
    model = "qwen3-coder-480b";
    fallback = [
      {
        provider = "litellm";
        model = "qwen-3.6-35b-sovereign";
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
    ];
  };

  plan = {
    provider = "litellm";
    model = "claude-sonnet-5*";
    thinking = "high";
    fallback = [
      {
        provider = "litellm";
        model = "qwen3-coder-480b";
      }
    ];
  };

  reviewer = {
    provider = "litellm";
    model = "claude-opus-4-8*";
    thinking = "high";
    fallback = [
      {
        provider = "litellm";
        model = "claude-sonnet-5*";
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
    ];
  };

  worker = {
    provider = "litellm";
    model = "qwen-3.6-35b-sovereign";
    fallback = [
      {
        provider = "litellm";
        model = "qwen3-coder-480b";
      }
    ];
  };

  vision = {
    provider = "litellm";
    model = "gemini-2.5-flash";
    fallback = [
      {
        provider = "litellm";
        model = "qwen3-coder-480b";
      }
    ];
  };
}
