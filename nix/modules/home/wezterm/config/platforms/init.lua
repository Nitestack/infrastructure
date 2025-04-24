-- ╭─────────────────────────────────────────────────────────╮
-- │ Platform Config                                         │
-- ╰─────────────────────────────────────────────────────────╯

---@type Wezterm
---@diagnostic disable: assign-type-mismatch
local wezterm = require("wezterm")

local M = {}

---@module "wezterm"
---@param config Config
function M.setup(config)
  -- ── Unix ────────────────────────────────────────────────────────────
  config.enable_tab_bar = false
  -- ── Linux ───────────────────────────────────────────────────────────
  if string.find(wezterm.target_triple, "linux") ~= nil then
    require("config.platforms.linux").setup(config)
  end
  -- ── macOS ───────────────────────────────────────────────────────────
  if string.find(wezterm.target_triple, "apple") ~= nil then
    require("config.platforms.macos").setup(config)
  end
end

return M
