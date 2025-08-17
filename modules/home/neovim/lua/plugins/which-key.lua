return utils.plugin.with_extensions({
  {
    "folke/which-key.nvim",
    ---@module "which-key"
    ---@type wk.Opts
    opts = {
      spec = {
        {
          mode = { "n", "v" },
          { "g", group = "Goto" },
          { "z", group = "Fold" },
          { "]", group = "Next" },
          { "[", group = "Previous" },
          { "<C-w>", group = "Window" },
          { "<leader>", group = "Leader" },
          { "<leader><Tab>", group = "Tabs" },
          {
            "<leader>b",
            group = "Buffer",
            expand = function()
              return require("which-key.extras").expand.buf()
            end,
          },
          { "<leader>c", group = "Code" },
          { "<leader>f", group = "File/Find" },
          { "<leader>g", group = "Git" },
          { "<leader>gh", group = "Hunks" },
          { "<leader>q", group = "Quit/Session" },
          { "<leader>s", group = "Search" },
          { "<leader>u", group = "UI" },
          {
            "<leader>w",
            group = "Windows",
            proxy = "<C-w>",
            expand = function()
              return require("which-key.extras").expand.win()
            end,
          },
          { "<leader>x", group = "Diagnostics/Quickfix/Location" },
        },
      },
      icons = {
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
