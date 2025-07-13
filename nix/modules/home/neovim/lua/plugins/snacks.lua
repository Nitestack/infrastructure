return utils.plugin.with_extensions({
  {
    "folke/snacks.nvim",
    keys = core.lazy_map({
      n = {
        [{ "<leader>e", "<leader>E" }] = { false },
      },
    }),
    ---@module "snacks"
    ---@type snacks.Config
    opts = {
      -- Dashboard
      dashboard = {
        preset = {
          header = core.config.ui.logo,
        },
      },
      -- Image
      image = {
        enabled = true,
        math = {
          typst = {
            tpl = [[
              #set page(width: auto, height: auto, margin: (x: 2pt, y: 2pt))
              #show math.equation.where(block: false): set text(top-edge: "bounds", bottom-edge: "bounds")
              #set text(lang: "de", region: "DE", fill: rgb("${color}"))
              ${header}
              ${content}]],
          },
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
      -- Picker
      picker = {
        win = {
          input = {
            keys = {
              ["<Esc>"] = { "close", mode = { "n", "i" } },
            },
          },
        },
      },
      -- Scroll
      scroll = {
        animate = {
          duration = { step = 5, total = 200 },
          fps = not core.config.performance_mode and 200,
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
