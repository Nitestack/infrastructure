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
  formatter = true;

  permissions = map (resource: {
    action = "external_directory";
    inherit resource;
    effect = "allow";
  }) externalDirectories;

  cli.theme.name = "catppuccin";
}
