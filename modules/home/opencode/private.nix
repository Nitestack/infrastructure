{
  formatter = true;
  warming = true;

  providers = {
    nvidia = { };
    openai = { };
    openrouter = { };
  };

  agents = {
    build.model = "openai/gpt-6-luna#max";
    plan.model = "openai/gpt-6-sol#high";
    general.model = "openai/gpt-6-luna#max";
    explore.model = "openai/gpt-6-luna#medium";
    title.model = "openai/gpt-6-luna#none";
    summary.model = "openai/gpt-6-luna#low";
  };
}
