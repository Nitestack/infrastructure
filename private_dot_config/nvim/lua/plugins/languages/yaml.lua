return utils.lsp.load_language({
  treesitter = {
    "yaml",
  },
  mason = {
    "prettierd",
    "yamllint",
  },
  plugins = {
    { import = "lazyvim.plugins.extras.lang.yaml" },
  },
  linter = {
    linters_by_ft = {
      ["yaml"] = { "yamllint" },
    },
  },
  formatter = {
    formatters_by_ft = {
      ["yaml"] = { "prettierd" },
    },
  },
})
