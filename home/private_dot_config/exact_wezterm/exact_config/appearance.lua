local wezterm = require("wezterm")

return {
  -- Colors
  color_scheme = "Catppuccin Mocha",

  -- Font
  font = wezterm.font("MonaspiceNe Nerd Font", { weight = "Bold" }),
  font_size = 18.0,
  line_height = 1.2,

  animation_fps = 144,
  max_fps = 144,

  -- Cursor
  default_cursor_style = "BlinkingBlock",
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",
  cursor_blink_rate = 700,

  -- Window
  window_decorations = "INTEGRATED_BUTTONS|RESIZE",
  window_padding = {
    top = 4,
    bottom = 4,
    left = 4,
    right = 4,
  },

  -- Tab Bar
  show_tab_index_in_tab_bar = false,
  switch_to_last_active_tab_when_closing_tab = true,
  tab_max_width = 25,
  window_frame = {
    font = wezterm.font("MonaspiceNe Nerd Font", { weight = "Bold" }),
  },
}
