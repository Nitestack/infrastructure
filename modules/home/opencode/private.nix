{
  plugin = [
    "@slkiser/opencode-quota@4.0.1"
  ];

  agent = {
    build.model = "openai/gpt-5.6-terra";
    plan.model = "openai/gpt-5.6-sol";
  };

  tui.plugin = [
    "@slkiser/opencode-quota@4.0.1"
  ];
}
