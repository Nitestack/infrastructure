---@module "lazy"
---@type LazyPluginSpec
return {
  "nvimdev/dashboard-nvim",
  opts = function(_, opts)
    local logo = string.rep("\n", 8) .. core.config.ui.logo .. "\n\n"
    opts.config = opts.config or {}
    opts.config.header = vim.split(logo, "\n")
  end,
}
