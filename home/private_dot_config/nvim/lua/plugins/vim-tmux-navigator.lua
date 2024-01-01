---@type LazyPluginSpec
return {
  "christoomey/vim-tmux-navigator",
  enabled = function()
    return vim.fn.executable("tmux") == 1
  end,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = core.lazy_map({
    n = {
      ["<C-h>"] = {
        function()
          vim.cmd("TmuxNavigateLeft")
        end,
        "Tmux: Navigate left",
      },
      ["<C-j>"] = {
        function()
          vim.cmd("TmuxNavigateDown")
        end,
        "Tmux: Navigate down",
      },
      ["<C-k>"] = {
        function()
          vim.cmd("TmuxNavigateUp")
        end,
        "Tmux: Navigate up",
      },
      ["<C-l>"] = {
        function()
          vim.cmd("TmuxNavigateRight")
        end,
        "Tmux: Navigate right",
      },
      ["<C-\\>"] = {
        function()
          vim.cmd("TmuxNavigatePrevious")
        end,
        "Tmux: Navigate previous",
      },
    },
  }),
}
