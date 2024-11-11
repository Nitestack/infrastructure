return utils.plugin.with_extensions({
  {
    "cbochs/grapple.nvim",
    cmd = "Grapple",
    keys = core.lazy_map({
      n = {
        [{ "M", "<leader>jm" }] = {
          function()
            require("grapple").toggle()
          end,
          desc = "Toggle file",
        },
        [{ "L", "<leader>jt" }] = {
          function()
            require("grapple").toggle_tags()
          end,
          desc = "Toggle menu",
        },
        [{ "<M-1>", "<leader>j1" }] = {
          function()
            require("grapple").select({ index = 1 })
          end,
          desc = "File 1",
        },
        [{ "<M-2>", "<leader>j2" }] = {
          function()
            require("grapple").select({ index = 2 })
          end,
          desc = "File 2",
        },
        [{ "<M-3>", "<leader>j3" }] = {
          function()
            require("grapple").select({ index = 3 })
          end,
          desc = "File 3",
        },
        [{ "<M-4>", "<leader>j4" }] = {
          function()
            require("grapple").select({ index = 4 })
          end,
          desc = "File 4",
        },
        [{ "<M-5>", "<leader>j5" }] = {
          function()
            require("grapple").select({ index = 5 })
          end,
          desc = "File 5",
        },
      },
    }),
    ---@module "grapple"
    ---@type grapple.settings
    opts = {
      scope = "git_branch",
      win_opts = {
        border = "rounded",
      },
    },
  },
}, {
  which_key = {
    { "<leader>j", group = "Jump" },
  },
})
