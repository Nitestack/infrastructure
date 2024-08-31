-- ╭─────────────────────────────────────────────────────────╮
-- │ JSON                                                    │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
  mason = {
    "prettierd",
    "prettier",
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
