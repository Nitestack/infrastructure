---@diagnostic disable: need-check-nil

local function set_diagnostic_count(result, icon, count, fg)
  if count ~= 0 then
    table.insert(result, { text = " " .. icon .. " " .. count, fg = fg })
  end
end

---@type LazyPluginSpec
return {
  "akinsho/bufferline.nvim",
  ---@param opts bufferline.UserConfig
  opts = function(_, opts)
    local C = require("catppuccin.palettes").get_palette()
    local selected_color = C.surface0

    opts.highlights = require("catppuccin.groups.integrations.bufferline").get({
      ---@type CtpHighlightArgs[]
      styles = { "bold" },
      custom = {
        all = {
          buffer_selected = { bg = selected_color },
          tab_selected = { bg = selected_color },
          tab_separator_selected = { bg = selected_color },
          duplicate_selected = { bg = selected_color },
          indicator_selected = { bg = selected_color },
          separator_selected = { bg = selected_color },
          close_button_selected = { bg = selected_color },
          numbers_selected = { bg = selected_color },
          error_selected = { bg = selected_color },
          error_diagnostic_selected = { bg = selected_color },
          warning_selected = { bg = selected_color },
          warning_diagnostic_selected = { bg = selected_color },
          info_selected = { bg = selected_color },
          info_diagnostic_selected = { bg = selected_color },
          hint_selected = { bg = selected_color },
          hint_diagnostic_selected = { bg = selected_color },
          diagnostic_selected = { bg = selected_color },
          modified_selected = { bg = selected_color },
          pick_selected = { bg = selected_color },
        },
      },
    })
    -- Icons
    opts.options.indicator = opts.options.indicator or {}
    opts.options.indicator.icon = core.icons.ui.BoldLineLeft
    opts.options.buffer_close_icon = core.icons.ui.Close
    opts.options.close_icon = core.icons.ui.BoldClose
    opts.options.modified_icon = core.icons.ui.Circle
    opts.options.left_trunc_marker = core.icons.ui.ArrowCircleLeft
    opts.options.right_trunc_marker = core.icons.ui.ArrowCircleRight
    -- Other options
    opts.options.mode = "tabs"
    opts.options.diagnostics_update_in_insert = false
    opts.options.show_close_icon = false
    opts.options.always_show_bufferline = true
    opts.options.right_mouse_command = "vert sbuffer %d"
    opts.options.diagnostics_indicator = function(count)
      return "(" .. count .. ")"
    end
    -- Styling
    opts.options.style_preset = {
      require("bufferline").style_preset.no_italic,
      require("bufferline").style_preset.minimal,
    }
    opts.options.separator_style = { "", "" }
  end,
}
