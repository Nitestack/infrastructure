# Private profile role map (ChatGPT subscription via Codex OAuth + NVIDIA
# NIM free tier). Model IDs carried over from the old oh-my-pi
# private.config.yml's modelRoles; NIM IDs are new (issue #19).
#
# NIM is on the free developer tier: keep subagent fan-out modest (enforced
# where the extension actually exposes a knob — see NOTES.md).
{
  default = {
    provider = "openai-codex";
    model = "gpt-5.6-terra";
    thinking = "medium";
    fallback = [
      {
        provider = "openai-codex";
        model = "gpt-5.6-luna";
      }
      {
        provider = "nim";
        model = "kimi-k2.6";
      }
    ];
  };

  commit = {
    provider = "nim";
    model = "stepfun-ai/step-3.7-flash";
    fallback = [
      {
        provider = "openai-codex";
        model = "gpt-5.6-luna";
        thinking = "low";
      }
    ];
  };

  plan = {
    provider = "openai-codex";
    model = "gpt-5.6-sol";
    thinking = "high";
    fallback = [
      {
        provider = "openai-codex";
        model = "gpt-5.6-terra";
      }
    ];
  };

  # oracle is an alias of reviewer (same role, second invocation name).
  reviewer = {
    provider = "openai-codex";
    model = "gpt-5.6-sol";
    thinking = "high";
    fallback = [
      {
        provider = "openai-codex";
        model = "gpt-5.6-terra";
      }
      {
        provider = "nim";
        model = "kimi-k2.6";
      }
    ];
  };

  # smol is an alias of scout (same role, second invocation name).
  scout = {
    provider = "nim";
    model = "qwen/qwen3.5-122b-a10b";
    fallback = [
      {
        provider = "nim";
        model = "kimi-k2.6";
      }
      {
        provider = "openai-codex";
        model = "gpt-5.6-luna";
        thinking = "low";
      }
    ];
  };

  worker = {
    provider = "openai-codex";
    model = "gpt-5.6-luna";
    thinking = "low";
    fallback = [
      {
        provider = "nim";
        model = "kimi-k2.6";
      }
    ];
  };

  vision = {
    provider = "nim";
    model = "qwen/qwen3.5-122b-a10b";
    fallback = [
      {
        provider = "nim";
        model = "kimi-k2.6";
      }
      {
        provider = "openai-codex";
        model = "gpt-5.6-luna";
        thinking = "low";
      }
    ];
  };
}
