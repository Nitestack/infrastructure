---@diagnostic disable: missing-parameter
---@type LazySpec
return {
  {
    "rmagatti/goto-preview",
    keys = core.lazy_map({
      n = {
        ["gpd"] = {
          function()
            require("goto-preview").goto_preview_definition()
          end,
          "Preview: Goto Definition",
        },
        ["gpt"] = {
          function()
            require("goto-preview").goto_preview_type_definition()
          end,
          "Preview: Goto Type Definition",
        },
        ["gpi"] = {
          function()
            require("goto-preview").goto_preview_implementation()
          end,
          "Preview: Goto Implementation",
        },
        ["gpD"] = {
          function()
            require("goto-preview").goto_preview_declaration()
          end,
          "Preview: Goto Declaration",
        },
        ["gP"] = {
          function()
            require("goto-preview").close_all_win()
          end,
          "Preview: Close all windows",
        },
        ["gpr"] = {
          function()
            require("goto-preview").goto_preview_references()
          end,
          "Preview: Goto References",
        },
      },
    }),
    opts = function(_, opts)
      local function reset_mappings(bufnr)
        core.disable_mapping({
          n = { "q", "<leader>|", "<leader>-", "<CR>" },
        }, {
          buffer = bufnr,
        })
      end
      opts.default_mappings = false
      opts.border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
      opts.post_open_hook = function(bufnr, winnr)
        core.map({
          n = {
            ["q"] = {
              function()
                reset_mappings(bufnr)
                vim.api.nvim_win_close(winnr, true)
              end,
              "Preview: Close current window",
            },
            ["<leader>|"] = {
              function()
                vim.cmd("wincmd L")
                require("goto-preview").close_all_win({ skip_curr_window = true })
                reset_mappings(bufnr)
              end,
              "Preview: Split vertically",
            },
            ["<leader>-"] = {
              function()
                vim.cmd("wincmd J")
                require("goto-preview").close_all_win({ skip_curr_window = true })
                reset_mappings(bufnr)
              end,
              "Preview: Split horizontally",
            },
            ["<CR>"] = {
              function()
                local cursor_position = vim.api.nvim_win_get_cursor(winnr)
                require("goto-preview").close_all_win()
                vim.api.nvim_set_current_buf(bufnr)
                vim.api.nvim_win_set_cursor(0, cursor_position or { 0, 0 })
              end,
              "Preview: Expand fullscreen",
            },
          },
        }, {
          noremap = true,
          silent = true,
          buffer = bufnr,
        })
      end
      opts.post_close_hook = reset_mappings
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["gp"] = {
          name = "+goto preview",
        },
      },
    },
  },
}
