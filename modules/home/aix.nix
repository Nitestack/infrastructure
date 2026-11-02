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
    };
  };
}
