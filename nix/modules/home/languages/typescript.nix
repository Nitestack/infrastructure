# ╭──────────────────────────────────────────────────────────╮
# │ TypeScript                                               │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, config, ... }:
let
  PNPM_HOME = "${config.home.homeDirectory}/.local/share/pnpm";
in
{
  home = {
    packages = with pkgs; [
      deno
      nodejs
      pnpm
      prisma
      prisma-engines
      yarn

      npkill
    ];

    # ── Prisma ────────────────────────────────────────────────────────────
    sessionVariables = {
      inherit PNPM_HOME;
      PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
      PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
      PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
    };
    sessionPath = [ PNPM_HOME ];
  };
}
