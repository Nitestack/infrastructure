return utils.lsp.load_language({
  treesitter = {
    "markdown",
    "markdown_inline",
  },
  formatter = {
    formatters_by_ft = {
      ["markdown"] = { "prettierd" },
      ["markdown.mdx"] = { "prettierd" },
    },
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
    {
      "iamcco/markdown-preview.nvim",
      build = "cd app && yarn install",
      init = function()
        vim.g.mkdp_filetypes = { "markdown" }
      end,
    },
  },
})
