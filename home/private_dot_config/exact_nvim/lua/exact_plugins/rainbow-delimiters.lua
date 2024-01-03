---@type LazyPluginSpec
return {
  "HiPhish/rainbow-delimiters.nvim",
  event = "LazyFile",
  ---@type rainbow_delimiters.config
  opts = {
    query = {
      javascript = "rainbow-delimiters-react",
      tsx = "rainbow-parens",
      typescript = "rainbow-parens",
    },
  },
  config = function(_, opts)
    require("rainbow-delimiters.setup").setup(opts)
  end,
}
