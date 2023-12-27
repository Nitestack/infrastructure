return utils.lsp.load_language({
  treesitter = {
    "json",
    "jsonc",
  },
  mason = {
    "prettierd",
    "jsonlint",
  },
  plugins = {
    { import = "lazyvim.plugins.extras.lang.json" },
  },
  linter = {
    linters_by_ft = {
      ["json"] = { "jsonlint" },
      ["jsonc"] = { "jsonlint" },
    },
  },
  formatter = {
    formatters_by_ft = {
      ["json"] = { "prettierd" },
      ["jsonc"] = { "prettierd" },
    },
  },
})
