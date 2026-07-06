{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
    ;

  renderedTemplateType = types.submodule {
    options = {
      source = mkOption {
        type = types.path;
      };

      replacements = mkOption {
        type = types.attrsOf types.str;
        default = { };
      };

      mode = mkOption {
        type = types.str;
        default = "0400";
      };
    };
  };
in
{
  options.homestation.renderedFiles = mkOption {
    type = types.attrsOf renderedTemplateType;
    default = { };
  };

  config.sops.templates = mapAttrs (_: file: {
    content =
      lib.replaceStrings (builtins.attrNames file.replacements) (builtins.attrValues file.replacements)
        (builtins.readFile file.source);
    inherit (file) mode;
  }) config.homestation.renderedFiles;
}
