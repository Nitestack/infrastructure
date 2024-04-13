--------------------------------------------------------------------------------
--  HTML
--------------------------------------------------------------------------------
return core.load_language({
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
