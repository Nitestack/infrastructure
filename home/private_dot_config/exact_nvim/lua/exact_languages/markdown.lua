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
    {
      "iamcco/markdown-preview.nvim",
      build = "cd app && yarn install",
      init = function()
        vim.g.mkdp_filetypes = { "markdown" }
      end,
    },
  }, {
    catppuccin = {
      render_markdown = true,
    },
  }),
})
