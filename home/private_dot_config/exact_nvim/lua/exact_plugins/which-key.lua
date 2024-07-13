return utils.plugin.with_extensions({
  {
    "folke/which-key.nvim",
    event = function()
      return {}
    end,
    keys = core.lazy_map({
      n = {
        [{ "<leader>", "<C-r>", "<C-w>", "\"", "'", "`", "c", "v", "g" }] = {},
      },
    }),
    ---@module "which-key"
    ---@type wk.Opts
    opts = {
      preset = "modern",
      spec = {
        {
          mode = { "n", "v" },
          { "g", group = "Goto" },
          { "z", group = "Fold" },
          { "]", group = "Next" },
          { "[", group = "Previous" },
          { "<C-w>", group = "Window" },
          { "<leader>", group = "Leader" },
          { "<leader>b", group = "Buffer" },
          { "<leader>c", group = "Code" },
          { "<leader>f", group = "File/Find" },
          { "<leader>g", group = "Git" },
          { "<leader>gh", group = "Hunks" },
          { "<leader>q", group = "Quit/Session" },
          { "<leader>s", group = "Search" },
          { "<leader>u", group = "UI" },
          { "<leader>w", group = "Windows" },
          { "<leader>x", group = "Diagnostics/Quickfix/Location" },
        },
      },
      icons = {
        breadcrumb = core.icons.ui.DoubleChevronRight,
        ellipsis = core.icons.ui.Ellipsis,
        group = "",
        separator = "",
      },
    },
  },
}, {
  catppuccin = {
    which_key = true,
  },
})
