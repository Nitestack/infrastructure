return utils.plugin.get_language_spec({
  treesitter = "typst",
  mason = { "typst-lsp", "typstfmt" },
  lsp = {
    servers = {
      typst_lsp = {},
    },
  },
  formatter = {
    formatters_by_ft = {
      ["typst"] = { "typstfmt" },
    },
  },
  plugins = {
    {
      "kaarmu/typst.vim",
      ft = "typst",
    },
  },
})
