-- ╭─────────────────────────────────────────────────────────╮
-- │ HTML                                                    │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
  treesitter = {
    "html",
  },
  lsp = {
    servers = {
      html = {},
      emmet_language_server = {},
    },
  },
  formatter = {
    formatters_by_ft = {
      ["html"] = { "prettierd" },
    },
  },
})
