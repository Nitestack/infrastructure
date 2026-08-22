{
  plugin = [
    "@slkiser/opencode-quota@4.8.0"
  ];

  provider.openai = { };
  provider.openrouter = { };

  agent = {
    build = {
      # model = "openai/gpt-5.6-luna";
      # reasoningEffort = "max";
      model = "opencode/x-preview-f-free";
      reasoningEffort = "high";
    };
    plan = {
      model = "openai/gpt-5.6-sol";
      reasoningEffort = "high";
      textVerbosity = "medium";
    };
    general = {
      # model = "openai/gpt-5.6-terra";
      # reasoningEffort = "high";
      model = "opencode/x-preview-f-free";
      reasoningEffort = "high";
    };
    explore = {
      # model = "openai/gpt-5.6-luna";
      # reasoningEffort = "medium";
      model = "opencode/x-preview-f-free";
      reasoningEffort = "high";
    };
    compaction = {
      model = "openai/gpt-5.6-terra";
      reasoningEffort = "medium";
      textVerbosity = "medium";
    };
    title = {
      model = "openai/gpt-5.6-luna";
      reasoningEffort = "none";
    };
    summary = {
      model = "openai/gpt-5.6-luna";
      reasoningEffort = "low";
    };
  };

  tui.plugin = [
    "@slkiser/opencode-quota@4.8.0"
  ];
}
