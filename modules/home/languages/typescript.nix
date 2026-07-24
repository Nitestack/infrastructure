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
  PNPM_HOME = "${config.home.homeDirectory}/.local/share/pnpm";

  npmPrefix = config.programs.npm.settings.prefix;
in
{
  home = {
    packages = with pkgs; [
      deno
      pnpm
      prisma
      prisma-engines

      npkill
    ];

    # ── Prisma ────────────────────────────────────────────────────────────
    sessionVariables = {
      inherit PNPM_HOME;
      PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
      PRISMA_QUERY_ENGINE_BINARY = lib.getExe' pkgs.prisma-engines "query-engine";
      PRISMA_SCHEMA_ENGINE_BINARY = lib.getExe pkgs.prisma-engines;
    };
    sessionPath = [
      "${PNPM_HOME}/bin"
      "${npmPrefix}/bin"
    ];
  };

  programs.npm.enable = true;
}
