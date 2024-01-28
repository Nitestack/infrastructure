---@type Wezterm
local wezterm = require("wezterm")
local config = wezterm.config_builder()
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")

require("config.appearance").setup(config)
require("config.general").setup(config)
require("config.keys").setup(config)
require("config.platforms").setup(config)

return smart_splits.apply_to_config(config, {
  -- directional keys to use in order of: left, down, up, right
  direction_keys = { "h", "j", "k", "l" },
  modifiers = {
    move = "CTRL", -- modifier to use for pane movement, e.g. CTRL+h to move left
    resize = "LEADER", -- modifier to use for pane resize, e.g. META+h to resize to the left
  },
})
