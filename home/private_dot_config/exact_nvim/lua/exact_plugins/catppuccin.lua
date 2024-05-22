---@type LazyPluginSpec
return {
  "catppuccin/nvim",
  name = "catppuccin",
  ---@type CatppuccinOptions
  opts = {
    transparent_background = core.config.ui.transparent.enabled,
    flavour = "mocha",
    styles = {
      loops = { "italic" },
      booleans = { "italic" },
      comments = { "italic" },
      conditionals = { "italic" },
      keywords = { "italic" },
    },
    custom_highlights = function(C)
      local treesitter_context_bg = C.crust
      local U = require("catppuccin.utils.colors")

      ---@type { [string]: CtpHighlight}
      return {
        -- Treesitter context
        TreesitterContext = {
          bg = treesitter_context_bg,
        },
        TreesitterContextLineNumber = {
          fg = C.surface1,
          bg = treesitter_context_bg,
        },
        TreesitterContextBottom = {
          style = {},
        },
        -- Diagnostics
        DiagnosticVirtualTextError = { bg = U.darken(C.red, 0.095, C.base) },
        DiagnosticVirtualTextWarn = { bg = U.darken(C.yellow, 0.095, C.base) },
        DiagnosticVirtualTextInfo = { bg = U.darken(C.sky, 0.095, C.base) },
        DiagnosticVirtualTextHint = { bg = U.darken(C.teal, 0.095, C.base) },
      }
    end,
    integrations = {
      dashboard = true,
      gitsigns = true,
      headlines = true,
      indent_blankline = { enabled = true },
      markdown = true,
      mason = true,
      mini = { enabled = true, indentscope_color = "overlay0" },
      neotest = true,
      noice = true,
      dap = true,
      dap_ui = true,
      cmp = true,
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = { "bold" },
          hints = { "bold" },
          warnings = { "bold" },
          information = { "bold" },
        },
        underlines = {
          errors = { "undercurl" },
          hints = { "undercurl" },
          warnings = { "undercurl" },
          information = { "undercurl" },
        },
        inlay_hints = { background = true },
      },
      notify = true,
      semantic_tokens = true,
      treesitter_context = true,
      treesitter = true,
      telescope = {
        enabled = true,
        style = "nvchad",
      },
      lsp_trouble = true,
      which_key = true,
    },
  },
}
