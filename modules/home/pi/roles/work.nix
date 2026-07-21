# Work profile role map (LiteLLM gateway). Model IDs carried over from the
# old oh-my-pi work.config.yml's modelRoles/enabledModels — plaintext, not
# secret; only the gateway base URL is sops-templated (see
# configurations/nixos/wslstation/sops.nix).
{
  default = {
    provider = "work-litellm";
    model = "qwen3-coder-480b";
    fallback = [
      {
        provider = "work-litellm";
        model = "qwen-3.6-35b-sovereign";
      }
    ];
  };

  commit = {
    provider = "work-litellm";
    model = "qwen-3.6-35b-sovereign";
    fallback = [
      {
        provider = "work-litellm";
        model = "deepseek-v4-flash-sovereign";
      }
    ];
  };

  plan = {
    provider = "work-litellm";
    model = "claude-sonnet-5*";
    thinking = "high";
    fallback = [
      {
        provider = "work-litellm";
        model = "qwen3-coder-480b";
      }
    ];
  };

  reviewer = {
    provider = "work-litellm";
    model = "claude-opus-4-8*";
    thinking = "high";
    fallback = [
      {
        provider = "work-litellm";
        model = "claude-sonnet-5*";
      }
    ];
  };

  scout = {
    provider = "work-litellm";
    model = "deepseek-v4-flash-sovereign";
    fallback = [
      {
        provider = "work-litellm";
        model = "qwen-3.6-35b-sovereign";
      }
    ];
  };

  worker = {
    provider = "work-litellm";
    model = "qwen-3.6-35b-sovereign";
    fallback = [
      {
        provider = "work-litellm";
        model = "qwen3-coder-480b";
      }
    ];
  };

  vision = {
    provider = "work-litellm";
    model = "gemini-2.5-flash";
    fallback = [
      {
        provider = "work-litellm";
        model = "qwen3-coder-480b";
      }
    ];
  };
}
