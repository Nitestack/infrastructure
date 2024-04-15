--------------------------------------------------------------------------------
--  HTML
--------------------------------------------------------------------------------
return utils.plugin.get_language_spec({
  treesitter = {
    "html",
  },
  mason = {
    "html-lsp",
    "prettierd",
    "prettier",
  },
  lsp = {
    servers = {
      html = {},
    },
  },
  formatter = {
    formatters_by_ft = {
      ["html"] = { "prettierd", "prettier" },
    },
  },
})
