-- ╭─────────────────────────────────────────────────────────╮
-- │ PLATFORM CONFIG                                         │
-- ╰─────────────────────────────────────────────────────────╯

---@type Wezterm
---@diagnostic disable: assign-type-mismatch
local wezterm = require("wezterm")

local M = {}

---@module "wezterm"
---@param config Config
function M.setup(config)
  -- ── Tabs ────────────────────────────────────────────────────────────
  config.enable_tab_bar = false
  -- ── macOS ───────────────────────────────────────────────────────────
  if string.find(wezterm.target_triple, "apple") ~= nil then
    require("config.platforms.macos").setup(config)
  end
  -- ── Linux ───────────────────────────────────────────────────────────
  if string.find(wezterm.target_triple, "linux") ~= nil then
    require("config.platforms.linux").setup(config)
  end
end

return M
