-- ╭─────────────────────────────────────────────────────────╮
-- │ Windows Config                                          │
-- ╰─────────────────────────────────────────────────────────╯

local M = {}

---@module "wezterm"
---@param config Config
function M.setup(config)
  -- ── Settings ────────────────────────────────────────────────────────
  config.integrated_title_button_style = "Windows"
  ---@diagnostic disable-next-line: assign-type-mismatch
  config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
  config.bypass_mouse_reporting_modifiers = "CTRL"

  -- hide tabs
  config.show_tabs_in_tab_bar = false
  config.show_new_tab_button_in_tab_bar = false

  -- set WSL to be the default program
  config.default_prog = { [[C:\Program Files\WSL\wsl.exe]], "--", "nu", "-e", "cd" }
end

return M
