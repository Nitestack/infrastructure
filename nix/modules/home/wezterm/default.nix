# ╭──────────────────────────────────────────────────────────╮
# │ WezTerm                                                  │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  pkgs,
  meta,
  theme,
  ...
}:
let
  inherit (flake) inputs;
  inherit (meta) font;
in
{
  programs.wezterm = {
    enable = true;
    package = inputs.wezterm.packages.${pkgs.system}.default;
    enableZshIntegration = true;
    extraConfig =
      let
        inherit (theme.variables)
          windowBgColor
          headerbarBorderColor
          headerbarBgColor
          windowFgColor
          ;
      in
      ''
        local config = wezterm.config_builder()

        require("config.appearance").setup(config)
        require("config.general").setup(config)
        require("config.keys").setup(config)
        require("config.platforms").setup(config)

        config.font = wezterm.font_with_fallback({
          "${font.nerd.name}",
          "Symbols Nerd Font",
          "Noto Color Emoji",
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
        config.window_background_gradient.colors = { "${windowBgColor}", "${headerbarBorderColor}", "${headerbarBgColor}" }
        config.command_palette_bg_color = "${headerbarBorderColor}"
        config.command_palette_fg_color = "${windowFgColor}"

        return config
      '';
  };
  xdg.configFile."wezterm/config".source = ./config;
}
