# ╭──────────────────────────────────────────────────────────╮
# │ Herdr App                                                │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  pkgs,
  lib,
  ...
}:
let
  inherit (flake) inputs;

  prefixKey = "ctrl-a";

  # Prefix a set of keybindings with a modifier.
  withModifier =
    modifier: bindings:
    lib.mapAttrs' (key: action: lib.nameValuePair "${modifier}-${key}" action) bindings;

  # Generate Vim-style directional bindings.
  directions = {
    h = "left";
    j = "down";
    k = "up";
    l = "right";
  };

  directionBindings =
    modifier: command:
    withModifier modifier (lib.mapAttrs (_: direction: "${command}:${direction}") directions);

  keys = {
    global =
      directionBindings "alt" "pane.go"
      // directionBindings "alt-shift" "pane.swap"
      // withModifier "ctrl-alt" {
        "[" = "agent.prev";
        "]" = "agent.next";
        h = "tab.prev";
        j = "space.next";
        k = "space.prev";
        l = "tab.next";
      }
      // {
        "ctrl--" = "app.zoom_out";
        "ctrl-0" = "app.zoom_reset";
        "ctrl-=" = "app.zoom_in";
        "${prefixKey}" = "mod.open:tmux-prefix";
      };

    terminal = {
      "${prefixKey}" = "mod.open:tmux-prefix";
      "ctrl-shift-c" = "terminal.copy";
      "ctrl-shift-v" = "terminal.paste";
      "ctrl-shift-f" = "terminal.search";
      "ctrl-v" = "terminal.paste_image";
    };
    "mod:tmux-prefix" = {
      "${prefixKey}" = "tmux-prefix.send-prefix";
    };
  };
in
{
  home.packages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr-app
  ];

  xdg.configFile = {
    "herdr-app/settings.json".text = builtins.toJSON {
      font = "0xProto Nerd Font";
      terminal_line_height = 1.25;
      theme = "catppuccin-mocha";
    };
    "herdr-app/keys.json".text = builtins.toJSON keys;
  };
}
