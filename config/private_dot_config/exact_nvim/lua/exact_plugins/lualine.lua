---@type LazyPluginSpec
return {
  "nvim-lualine/lualine.nvim",
  -- opts_extend = { "extensions" },
  opts = function(_, opts)
    -- Options
    opts.options = opts.options or {}
    opts.options.theme = core.config.ui.theme
    opts.options.component_separators = { left = "", right = "" }
    opts.options.section_separators = { left = "", right = "" }

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
