return utils.plugin.with_extensions({
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = core.lazy_map({
      x = {
        ["e"] = {
          function()
            require("refactoring").refactor("Extract Function")
          end,
          desc = "Refactoring: Extract function",
        },
        ["f"] = {
          function()
            require("refactoring").refactor("Extract Function To File")
          end,
          desc = "Refactoring: Extract function to file",
        },
        ["v"] = {
          function()
            require("refactoring").refactor("Extract Variable")
          end,
          desc = "Refactoring: Extract variable",
        },
      },
      n = {
        ["I"] = {
          function()
            require("refactoring").refactor("Inline Function")
          end,
          desc = "Refactoring: Inline function",
        },
        ["b"] = {
          function()
            require("refactoring").refactor("Extract Block")
          end,
          desc = "Refactoring: Extract block",
        },
        ["B"] = {
          function()
            require("refactoring").refactor("Extract Block To File")
          end,
          desc = "Refactoring: Extract block to file",
        },
        ["D"] = {
          function()
            require("refactoring").debug.printf({ below = false })
          end,
          desc = "Debug: Print function",
        },
        ["c"] = {
          function()
            require("refactoring").debug.cleanup({})
          end,
          desc = "Debug: Cleanup operation",
        },
      },
      [{ "n", "x" }] = {
        ["i"] = {
          function()
            require("refactoring").refactor("Inline Variable")
          end,
          desc = "Refactoring: Inline variable",
        },
        ["r"] = {
          function()
            require("telescope").extensions.refactoring.refactors()
          end,
          desc = "Refactoring: Select refactoring",
        },
        ["d"] = {
          function()
            require("refactoring").debug.print_var({})
          end,
          desc = "Debug: Print variable",
        },
      },
    }, {
      prefix = "<leader>r",
    }),
    ---@type ConfigOpts
    opts = {},
  },
}, {
  which_key = {
    ["<leader>r"] = "Refactoring",
  },
  telescope = {
    extensions = "refactoring",
  },
})
