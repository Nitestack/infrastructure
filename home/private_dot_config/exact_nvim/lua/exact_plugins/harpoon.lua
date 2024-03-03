---@type LazySpec
return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = core.lazy_map({
      n = {
        ["<leader>hm"] = {
          function()
            require("harpoon"):list():append()
          end,
          "Harpoon: Append to file list",
        },
        ["<leader>ht"] = {
          function()
            require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
          end,
          "Harpoon: Toggle quick menu",
        },
        [{ "<leader>hn", "<leader>hj" }] = {
          function()
            require("harpoon"):list():next()
          end,
          "Harpoon: Next file",
        },
        [{ "<leader>hp", "<leader>hk" }] = {
          function()
            require("harpoon"):list():prev()
          end,
          "Harpoon: Previous file",
        },
        [{ "<leader>h1", "<M-1>" }] = {
          function()
            require("harpoon"):list():select(1)
          end,
          "Harpoon: Select file Nr. 1",
        },
        [{ "<leader>h2", "<M-2>" }] = {
          function()
            require("harpoon"):list():select(2)
          end,
          "Harpoon: Select file Nr. 2",
        },
        [{ "<leader>h3", "<M-3>" }] = {
          function()
            require("harpoon"):list():select(3)
          end,
          "Harpoon: Select file Nr. 3",
        },
        [{ "<leader>h4", "<M-4>" }] = {
          function()
            require("harpoon"):list():select(4)
          end,
          "Harpoon: Select file Nr. 4",
        },
        [{ "<leader>h5", "<M-5>" }] = {
          function()
            require("harpoon"):list():select(5)
          end,
          "Harpoon: Select file Nr. 5",
        },
        [{ "<leader>h6", "<M-6>" }] = {
          function()
            require("harpoon"):list():select(6)
          end,
          "Harpoon: Select file Nr. 6",
        },
        [{ "<leader>h7", "<M-7>" }] = {
          function()
            require("harpoon"):list():select(7)
          end,
          "Harpoon: Select file Nr. 7",
        },
        [{ "<leader>h8", "<M-8>" }] = {
          function()
            require("harpoon"):list():select(8)
          end,
          "Harpoon: Select file Nr. 8",
        },
        [{ "<leader>h9", "<M-9>" }] = {
          function()
            require("harpoon"):list():select(9)
          end,
          "Harpoon: Select file Nr. 9",
        },
        [{ "<leader>h0", "<M-0>" }] = {
          function()
            require("harpoon"):list():select(10)
          end,
          "Harpoon: Select file Nr. 10",
        },
      },
    }),
    ---@type HarpoonPartialConfig
    opts = {
      settings = {
        save_on_toggle = true,
      },
    },
    config = function(_, opts)
      require("harpoon"):setup(opts)

      core.auto_cmds({
        {
          "FileType",
          {
            group = "harpoon",
            pattern = { "harpoon" },
            callback = function()
              if core.config.ui.transparent.floats then
                local win_id = vim.fn.win_getid()
                vim.api.nvim_win_set_config(win_id, { title = "Harpoon", title_pos = "center", border = "rounded" })
              end
            end,
          },
        },
      })
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>h"] = { name = "+harpoon" },
      },
    },
  },
}
