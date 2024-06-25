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
      "lukas-reineke/headlines.nvim",
      opts = function(_, opts)
        for filetype, _ in pairs(opts) do
          opts[filetype].fat_headline_lower_string = "▀"
        end
      end,
    },
    {
      "iamcco/markdown-preview.nvim",
      build = "cd app && yarn install",
      init = function()
        vim.g.mkdp_filetypes = { "markdown" }
      end,
    },
  }, {
    catppuccin = {
      headlines = true,
    },
  }),
})
