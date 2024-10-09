-- ╭─────────────────────────────────────────────────────────╮
-- │ UNIX CONFIG                                             │
-- ╰─────────────────────────────────────────────────────────╯

local colors = require("colors")

local M = {}

---@module "wezterm"
---@param config Config
function M.setup(config)
  -- ── Tabs ────────────────────────────────────────────────────────────
  config.enable_tab_bar = false
  config.window_frame = {
    active_titlebar_bg = colors.base,
    inactive_titlebar_bg = colors.base,
  }
end

return M
