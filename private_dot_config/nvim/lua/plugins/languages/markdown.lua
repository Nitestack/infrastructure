return utils.lsp.load_language({
  treesitter = {
    "markdown",
    "markdown_inline",
  },
  plugins = {
    { import = "lazyvim.plugins.extras.lang.markdown" },
  },
  formatter = {
    formatters_by_ft = {
      ["markdown"] = { "prettierd" },
      ["markdown.mdx"] = { "prettierd" },
    },
  },
})
