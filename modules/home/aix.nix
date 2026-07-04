{
  flake,
  ...
}:
let
  inherit (flake.inputs) aix;
in
{
  imports = [ aix.homeManagerModules.aix ];

  programs.aix = {
    enable = true;
    endpoint.baseUrl.file = "/run/secrets/aix/base-url";
    profiles = {
      p = {
        label.file = "/run/secrets/aix/p-label";
        apiKey.file = "/run/secrets/aix/p";
      };
      adp = {
        label.file = "/run/secrets/aix/adp-label";
        apiKey.file = "/run/secrets/aix/adp";
      };
      swtb = {
        label.file = "/run/secrets/aix/swtb-label";
        apiKey.file = "/run/secrets/aix/swtb";
      };
      "p-t" = {
        label.file = "/run/secrets/aix/p-t-label";
        apiKey.file = "/run/secrets/aix/p-t";
      };
    };
  };
}
