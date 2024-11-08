return utils.plugin.get_language_spec({
  treesitter = "typst",
  mason = { "tinymist", "typstfmt" },
  lsp = {
    servers = {
      tinymist = {
        settings = {
          exportPdf = "onSave",
          formatterMode = "typstfmt",
        },
      },
    },
  },
  plugins = {
    {
      "kaarmu/typst.vim",
      ft = "typst",
    },
  },
})
