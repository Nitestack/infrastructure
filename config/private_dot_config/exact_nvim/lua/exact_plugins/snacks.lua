---@type LazyPluginSpec
return {
  "folke/snacks.nvim",
  ---@module "snacks"
  ---@param opts snacks.Config
  opts = function(_, opts)
    -- Default window options
    opts.win = opts.win or {}
    opts.win.border = "rounded"

    -- Terminal
    opts.terminal = opts.terminal or {}
    opts.terminal.win = opts.terminal.win or {}
    opts.terminal.win.style = "float"
  end,
}
