---@type LazyPluginSpec
return {
  "catppuccin/nvim",
  name = "catppuccin",
  ---@module "catppuccin"
  ---@type CatppuccinOptions
  opts = {
    transparent_background = true,
    flavour = "mocha",
    term_colors = true,
    styles = {
      comments = { "italic" },
      conditionals = { "italic" },
      loops = { "italic" },
      functions = {},
      keywords = {},
      strings = {},
      variables = {},
      numbers = {},
      booleans = {},
      properties = {},
      types = {},
      operators = {},
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
      markdown = true,
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
      semantic_tokens = true,
    },
  },
}
