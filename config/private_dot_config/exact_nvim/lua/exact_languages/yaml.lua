-- ╭─────────────────────────────────────────────────────────╮
-- │ YAML                                                    │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
  mason = {
    "prettierd",
    "prettier",
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
