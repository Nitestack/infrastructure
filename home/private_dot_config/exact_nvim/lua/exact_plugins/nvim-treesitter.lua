---@type LazyPluginSpec
return {
  "nvim-treesitter/nvim-treesitter",
  event = function()
    return {
      "LazyFile",
    }
  end,
  opts = function(_, opts)
    if type(opts.ensure_installed) == "table" then
      vim.list_extend(opts.ensure_installed, core.config.plugins.treesitter)
    end
  end,
}
