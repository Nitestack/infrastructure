---@type LazyPluginSpec
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function()
    local lualine_components = require("utils.lualine")

    -- PERF: we don't need this lualine require madness 🤷
    local lualine_require = require("lualine_require")
    lualine_require.require = require

    return {
      options = {
        theme = core.config.ui.theme,
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = { "dashboard" },
        },
      },
      sections = {
        lualine_a = {
          lualine_components.mode,
        },
        lualine_b = {
          lualine_components.git_branch,
          lualine_components.diff,
        },
        lualine_c = {
          {
            "filetype",
            icon_only = true,
            padding = { left = 1, right = 0 },
          },
          {
            "filename",
            color = { gui = "bold" },
          },
        },

        lualine_x = {
          lualine_components.command_status,
          lualine_components.mode_status,
          lualine_components.debug_status,
          lualine_components.lazy_updates,
          lualine_components.diagnostics,
          lualine_components.lsp_status,
          lualine_components.shift_width,
        },
        lualine_y = {
          lualine_components.location,
        },
        lualine_z = {
          lualine_components.progress,
        },
      },
      extensions = {
        -- don't include mason in lualine
        -- lualine is loaded via the "VeryLazy" event and loading mason on startup is heavy
        "lazy",
        "man",
        "mason",
        "quickfix",
        "toggleterm",
        "trouble",
      },
    }
  end,
}
