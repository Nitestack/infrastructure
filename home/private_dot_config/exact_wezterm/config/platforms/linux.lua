local M = {}

---@param config Config
function M.setup(config)
  config.integrated_title_button_style = "Gnome"
  config.bypass_mouse_reporting_modifiers = "CTRL"
  config.quote_dropped_files = "POSIX"

  config.show_tabs_in_tab_bar = false
  config.show_new_tab_button_in_tab_bar = false

  config.tab_bar_style = {}
end

return M
