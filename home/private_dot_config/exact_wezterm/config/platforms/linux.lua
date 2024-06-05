local M = {}

---@module "wezterm"
---@param config Config
function M.setup(config)
  -- Settings
  config.integrated_title_button_style = "Gnome"
  config.bypass_mouse_reporting_modifiers = "CTRL"
end

return M
