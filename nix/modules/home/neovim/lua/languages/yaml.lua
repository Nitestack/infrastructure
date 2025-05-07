-- ╭─────────────────────────────────────────────────────────╮
-- │ YAML                                                    │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
  formatter = {
    formatters_by_ft = {
      ["yaml"] = { "prettierd" },
    },
  },
  plugins = {
    { import = "lazyvim.plugins.extras.lang.yaml" },
  },
})
