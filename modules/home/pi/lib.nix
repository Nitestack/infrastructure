{ lib }:
let
  qualify = r: "${r.provider}/${r.model}";
  qualifyThinking =
    r: qualify r + lib.optionalString (r ? thinking && r.thinking != null) ":${r.thinking}";

  frontmatter = attrs: body: "---\n${builtins.toJSON attrs}\n---\n${body}\n";
in
{
  mkSettings =
    {
      roleMap,
      extensions,
    }:
    let
      d = roleMap.default;
    in
    {
      defaultProvider = d.provider;
      defaultModel = d.model;
      defaultThinkingLevel = d.thinking or "medium";
      theme = "catppuccin-mocha";
      quietStartup = true;
      packages = map (e: "npm:${e}") extensions;
    };

  mkProviderFallback =
    { role }:
    let
      # This is the *global session* fallback (extensions/provider-fallback.json),
      # which only ever governs the main agent — so it must be derived from the
      # default role's own chain, not every role's. Subagents get their fallback
      # chain independently via mkSubagent's fallbackModels. Bucketing here by
      # each step's own provider, not role.provider, because the chain can cross
      # providers (e.g. openai-codex -> nvidia-nim), and pi-provider-fallback
      # only resolves same-provider entries per bucket.
      steps = role.fallback or [ ];
      providersUsed = lib.unique ([ role.provider ] ++ (map (s: s.provider) steps));
      fallbacksFor =
        provider:
        lib.imap1 (i: s: {
          model = s.model;
          priority = i;
        }) (lib.filter (s: s.provider == provider) steps);
    in
    {
      enabled = true;
      providers = lib.genAttrs providersUsed (p: {
        enabled = true;
        fallbacks = fallbacksFor p;
      });
    };

  mkPromptTemplate =
    {
      description,
      role,
      body,
    }:
    frontmatter (
      {
        inherit description;
        restore = true;
        model = qualify role;
      }
      // lib.optionalAttrs (role ? thinking && role.thinking != null) { inherit (role) thinking; }
    ) body;

  mkSubagent =
    {
      name,
      description,
      role,
      tools ? null,
      extensions ? null,
      permission ? null,
      maxSubagentDepth ? null,
    }:
    frontmatter (
      {
        inherit name description;
        model = qualify role;
      }
      // lib.optionalAttrs (role ? thinking && role.thinking != null) { inherit (role) thinking; }
      // lib.optionalAttrs (role.fallback or [ ] != [ ]) {
        fallbackModels = map qualifyThinking role.fallback;
      }
      // lib.optionalAttrs (tools != null) { inherit tools; }
      // lib.optionalAttrs (extensions != null) { inherit extensions; }
      // lib.optionalAttrs (permission != null) { inherit permission; }
      // lib.optionalAttrs (maxSubagentDepth != null) { inherit maxSubagentDepth; }
    ) description;
}
