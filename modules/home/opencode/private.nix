{
  plugin = [
    "@slkiser/opencode-quota@4.8.0"
  ];

  provider.openai = { };

  agent = {
    build = {
      model = "openai/gpt-5.6-luna";
      reasoningEffort = "max";
    };
    plan = {
      model = "openai/gpt-5.6-sol";
      reasoningEffort = "high";
      textVerbosity = "medium";
    };
    general = {
      model = "openai/gpt-5.6-terra";
      reasoningEffort = "high";
    };
    explore = {
      model = "openai/gpt-5.6-luna";
      reasoningEffort = "medium";
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
