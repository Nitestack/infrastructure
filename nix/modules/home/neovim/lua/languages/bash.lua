-- ╭─────────────────────────────────────────────────────────╮
-- │ Bash                                                    │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
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
