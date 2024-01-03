---@type LazyPluginSpec
return {
  "utilyre/barbecue.nvim",
  name = "barbecue",
  version = "*",
  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons",
  },
  event = "LazyFile",
  ---@type barbecue.Config
  opts = {
    create_autocmd = false,
    show_dirname = false,
    show_modified = true,
    theme = type(core.config.lazyvim.colorscheme) == "function" and core.config.lazyvim.colorscheme()
      or core.config.lazyvim.colorscheme,
    kinds = core.icons.kind,
  },
  config = function(_, opts)
    require("barbecue").setup(opts)

    core.auto_cmds({
      {
        {
          "WinResized", -- or WinResized on NVIM-v0.9 and higher
          "BufWinEnter",
          "CursorHold",
          "InsertLeave",

          -- include this if you have set `show_modified` to `true`
          "BufModifiedSet",
        },
        {
          group = "barbecue.updater",
          callback = function()
            require("barbecue.ui").update()
          end,
        },
      },
    }, {}, {})
  end,
}
