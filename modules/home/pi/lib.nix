# Shared renderer: turns a role-map attrset into the file set both the
# `pi` and `pi-work` profiles are made of. Profiles differ only in the
# role-map (roles/private.nix, roles/work.nix) and the provider blocks
# passed to mkModels; everything else is rendered once from here.
{ lib }:
let
  qualify = r: "${r.provider}/${r.model}";
  qualifyThinking =
    r: qualify r + lib.optionalString (r ? thinking && r.thinking != null) ":${r.thinking}";

  # De-duplicated, order-preserving flatten of every model referenced
  # anywhere in the role map (primary + fallback steps).
  allModelRefs =
    roleMap:
    lib.unique (
      lib.concatMap (role: [ (qualify role) ] ++ map qualify (role.fallback or [ ])) (
        lib.attrValues roleMap
      )
    );

  frontmatter = attrs: body: "---\n${builtins.toJSON attrs}\n---\n${body}\n";
in
{
  inherit qualify qualifyThinking allModelRefs;

  # settings.json (minus the extra bits default.nix layers on: theme, packages).
  mkSettings =
    {
      roleMap,
      extensions,
      theme,
    }:
    let
      d = roleMap.default;
    in
    {
      defaultProvider = d.provider;
      defaultModel = d.model;
      defaultThinkingLevel = d.thinking or "medium";
      inherit theme;
      packages = map (e: "npm:${e}") extensions;
      # Cycle list (Ctrl+P): cheap-to-expensive as declared in the role map.
      enabledModels = allModelRefs roleMap;
    };

  # models.json custom-provider block (NIM for private, LiteLLM for work).
  # `providers` is passed straight through from the caller (default.nix /
  # roles/*.nix own the baseUrl/apiKey/model-catalog per provider).
  mkModels = { providers }: { inherit providers; };

  # ~/.pi/agent/extensions/provider-fallback.json — global cross-provider
  # protection for whatever model is currently active (story 13), not a
  # per-role chain: pi-subagents/pi-prompt-template-model already carry
  # their own fallbackModels/model spec per invocation. Every provider used
  # anywhere in the role map gets its fallback chain from every role that
  # uses it, de-duplicated and re-numbered by priority.
  mkProviderFallback =
    { roleMap }:
    let
      providersUsed = lib.unique (map (r: r.provider) (lib.attrValues roleMap));
      fallbacksFor =
        provider:
        let
          steps = lib.concatMap (r: if r.provider == provider then r.fallback or [ ] else [ ]) (
            lib.attrValues roleMap
          );
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

  # ~/.pi/agent/prompts/<name>.md — slash-command roles (pi-prompt-template-model).
  # Filename is the command name; `restore` switches back to the previous
  # model/thinking level once the command's turn finishes.
  mkPromptTemplate =
    {
      description,
      role,
      body,
      restore ? true,
    }:
    frontmatter (
      {
        inherit description restore;
        model = qualify role;
      }
      // lib.optionalAttrs (role ? thinking && role.thinking != null) { inherit (role) thinking; }
    ) body;

  # ~/.pi/agent/agents/<name>.md — delegated subagent roles (pi-subagents).
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
