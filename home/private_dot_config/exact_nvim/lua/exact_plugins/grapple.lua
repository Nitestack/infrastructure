---@type LazySpec
return {
  {
    "cbochs/grapple.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Grapple",
    keys = core.lazy_map({
      n = {
        [{ "M", "<leader>jm" }] = {
          function()
            require("grapple").toggle()
          end,
          "Jump: Toggle file",
        },
        [{ "L", "<leader>jt" }] = {
          function()
            require("grapple").toggle_tags()
          end,
          "Jump: Toggle menu",
        },
        [{ "<M-1>", "<leader>j1" }] = {
          function()
            require("grapple").select({ index = 1 })
          end,
          "Jump: File 1",
        },
        [{ "<M-2>", "<leader>j2" }] = {
          function()
            require("grapple").select({ index = 2 })
          end,
          "Jump: File 2",
        },
        [{ "<M-3>", "<leader>j3" }] = {
          function()
            require("grapple").select({ index = 3 })
          end,
          "Jump: File 3",
        },
        [{ "<M-4>", "<leader>j4" }] = {
          function()
            require("grapple").select({ index = 4 })
          end,
          "Jump: File 4",
        },
        [{ "<M-5>", "<leader>j5" }] = {
          function()
            require("grapple").select({ index = 5 })
          end,
          "Jump: File 5",
        },
      },
    }),
    ---@type grapple.settings
    opts = {
      scope = "git_branch",
      win_opts = {
        border = core.config.ui.transparent.floats and "rounded" or "none",
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>j"] = { name = "+jump" },
      },
    },
  },
  {
    "WolfeCub/harpeek.nvim",
    keys = core.lazy_map({
      n = {
        ["<leader>jp"] = {
          function()
            require("harpeek").toggle()
          end,
          "Jump: Toggle peek menu",
        },
      },
    }),
    ---@type harpeek.settings
    opts = {
      winopts = {
        border = core.config.ui.transparent.floats and "rounded" or "none",
      },
      hide_on_empty = true,
    },
  },
}
