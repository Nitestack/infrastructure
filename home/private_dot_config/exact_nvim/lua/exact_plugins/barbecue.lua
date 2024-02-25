local use_navic = false
local show_modified = true

---@type LazyPluginSpec
return {
  "utilyre/barbecue.nvim",
  name = "barbecue",
  version = "*",
  event = "LazyFile",
  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons",
  },
  ---@type barbecue.Config
  opts = {
    theme = core.config.ui.theme,
    -- prevent barbecue from updating itself automatically when in performance mode
    create_autocmd = not core.config.performance_mode,
    show_modified = show_modified,
    symbols = {
      modified = core.icons.ui.Circle,
      elipsis = core.icons.ui.Ellipsis,
    },
    -- Disable navic completely
    attach_navic = use_navic,
    show_navic = use_navic,
  },
  config = function(_, opts)
    require("barbecue").setup(opts)

    if core.config.performance_mode then
      local events = {
        "WinResized",
        "BufWinEnter",
      }

      if show_modified then
        table.insert(events, "BufModifiedSet")
      end

      if use_navic then
        table.insert(events, "CursorHold")
        table.insert(events, "InsertLeave")
      end

      core.auto_cmds({
        {
          events,
          {
            group = "barbecue.updater",
            callback = function()
              require("barbecue.ui").update()
            end,
          },
        },
      })
    end
  end,
}
