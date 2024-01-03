return utils.lsp.load_language({
  treesitter = {
    "markdown",
    "markdown_inline",
  },
  plugins = {
    { import = "lazyvim.plugins.extras.lang.markdown" },
    {
      "lukas-reineke/headlines.nvim",
      dependencies = "nvim-treesitter/nvim-treesitter",
      opts = {
        markdown = {
          fat_headline_lower_string = "▀",
        },
      },
    },
  },
  formatter = {
    formatters_by_ft = {
      ["markdown"] = { "prettierd" },
      ["markdown.mdx"] = { "prettierd" },
    },
  },
})
