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
        -- Extract function supports only visual mode
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
        -- Extract variable supports only visual mode
        ["v"] = {
          function()
            require("refactoring").refactor("Extract Variable")
          end,
          "Refactoring: Extract variable",
        },
      },
      n = {
        -- Inline func supports only normal
        ["I"] = {
          function()
            require("refactoring").refactor("Inline Function")
          end,
          "Refactoring: Inline function",
        },
        -- Extract block supports only normal mode
        ["b"] = {
          function()
            require("refactoring").refactor("Extract Block")
          end,
          "Refactoring: Extract block",
        },
        ["bf"] = {
          function()
            require("refactoring").refactor("Extract Block To File")
          end,
          "Refactoring: Extract block to file",
        },
        ["df"] = {
          function()
            require("refactoring").debug.printf({ below = false })
          end,
          "Refactoring: Debug printf",
        },
        ["dc"] = {
          function()
            require("refactoring").debug.cleanup({})
          end,
          "Refactoring: Cleanup debug operation",
        },
      },
      -- Inline var supports both normal and visual mode
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
        -- Print var
        ["dv"] = {
          function()
            require("refactoring").debug.print_var({})
          end,
          "Refactoring: Debug print variable",
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
        ["<leader>rd"] = { name = "+debug operations" },
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
