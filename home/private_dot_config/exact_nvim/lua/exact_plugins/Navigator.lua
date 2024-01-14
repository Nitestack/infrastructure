---@type LazyPluginSpec
return {
  "numToStr/Navigator.nvim",
  enabled = function()
    return vim.fn.executable("tmux") == 1 or vim.fn.executable("wezterm") == 1
  end,
  keys = core.lazy_map({
    [{ "v", "n", "i", "t" }] = {
      ["<C-h>"] = {
        "<C-\\><C-n><cmd>NavigatorLeft<cr>",
        "Navigator: Navigate left",
      },
      ["<C-l>"] = {
        "<C-\\><C-n><cmd>NavigatorRight<cr>",
        "Navigator: Navigate right",
      },
      ["<C-k>"] = {
        "<C-\\><C-n><cmd>NavigatorUp<cr>",
        "Navigator: Navigate up",
      },
      ["<C-j>"] = {
        "<C-\\><C-n><cmd>NavigatorDown<cr>",
        "Navigator: Navigate down",
      },
    },
  }, {
    silent = true,
  }),
  opts = {},
}
