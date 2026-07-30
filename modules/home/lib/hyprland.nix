# ╭──────────────────────────────────────────────────────────╮
# │ Shared Hyprland keybind helpers                          │
# ╰──────────────────────────────────────────────────────────╯
{ lib, pkgs }:
{
  uwsm = "${lib.getExe pkgs.uwsm} app --";

  mkBind = keys: desc: luaDispatcher: flags: {
    _args = [
      keys
      (lib.generators.mkLuaInline luaDispatcher)
    ]
    ++ lib.optional (flags != { } || desc != "") (
      flags // lib.optionalAttrs (desc != "") { description = desc; }
    );
  };
}
