return utils.plugin.get_language_spec({
  treesitter = "typst",
  mason = { "tinymist", "typstfmt" },
  lsp = {
    servers = {
      tinymist = {},
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
