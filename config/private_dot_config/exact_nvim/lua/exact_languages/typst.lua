return utils.plugin.get_language_spec({
  treesitter = "typst",
  mason = { "tinymist", "typstfmt" },
  lsp = {
    servers = {
      tinymist = {
        single_file_support = true,
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
