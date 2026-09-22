let
  externalDirectories = [
    "/nix/store/*"
    "/tmp/*"
    "~/.cargo/*"
    "~/go/pkg/mod/*"
    "~/go/pkg/sumdb/*"
    "~/.local/share/pnpm/*"
    "~/.gradle/*"
    "~/.m2/repository/*"
  ];
in
{
  permission.external_directory = builtins.listToAttrs (
    map (resource: {
      name = resource;
      value = "allow";
    }) externalDirectories
  );

  permissions = map (resource: {
    action = "external_directory";
    inherit resource;
    effect = "allow";
  }) externalDirectories;

  tui.theme = "catppuccin";
}
