# ╭──────────────────────────────────────────────────────────╮
# │ Top-level                                                │
# ╰──────────────────────────────────────────────────────────╯
{ inputs, ... }:
{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
  ];
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    let
      formatNixFiles = ''
        args=("$@")
        find . \
          -type f \
          -name '*.nix' \
          -not -path './.git/*' \
          -not -path './.worktrees/*' \
          -not -path './worktrees/*' \
          -not -name 'hardware-configuration.nix' \
          -print0 \
          | xargs -0 nixfmt "''${args[@]}"
      '';
    in
    {
      formatter = pkgs.writeShellApplication {
        name = "nix-config-fmt";
        runtimeInputs = [
          pkgs.findutils
          pkgs.nixfmt
        ];
        text = formatNixFiles;
      };

      packages.check = pkgs.writeShellApplication {
        name = "nix-config-check";
        runtimeInputs = [
          pkgs.git-lfs
          pkgs.nix
        ];
        text = ''
          nix fmt -- --check
          nix flake check --no-build --no-write-lock-file
        '';
      };

      apps.check = {
        type = "app";
        program = "${config.packages.check}/bin/nix-config-check";
        meta.description = "Run formatting and flake evaluation checks";
      };
    };
}
