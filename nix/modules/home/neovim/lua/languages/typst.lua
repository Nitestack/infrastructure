-- ╭─────────────────────────────────────────────────────────╮
-- │ Typst                                                   │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
  treesitter = "typst",
  mason = "tinymist",
  lsp = {
    servers = {
      tinymist = {
        offset_encoding = "utf-8",
        settings = {
          exportPdf = "onType",
          formatterMode = "typstyle",
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
