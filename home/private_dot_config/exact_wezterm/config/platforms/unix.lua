local colors = require("colors")

local M = {}

---@param config Config
function M.setup(config)
  -- Settings
  ---@diagnostic disable-next-line: assign-type-mismatch
  config.quote_dropped_files = "Posix"

  -- Disable tab bar because tmux is used in UNIX-based systems
  config.show_tabs_in_tab_bar = false
  config.show_new_tab_button_in_tab_bar = false
  config.window_frame = {
    active_titlebar_bg = colors.base,
    inactive_titlebar_bg = colors.base,
  }
end

return M
