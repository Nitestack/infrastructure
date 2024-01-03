return utils.lsp.load_language({
  mason = {
    "bash-language-server",
    "shellcheck",
    "shfmt",
  },
  lsp = {
    servers = {
      bashls = {},
    },
  },
  linter = {
    linters_by_ft = {
      ["sh"] = { "shellcheck" },
    },
  },
  formatter = {
    formatters_by_ft = {
      ["sh"] = { "shfmt" },
    },
  },
  treesitter = { "bash" },
})
