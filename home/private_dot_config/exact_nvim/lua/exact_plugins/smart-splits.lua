---@type LazyPluginSpec
return {
  "mrjones2014/smart-splits.nvim",
  event = "VeryLazy",
  cmd = {
    "SmartResizeLeft",
    "SmartResizeRight",
    "SmartResizeUp",
    "SmartResizeDown",

    "SmartCursorMoveLeft",
    "SmartCursorMoveRight",
    "SmartCursorMoveUp",
    "SmartCursorMoveDown",

    "SmartSwapLeft",
    "SmartSwapRight",
    "SmartSwapUp",
    "SmartSwapDown",

    "SmartResizeMode",
    "SmartSplitsLog",
    "SmartSplitsLogLevel",
  },
  keys = core.lazy_map({
    n = {
      ["<C-h>"] = {
        function()
          require("smart-splits").move_cursor_left()
        end,
        "Window: Select left",
      },
      ["<C-l>"] = {
        function()
          require("smart-splits").move_cursor_right()
        end,
        "Window: Select right",
      },
      ["<C-k>"] = {
        function()
          require("smart-splits").move_cursor_up()
        end,
        "Window: Select upper",
      },
      ["<C-j>"] = {
        function()
          require("smart-splits").move_cursor_down()
        end,
        "Window: Select lower",
      },
      ["<C-;>"] = {
        function()
          if vim.fn.winnr() == vim.fn.winnr("j") then
            vim.fn.system({
              "wezterm",
              "cli",
              "activate-pane-direction",
              "Down",
            })
          else
            vim.cmd.wincmd("j")
          end
        end,
        "WezTerm: Toggle terminal",
      },
      ["<C-Up>"] = {
        function()
          require("smart-splits").resize_up()
        end,
        "Window: Resize up",
      },
      ["<C-Down>"] = {
        function()
          require("smart-splits").resize_down()
        end,
        "Window: Resize down",
      },
      ["<C-Left>"] = {
        function()
          require("smart-splits").resize_left()
        end,
        "Window: Resize left",
      },
      ["<C-Right>"] = {
        function()
          require("smart-splits").resize_right()
        end,
        "Window: Resize right",
      },
    },
  }),
  ---@type SmartSplitsConfig
  opts = {
    multiplexer_integration = "wezterm",
  },
}
