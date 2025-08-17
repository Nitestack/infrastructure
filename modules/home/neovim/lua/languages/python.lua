-- ╭─────────────────────────────────────────────────────────╮
-- │ Python                                                  │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
  treesitter = "python",
  plugins = {
    { import = "lazyvim.plugins.extras.formatting.black" },
    { import = "lazyvim.plugins.extras.lang.python" },
  },
})
