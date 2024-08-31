-- ╭─────────────────────────────────────────────────────────╮
-- │ MACOS CONFIG                                            │
-- ╰─────────────────────────────────────────────────────────╯

local M = {}

---@module "wezterm"
---@param config Config
function M.setup(config)
  -- ── Settings ────────────────────────────────────────────────────────
  config.integrated_title_button_style = "MacOsNative"
  config.bypass_mouse_reporting_modifiers = "SUPER"
end

return M
