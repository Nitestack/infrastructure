return utils.plugin.get_language_spec({
  treesitter = "typst",
  mason = "typst-lsp",
  lsp = {
    servers = {
      typst_lsp = {},
    },
  },
  plugins = {
    {
      "kaarmu/typst.vim",
      ft = "typst",
    },
  },
})
