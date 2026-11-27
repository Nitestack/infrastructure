# ╭──────────────────────────────────────────────────────────╮
# │ TypeScript                                               │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  config,
  lib,
  ...
}:
let
  npmPrefix = config.programs.npm.settings.prefix;
in
{
  home = {
    packages = with pkgs; [
      deno
      prisma
      prisma-engines

      npkill
    ];

    # ── Prisma ────────────────────────────────────────────────────────────
    sessionVariables = {
      PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
      PRISMA_QUERY_ENGINE_BINARY = lib.getExe' pkgs.prisma-engines "query-engine";
      PRISMA_SCHEMA_ENGINE_BINARY = lib.getExe pkgs.prisma-engines;
    };
    sessionPath = [
      "${npmPrefix}/bin"
    ];
  };

  programs = {
    npm.enable = true;
    pnpm.enable = true;
  };

  # Share one content-addressable pnpm store across git worktrees on the same filesystem.
  xdg.configFile."pnpm/rc".text = ''
    store-dir=${config.xdg.dataHome}/pnpm/store
  '';
}
