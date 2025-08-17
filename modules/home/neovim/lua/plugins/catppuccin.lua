---@type LazyPluginSpec
return {
  "catppuccin/nvim",
  name = "catppuccin",
  ---@module "catppuccin"
  ---@type CatppuccinOptions
  opts = {
    flavour = "mocha",
    term_colors = true,
    float = {
      solid = true,
    },
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
    integrations = {
      flash = true,
      gitsigns = true,
      grug_far = true,
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
