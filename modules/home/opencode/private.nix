{
  provider."nvidia-nim" = {
    npm = "@ai-sdk/openai-compatible";
    name = "NVIDIA NIM";
    options = {
      baseURL = "https://integrate.api.nvidia.com/v1";
      apiKey = "{env:NVIDIA_NIM_API_KEY}";
    };
    models = {
      "moonshotai/kimi-k2.6" = { };
      "z-ai/glm-5.2" = { };
    };
  };

  agent = {
    build.model = "openai/gpt-5.6-codex";
    plan.model = "openai/gpt-5.6-codex-max";
  };
}
