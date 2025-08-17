-- ╭─────────────────────────────────────────────────────────╮
-- │ Typst                                                   │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
  treesitter = "typst",
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
  formatter = {
    formatters_by_ft = {
      ["bib"] = { "bibtex-tidy" },
    },
  },
  plugins = {
    {
      "kaarmu/typst.vim",
      ft = "typst",
    },
  },
})
