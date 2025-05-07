-- ╭─────────────────────────────────────────────────────────╮
-- │ JSON                                                    │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
  formatter = {
    formatters_by_ft = {
      ["json"] = { "prettierd" },
      ["jsonc"] = { "prettierd" },
    },
  },
  plugins = {
    { import = "lazyvim.plugins.extras.lang.json" },
  },
})
