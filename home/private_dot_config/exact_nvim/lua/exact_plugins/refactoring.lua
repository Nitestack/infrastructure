---@type LazySpec
return {
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
          "Refactoring: Extract function",
        },
        ["f"] = {
          function()
            require("refactoring").refactor("Extract Function To File")
          end,
          "Refactoring: Extract function to file",
        },
        ["v"] = {
          function()
            require("refactoring").refactor("Extract Variable")
          end,
          "Refactoring: Extract variable",
        },
      },
      n = {
        ["I"] = {
          function()
            require("refactoring").refactor("Inline Function")
          end,
          "Refactoring: Inline function",
        },
        ["b"] = {
          function()
            require("refactoring").refactor("Extract Block")
          end,
          "Refactoring: Extract block",
        },
        ["B"] = {
          function()
            require("refactoring").refactor("Extract Block To File")
          end,
          "Refactoring: Extract block to file",
        },
        ["D"] = {
          function()
            require("refactoring").debug.printf({ below = false })
          end,
          "Debug: Print function",
        },
        ["c"] = {
          function()
            require("refactoring").debug.cleanup({})
          end,
          "Debug: Cleanup operation",
        },
      },
      [{ "n", "x" }] = {
        ["i"] = {
          function()
            require("refactoring").refactor("Inline Variable")
          end,
          "Refactoring: Inline variable",
        },
        ["r"] = {
          function()
            require("telescope").extensions.refactoring.refactors()
          end,
          "Refactoring: Select refactoring",
        },
        ["d"] = {
          function()
            require("refactoring").debug.print_var({})
          end,
          "Debug: Print variable",
        },
      },
    }, {
      prefix = "<leader>r",
    }),
    ---@type ConfigOpts
    opts = {},
  },
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>r"] = { name = "+refactoring" },
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      load_extensions = {
        ["refactoring"] = true,
      },
    },
  },
}
