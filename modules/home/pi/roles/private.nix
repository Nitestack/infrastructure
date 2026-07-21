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
        provider = "nvidia-nim";
        model = "moonshotai/kimi-k2.6";
      }
      {
        provider = "nvidia-nim";
        model = "z-ai/glm-5.2";
      }
    ];
  };

  commit = {
    provider = "nvidia-nim";
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
        provider = "nvidia-nim";
        model = "moonshotai/kimi-k2.6";
      }
      {
        provider = "nvidia-nim";
        model = "nvidia/nemotron-3-ultra-550b-a55b";
      }
      {
        provider = "nvidia-nim";
        model = "deepseek-ai/deepseek-v4-pro";
      }
    ];
  };

  # smol is an alias of scout (same role, second invocation name).
  scout = {
    provider = "nvidia-nim";
    model = "nvidia/nemotron-3-nano-30b-a3b";
    fallback = [
      {
        provider = "nvidia-nim";
        model = "moonshotai/kimi-k2.6";
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
        provider = "nvidia-nim";
        model = "moonshotai/kimi-k2.6";
      }
      {
        provider = "nvidia-nim";
        model = "nvidia/nemotron-3-nano-30b-a3b";
      }
    ];
  };

  vision = {
    provider = "nvidia-nim";
    model = "moonshotai/kimi-k2.6";
    fallback = [
      {
        provider = "nvidia-nim";
        model = "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning";
      }
      {
        provider = "openai-codex";
        model = "gpt-5.6-luna";
        thinking = "low";
      }
    ];
  };
}
