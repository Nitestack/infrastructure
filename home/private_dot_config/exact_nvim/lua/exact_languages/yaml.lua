-- ╭─────────────────────────────────────────────────────────╮
-- │ YAML                                                    │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
  mason = {
    "prettierd",
    "prettier",
    "yamllint",
  },
  linter = {
    linters_by_ft = {
      ["yaml"] = { "yamllint" },
    },
  },
  formatter = {
    formatters_by_ft = {
      ["yaml"] = { "prettierd", "prettier" },
    },
  },
  plugins = {
    { import = "lazyvim.plugins.extras.lang.yaml" },
  },
})
