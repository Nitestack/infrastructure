--------------------------------------------------------------------------------
--  JSON
--------------------------------------------------------------------------------
return utils.plugin.get_language_spec({
  mason = {
    "prettierd",
    "prettier",
    "jsonlint",
    "json-lsp",
  },
  linter = {
    linters_by_ft = {
      ["json"] = { "jsonlint" },
      ["jsonc"] = { "jsonlint" },
    },
  },
  formatter = {
    formatters_by_ft = {
      ["json"] = { "prettierd", "prettier" },
      ["jsonc"] = { "prettierd", "prettier" },
    },
  },
  plugins = {
    { import = "lazyvim.plugins.extras.lang.json" },
  },
})
