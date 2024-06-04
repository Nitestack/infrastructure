local M = {}

---@param config Config
function M.setup(config)
  config.integrated_title_button_style = "MacOsNative"
  config.bypass_mouse_reporting_modifiers = "SUPER"
  config.quote_dropped_files = "Posix"
end

return M
