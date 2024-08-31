-- ╭─────────────────────────────────────────────────────────╮
-- │ TOML                                                    │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
  treesitter = "toml",
  plugins = {
    { import = "lazyvim.plugins.extras.lang.toml" },
  },
})
