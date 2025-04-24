# ╭──────────────────────────────────────────────────────────╮
# │ WezTerm                                                  │
# ╰──────────────────────────────────────────────────────────╯
{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local config = wezterm.config_builder()

      require("config.appearance").setup(config)
      require("config.general").setup(config)
      require("config.keys").setup(config)
      require("config.platforms").setup(config)

      return config
    '';
  };
  xdg.configFile."wezterm/config".source = ./config;
}
