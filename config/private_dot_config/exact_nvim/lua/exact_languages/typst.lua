-- ╭─────────────────────────────────────────────────────────╮
-- │ Typst                                                   │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
  treesitter = "typst",
  mason = { "tinymist", "typstfmt" },
  lsp = {
    servers = {
      tinymist = {
        offset_encoding = "utf-8",
        settings = {
          exportPdf = "onSave",
        },
      },
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
