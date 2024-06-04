---@module "lazy"
---@type LazyPluginSpec
return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = {
      add = { text = core.icons.ui.BoldLineLeft },
      change = { text = core.icons.ui.BoldLineLeft },
      delete = { text = core.icons.ui.Triangle },
      topdelete = { text = core.icons.ui.Triangle },
      changedelete = { text = core.icons.ui.BoldLineLeft },
      untracked = { text = core.icons.ui.BoldLineLeft },
    },
    current_line_blame_formatter = "<author>, <author_time:-%d.%m.%Y> - <summary>",
    preview_config = {
      border = core.config.ui.transparent.floats and "rounded" or "none",
    },
  },
}
