return utils.plugin.with_extensions({
  {
    "folke/snacks.nvim",
    ---@module "snacks"
    ---@type snacks.Config
    opts = {
      -- Animations
      animate = {
        fps = not core.config.performance_mode and 144,
      },
      -- Dashboard
      dashboard = {
        preset = {
          header = core.config.ui.logo,
        },
      },
      -- Indent
      indent = {
        indent = {
          char = core.icons.ui.LineLeft,
        },
        scope = {
          char = core.icons.ui.LineLeft,
        },
      },
      -- Scroll
      scroll = {
        animate = {
          duration = { step = 5, total = 200 },
        },
      },
      -- Terminal
      terminal = {
        win = {
          style = "float",
        },
      },
      -- Window
      win = {
        border = "rounded",
      },
    },
  },
}, {
  catppuccin = {
    snacks = true,
  },
})
