{
  provider."nvidia-nim" = {
    npm = "@ai-sdk/openai-compatible";
    name = "NVIDIA NIM";
    options = {
      baseURL = "https://integrate.api.nvidia.com/v1";
      apiKey = "{env:NVIDIA_NIM_API_KEY}";
    };
    # Same fallback catalog entries Pi's private profile already uses.
    models = {
      "moonshotai/kimi-k2.6" = { };
      "z-ai/glm-5.2" = { };
    };
  };

  agent = {
    # Placeholder model IDs — verify via `opencode models` after completing
    # ChatGPT OAuth login (`/connect`), then update here.
    build.model = "openai/gpt-5.6-codex";
    plan.model = "openai/gpt-5.6-codex-max";
  };
}
