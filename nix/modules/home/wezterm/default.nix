# ╭──────────────────────────────────────────────────────────╮
# │ WezTerm                                                  │
# ╰──────────────────────────────────────────────────────────╯
{ meta, pkgs, ... }:
let
  inherit (meta) font maxRefreshRate;
in
{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local config = wezterm.config_builder()

      config.default_prog = { "${pkgs.nushell}/bin/nu" }

      -- Font
      config.font = wezterm.font_with_fallback({
        "${font.nerd.name}",
        "Iosevka Nerd Font",
        "Symbols Nerd Font",
        "${font.emoji.name}",
      })
      config.font_rules = {
        {
          italic = true,
          font = wezterm.font({
            family = "${font.nerd.italic.name}",
            style = "Italic",
            weight = "DemiBold",
          }),
        },
      }
      config.animation_fps = ${toString maxRefreshRate}
      config.max_fps = ${toString maxRefreshRate}

      require("config.appearance").setup(config)
      require("config.general").setup(config)
      require("config.keys").setup(config)
      require("config.platforms").setup(config)

      return config
    '';
  };
  xdg.configFile."wezterm/config".source = ./config;
}
