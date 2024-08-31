-- ╭─────────────────────────────────────────────────────────╮
-- │ Markdown                                                │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
  mason = {
    "prettierd",
    "prettier",
  },
  plugins = utils.plugin.with_extensions({
    { import = "lazyvim.plugins.extras.lang.markdown" },
  }, {
    catppuccin = {
      render_markdown = true,
    },
  }),
})
