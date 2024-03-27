---@type LazyPluginSpec
return {
  "rcarriga/nvim-notify",
  keys = core.lazy_map({
    n = {
      ["<leader>un"] = {
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        "Notify: Dismiss all",
      },
    },
  }),
  ---@type notify.Config
  opts = {
    stages = core.config.performance_mode and "static" or "fade_in_slide_out",
    timeout = 3000,
    max_height = function()
      return math.floor(vim.o.lines * 0.75)
    end,
    max_width = function()
      return math.floor(vim.o.columns * 0.75)
    end,
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { zindex = 100 })
    end,
    fps = not core.config.performance_mode and 144 or 30,
    icons = core.icons.diagnostics,
  },
}
