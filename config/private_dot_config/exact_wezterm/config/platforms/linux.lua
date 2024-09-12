-- ╭─────────────────────────────────────────────────────────╮
-- │ LINUX CONFIG                                            │
-- ╰─────────────────────────────────────────────────────────╯

local M = {}

---@module "wezterm"
---@param config Config
function M.setup(config)
  -- ── Settings ────────────────────────────────────────────────────────
  config.integrated_title_button_style = "Gnome"
  config.bypass_mouse_reporting_modifiers = "CTRL"

  config.enable_tab_bar = false
  -- NOTE: Hyprland Issue
  config.enable_wayland = false
  -- NOTE: NixOS Issue
  config.front_end = "WebGpu"
end

return M
