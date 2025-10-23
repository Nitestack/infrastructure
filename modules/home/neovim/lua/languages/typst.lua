-- ╭─────────────────────────────────────────────────────────╮
-- │ Typst                                                   │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
  lsp = {
    servers = {
      tinymist = {
        offset_encoding = "utf-8",
        settings = {
          exportPdf = "onType",
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
    { import = "lazyvim.plugins.extras.lang.typst" },
  },
})
