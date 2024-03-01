---@type LazyPluginSpec
return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  enabled = function()
    return core.config.ui.theme == "catppuccin"
  end,
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
      local treesitter_context_bg = C.base

      ---@type { [string]: CtpHighlight}
      return {
        MiniIndentscopeSymbol = {
          fg = "#737aa2",
        },
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
      }
    end,
    integrations = {
      barbecue = {
        dim_dirname = true,
        bold_basename = true,
        dim_context = true,
        alt_background = false,
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
  config = function(_, opts)
    require("catppuccin").setup(opts)

    vim.cmd.colorscheme("catppuccin")
  end,
}
