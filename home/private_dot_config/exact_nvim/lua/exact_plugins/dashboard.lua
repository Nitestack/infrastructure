---@type LazyPluginSpec
return {
  "nvimdev/dashboard-nvim",
  opts = function(_, opts)
    local logo = core.config.ui.logo

    logo = string.rep("\n", 8) .. logo .. "\n\n"
    opts.config = opts.config or {}
    opts.config.header = vim.split(logo, "\n")
  end,
}
