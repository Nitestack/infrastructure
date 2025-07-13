-- ╭─────────────────────────────────────────────────────────╮
-- │ Appearance Config                                       │
-- ╰─────────────────────────────────────────────────────────╯

local M = {}

---@param config Config
function M.setup(config)
  -- ── Font ────────────────────────────────────────────────────────────
  config.font_size = 14
  config.command_palette_font_size = 14
  config.line_height = 1.5

  -- ── Colors ──────────────────────────────────────────────────────────
  config.color_scheme = "Catppuccin Mocha"

  config.underline_thickness = 3
  config.cursor_thickness = 4
  config.underline_position = -6

  -- -- ── Window ──────────────────────────────────────────────────────────
  config.window_padding = {
    top = 0,
    bottom = 0,
    left = 0,
    right = 0,
  }
  config.enable_scroll_bar = false
end

return M
