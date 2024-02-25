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
    create_autocmd = false, -- prevent barbecue from updating itself automatically
    show_modified = true,
    symbols = {
      modified = core.icons.ui.Circle,
      elipsis = core.icons.ui.Ellipsis,
    },
    -- Disable navic completely
    attach_navic = false,
    show_navic = false,
  },
  config = function(_, opts)
    require("barbecue").setup(opts)

    core.auto_cmds({
      {
        {
          "WinResized",
          "BufWinEnter",
          "CursorHold",
          "InsertLeave",

          "BufModifiedSet", -- include this if you have set `show_modified` to `true`
        },
        {
          group = "barbecue.updater",
          callback = function()
            require("barbecue.ui").update()
          end,
        },
      },
    })
  end,
}
