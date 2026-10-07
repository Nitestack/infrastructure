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
      adp = {
        label.file = sopsPath "aix/adp-label";
        apiKey.file = sopsPath "aix/adp";
      };
      tw = {
        label.file = sopsPath "aix/tw-label";
        apiKey.file = sopsPath "aix/tw";
      };
      ae = {
        label.file = sopsPath "aix/ae-label";
        apiKey.file = sopsPath "aix/ae";
      };
    };
  };
}
