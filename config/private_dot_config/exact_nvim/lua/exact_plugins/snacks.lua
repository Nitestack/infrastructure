---@type LazyPluginSpec
return {
  "folke/snacks.nvim",
  ---@module "snacks"
  ---@param opts snacks.Config
  opts = function(_, opts)
    -- Default window options
    opts.win = opts.win or {}
    opts.win.border = core.config.ui.transparent.floats and "rounded" or "none"

    -- Terminal
    opts.terminal = opts.terminal or {}
    opts.terminal.win = opts.terminal.win or {}
    opts.terminal.win.style = "float"
    opts.terminal.win.wo = opts.terminal.win.wo or {}
    opts.terminal.win.width = core.config.ui.width
    opts.terminal.win.height = core.config.ui.height

    -- Notifier
    opts.notifier = opts.notifier or {}
    opts.notifier.icons = opts.notifier.icons or {}
    for name, icon in pairs(core.icons.diagnostics) do
      opts.notifier.icons[name:lower()] = icon
    end
  end,
}
