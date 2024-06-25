---@type LazyPluginSpec
return {
  "nvim-lualine/lualine.nvim",
  -- opts_extend = { "extensions" },
  opts = function(_, opts)
    local lualine_components = utils.lualine

    -- Options
    opts.options = opts.options or {}
    opts.options.theme = core.config.ui.theme
    opts.options.component_separators = { left = "", right = "" }
    opts.options.section_separators = { left = "", right = "" }

    -- Sections
    opts.sections = opts.sections or {}
    opts.sections.lualine_a = {
      lualine_components.mode,
    }
    opts.sections.lualine_b = {
      lualine_components.git_branch,
      lualine_components.diff,
    }
    opts.sections.lualine_c = {
      {
        "filetype",
        icon_only = true,
        padding = { left = 1, right = 0 },
      },
      {
        "filename",
        padding = { left = 0, right = 1 },
        color = { gui = "bold" },
      },
    }
    opts.sections.lualine_x = {
      lualine_components.command_status,
      lualine_components.mode_status,
      lualine_components.debug_status,
      lualine_components.lazy_updates,
      lualine_components.diagnostics,
      lualine_components.lsp_status,
      lualine_components.shift_width,
    }
    opts.sections.lualine_y = {
      lualine_components.location,
    }
    opts.sections.lualine_z = {
      lualine_components.progress,
    }

    -- Extensions
    opts.extensions = vim.list_extend(opts.extensions or {}, {
      "lazy",
      "man",
      "quickfix",
    })
  end,
  config = function(_, opts)
    opts.extensions = LazyVim.dedup(opts.extensions)
    require("lualine").setup(opts)
  end,
}
