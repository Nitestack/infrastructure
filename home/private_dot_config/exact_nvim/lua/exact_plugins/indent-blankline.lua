---@type LazyPluginSpec
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = "LazyFile",
  opts = {
    indent = {
      char = core.icons.ui.LineLeft,
      tab_char = core.icons.ui.LineLeft,
    },
    scope = {
      enabled = false,
    },
    exclude = {
      filetypes = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
        "noice",
      },
    },
  },
}
