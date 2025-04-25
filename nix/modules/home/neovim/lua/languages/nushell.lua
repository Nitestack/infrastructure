-- ╭─────────────────────────────────────────────────────────╮
-- │ Nushell                                                 │
-- ╰─────────────────────────────────────────────────────────╯
return utils.plugin.get_language_spec({
  formatter = {
    formatters_by_ft = {
      ["nu"] = { "nufmt" },
    },
  },
  plugins = {
    { import = "lazyvim.plugins.extras.lang.nushell" },
  },
})
