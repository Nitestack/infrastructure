-- ╭─────────────────────────────────────────────────────────╮
-- │ Linux Config                                            │
-- ╰─────────────────────────────────────────────────────────╯

local M = {}

---@module "wezterm"
---@param config Config
function M.setup(config)
  -- ── Settings ────────────────────────────────────────────────────────
  config.integrated_title_buttons = { "Close" }
  config.integrated_title_button_style = "Gnome"
  config.bypass_mouse_reporting_modifiers = "CTRL"

  -- recommended for tiling window managers
  config.adjust_window_size_when_changing_font_size = false
end

return M
