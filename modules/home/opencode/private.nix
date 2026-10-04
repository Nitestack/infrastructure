{
  plugins = [ "@slkiser/opencode-quota@5.0.0" ];

  warming = true;

  providers = {
    nvidia = { };
    openai = { };
    openrouter = { };
  };

  agents = {
    build.model = "openai/gpt-6-luna#max";
    plan.model = "openai/gpt-6.1-sol#high";
    general.model = "openai/gpt-6-luna#max";
    explore.model = "openai/gpt-6-luna#medium";
    title.model = "openai/gpt-6-luna#none";
    summary.model = "openai/gpt-6-luna#low";
  };
}
