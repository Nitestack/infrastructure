return utils.lsp.load_language({
  mason = {
    "css-lsp",
    "cssmodules-language-server",
    "stylelint",
    "prettierd",
  },
  treesitter = {
    "css",
    "scss",
  },
  lsp = {
    servers = {
      cssls = {},
      cssmodules_ls = {},
    },
  },
  linter = {
    linters_by_ft = {
      ["css"] = { "stylelint" },
      ["scss"] = { "stylelint" },
      ["sass"] = { "stylelint" },
    },
  },
  formatter = {
    formatters_by_ft = {
      ["css"] = { "prettierd" },
      ["scss"] = { "prettierd" },
      ["sass"] = { "prettierd" },
    },
  },
  plugins = {
    { import = "lazyvim.plugins.extras.lang.tailwind" },
  },
})
