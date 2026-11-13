{
  flake,
  osConfig,
  ...
}:
let
  inherit (flake.inputs) aix;
  sopsPath = name: osConfig.sops.secrets.${name}.path;
in
{
  imports = [ aix.homeManagerModules.aix ];

  programs.aix = {
    enable = true;
    endpoint.baseUrl.file = sopsPath "aix/base-url";
    profiles = {
      p = {
        label.file = sopsPath "aix/p-label";
        apiKey.file = sopsPath "aix/p";
      };
      ae = {
        label.file = sopsPath "aix/ae-label";
        apiKey.file = sopsPath "aix/ae";
      };
      nim = {
        label.file = sopsPath "aix/nim-label";
        apiKey.file = sopsPath "aix/nim";
      };
      adp = {
        label.file = sopsPath "aix/adp-label";
        apiKey.file = sopsPath "aix/adp";
      };
      ac = {
        label.file = sopsPath "aix/ac-label";
        apiKey.file = sopsPath "aix/ac";
      };
      acs = {
        label.file = sopsPath "aix/acs-label";
        apiKey.file = sopsPath "aix/acs";
      };
      nim4 = {
        label.file = sopsPath "aix/nim4-label";
        apiKey.file = sopsPath "aix/nim4";
      };
      ae2 = {
        label.file = sopsPath "aix/ae2-label";
        apiKey.file = sopsPath "aix/ae2";
        # Anthropic-only key; talks to Anthropic directly instead of the gateway.
        baseUrl = "https://api.anthropic.com";
      };
    };
  };
}
