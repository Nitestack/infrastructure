{ pkgs, lib }:
{
  compileToCss =
    {
      src, # Path to your SCSS file
      variables ? { }, # Variables to inject (attrset)
      imports ? "", # Additional imports/content to prepend
      name ? "style.css", # Output filename (optional)
    }:
    let
      variableDeclarations = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: value: "\$${name}: ${value};") variables
      );
      mainScss = pkgs.writeText "main.scss" ''
        ${imports}

        ${variableDeclarations}

        ${builtins.readFile src}
      '';
    in
    pkgs.runCommand name
      {
        nativeBuildInputs = [ pkgs.dart-sass ];
      }
      ''
        sass --no-charset --no-source-map ${mainScss} $out
      '';
}
