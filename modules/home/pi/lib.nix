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
    { roleMap }:
    let
      # Bucket by each step's own provider, not role.provider: fallback
      # chains can cross providers (e.g. openai-codex -> nvidia-nim), and
      # pi-provider-fallback only resolves same-provider entries per bucket.
      allFallbackSteps = lib.concatMap (r: r.fallback or [ ]) (lib.attrValues roleMap);
      providersUsed = lib.unique (
        (map (r: r.provider) (lib.attrValues roleMap)) ++ (map (s: s.provider) allFallbackSteps)
      );
      fallbacksFor =
        provider:
        let
          steps = lib.filter (s: s.provider == provider) allFallbackSteps;
          uniqueSteps = lib.foldl' (
            acc: s: if lib.any (x: x.model == s.model) acc then acc else acc ++ [ s ]
          ) [ ] steps;
        in
        lib.imap1 (i: s: {
          model = s.model;
          priority = i;
        }) uniqueSteps;
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
    ) description;
}
