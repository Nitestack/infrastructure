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
      functions = { "italic" },
      keywords = { "italic" },
    },
    custom_highlights = function(C)
      local U = require("catppuccin.utils.colors")
      ---@type { [string]: CtpHighlight}
      local highlights = {
        MiniIndentscopeSymbol = {
          fg = "#737aa2",
        },
      }

      if not core.config.ui.transparent.floats then
        ---@type { [string]: CtpHighlight}
        local float_highlights = {
          NormalFloat = { bg = C.mantle },
          Pmenu = { bg = U.darken(C.surface0, 0.8, C.crust) },

          NeoTreeNormal = { bg = C.mantle },
          NeoTreeNormalNC = { bg = C.mantle },
          NeoTreeVertSplit = { bg = C.base },

          DiagnosticVirtualTextError = { bg = U.darken(C.red, 0.095, C.base) },
          DiagnosticVirtualTextWarn = { bg = U.darken(C.yellow, 0.095, C.base) },
          DiagnosticVirtualTextInfo = { bg = U.darken(C.sky, 0.095, C.base) },
          DiagnosticVirtualTextHint = { bg = U.darken(C.teal, 0.095, C.base) },

          TelescopeBorder = { fg = C.mantle, bg = C.mantle },
          TelescopeNormal = { bg = C.mantle },
          TelescopePromptBorder = { fg = C.surface0, bg = C.surface0 },
          TelescopePromptNormal = { bg = C.surface0 },
          TelescopePromptPrefix = { bg = C.surface0 },
          TelescopePreviewTitle = { fg = C.base, bg = C.green },
          TelescopePromptTitle = { fg = C.base, bg = C.red },
          TelescopeResultsTitle = { fg = C.mantle, bg = C.lavender },
          TelescopeSelection = { fg = C.text, bg = C.surface0 },

          TreesitterContext = { bg = C.none, fg = C.text, link = "" },
        }
        highlights = vim.tbl_deep_extend("force", highlights, float_highlights) --[[@as { [string]: CtpHighlight}]]
      end

      return highlights
    end,
    integrations = {
      barbecue = {
        bold_basename = true,
        dim_context = true,
      },
      dashboard = true,
      flash = true,
      gitsigns = true,
      harpoon = true,
      headlines = true,
      indent_blankline = { enabled = true },
      markdown = true,
      mason = true,
      mini = { enabled = true },
      neotree = true,
      noice = true,
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
      navic = {
        enabled = true,
      },
      notify = true,
      treesitter_context = true,
      treesitter = true,
      rainbow_delimiters = true,
      telescope = {
        enabled = true,
        style = "nvchad",
      },
      lsp_trouble = true,
      illuminate = true,
      which_key = true,
    },
  },
}
