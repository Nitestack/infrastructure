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
        ["<leader>re"] = {
          function()
            require("refactoring").refactor("Extract Function")
          end,
          "Refactoring: Extract function",
        },
        ["<leader>rf"] = {
          function()
            require("refactoring").refactor("Extract Function To File")
          end,
          "Refactoring: Extract function to file",
        },
        -- Extract variable supports only visual mode
        ["<leader>rv"] = {
          function()
            require("refactoring").refactor("Extract Variable")
          end,
          "Refactoring: Extract variable",
        },
      },
      n = {
        -- Inline func supports only normal
        ["<leader>rI"] = {
          function()
            require("refactoring").refactor("Inline Function")
          end,
          "Refactoring: Inline function",
        },
        -- Extract block supports only normal mode
        ["<leader>rb"] = {
          function()
            require("refactoring").refactor("Extract Block")
          end,
          "Refactoring: Extract block",
        },
        ["<leader>rbf"] = {
          function()
            require("refactoring").refactor("Extract Block To File")
          end,
          "Refactoring: Extract block to file",
        },
        ["<leader>rdf"] = {
          function()
            require("refactoring").debug.printf({ below = false })
          end,
          "Refactoring: Debug printf",
        },
        ["<leader>rdc"] = {
          function()
            require("refactoring").debug.cleanup({})
          end,
          "Refactoring: Cleanup debug operation",
        },
      },
      -- Inline var supports both normal and visual mode
      [{ "n", "x" }] = {
        ["<leader>ri"] = {
          function()
            require("refactoring").refactor("Inline Variable")
          end,
          "Refactoring: Inline variable",
        },
        ["<leader>rr"] = {
          function()
            require("telescope").extensions.refactoring.refactors()
          end,
          "Refactoring: Select refactoring",
        },
        -- Print var
        ["<leader>rdv"] = {
          function()
            require("refactoring").debug.print_var({})
          end,
          "Refactoring: Debug print variable",
        },
      },
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
