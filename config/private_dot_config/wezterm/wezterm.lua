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

return config
