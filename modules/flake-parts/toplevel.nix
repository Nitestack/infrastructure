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
      lib,
      ...
    }:
    let
      homelabArionRegressions = import ../../checks/homelab-arion-regressions.nix {
        inherit inputs pkgs;
        system = pkgs.stdenv.hostPlatform.system;
      };

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
        name = "infrastructure-fmt";
        runtimeInputs = [
          pkgs.findutils
          pkgs.nixfmt
        ];
        text = formatNixFiles;
      };

      packages.check = pkgs.writeShellApplication {
        name = "infrastructure-check";
        runtimeInputs = [
          pkgs.git-lfs
          pkgs.nix
        ];
        text = ''
          nix fmt -- --check
          nix flake check --no-build --no-write-lock-file
        '';
      };

      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.nixfmt
          pkgs.opentofu
        ];
        shellHook = ''
          git config core.hooksPath .githooks
        '';
      };

      checks.homelab-arion-regressions = homelabArionRegressions;

      apps.check = {
        type = "app";
        program = lib.getExe config.packages.check;
        meta.description = "Run formatting and flake evaluation checks";
      };
    };
}
