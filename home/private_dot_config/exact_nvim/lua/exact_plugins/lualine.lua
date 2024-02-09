---@type LazyPluginSpec
return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local icons = require("lazyvim.config").icons

    -- Options
    opts.options = opts.options or {}
    opts.options.theme = core.config.ui.theme
    opts.options.component_separators = { left = "", right = "" }
    opts.options.section_separators = { left = "", right = "" }
    opts.options.disabled_filetypes = opts.options.disabled_filetypes or {}
    opts.options.disabled_filetypes.statusline = {}

    -- Sections
    opts.sections = opts.sections or {}
    opts.sections.lualine_b = {
      {
        "b:gitsigns_head",
        icon = core.icons.git.Branch,
        color = { gui = "bold" },
      },
    }
    opts.sections.lualine_c = {
      {
        "diagnostics",
        symbols = {
          error = icons.diagnostics.Error,
          warn = icons.diagnostics.Warn,
          info = icons.diagnostics.Info,
          hint = icons.diagnostics.Hint,
        },
      },
    }
    opts.sections.lualine_x = opts.sections.lualine_x or {}
    vim.list_extend(opts.sections.lualine_x, {
      {
        function()
          local shiftwidth = vim.api.nvim_get_option_value("shiftwidth", { buf = 0 })
          return core.icons.ui.Tab .. " " .. shiftwidth
        end,
        padding = 1,
      },
      "filetype",
    })
    opts.sections.lualine_y = opts.sections.lualine_y or {}

    -- Extensions
    opts.extensions = vim.list_extend(opts.extensions or {}, {
      -- don't include mason in lualine
      -- lualine is loaded via the "VeryLazy" event and loading mason on startup is heavy
      "lazy",
      "man",
      "neo-tree",
      "quickfix",
      "toggleterm",
      "trouble",
    })
  end,
}
