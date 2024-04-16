---@type Wezterm
local wezterm = require("wezterm")
local config = wezterm.config_builder()
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")

require("config.appearance").setup(config)
require("config.general").setup(config)
require("config.keys").setup(config)
require("config.platforms").setup(config)

---@type SmartSplitsWeztermConfig
local smart_splits_config = {
  direction_keys = { "h", "j", "k", "l" },
  modifiers = {
    move = "CTRL",
    resize = "LEADER",
  },
}

return smart_splits.apply_to_config(config, smart_splits_config)
