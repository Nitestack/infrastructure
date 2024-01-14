local wezterm = require("wezterm")
local Config = require("config")
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")

return smart_splits.apply_to_config(
  Config:init():append_module("general"):append_module("appearance"):append_module("keys"):append_platform().options,
  {
    -- directional keys to use in order of: left, down, up, right
    direction_keys = { "h", "j", "k", "l" },
    modifiers = {
      move = "CTRL", -- modifier to use for pane movement, e.g. CTRL+h to move left
      resize = "LEADER", -- modifier to use for pane resize, e.g. META+h to resize to the left
    },
  }
)
