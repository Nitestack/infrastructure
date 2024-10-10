-- ╭─────────────────────────────────────────────────────────╮
-- │ WEZTERM CONFIG                                          │
-- ╰─────────────────────────────────────────────────────────╯

---@type Wezterm
---@diagnostic disable-next-line: assign-type-mismatch
local wezterm = require("wezterm")
local config = wezterm.config_builder()

require("config.appearance").setup(config)
require("config.general").setup(config)
require("config.keys").setup(config)
require("config.platforms").setup(config)

local function is_tmux_available()
  local success, stdout = wezterm.run_child_process({ "which", "tmux" })
  return success and stdout ~= nil and stdout ~= "" -- If `which tmux` succeeds and returns a valid path
end

if is_tmux_available() then
  return config
else
  local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")

  ---@type SmartSplitsWeztermConfig
  local smart_splits_config = {
    direction_keys = { "h", "j", "k", "l" },
    modifiers = {
      move = "CTRL",
      resize = "LEADER",
    },
  }

  return smart_splits.apply_to_config(config, smart_splits_config)
end
