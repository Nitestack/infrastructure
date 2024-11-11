return utils.plugin.with_extensions({
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame_formatter = "<author>, <author_time:-%d.%m.%Y> - <summary>",
      preview_config = {
        border = core.config.ui.transparent.floats and "rounded" or "none",
      },
    },
  },
}, {
  catppuccin = {
    gitsigns = true,
  },
})
