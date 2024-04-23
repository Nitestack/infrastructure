return utils.plugin.with_extensions({
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    event = "VeryLazy",
    keys = core.lazy_map({
      n = {
        ["d"] = {
          function()
            require("noice").cmd("dismiss")
          end,
          desc = "Noice: Dismiss all",
        },
        ["e"] = {
          function()
            require("noice").cmd("error")
          end,
          desc = "Noice: Next error",
        },
      },
    }, {
      prefix = "<leader>sn",
    }),
    ---@type NoiceConfig
    opts = {
      -- Disable cmdline
      cmdline = {
        view = "cmdline",
      },
      -- Disable notify
      -- messages = {
      --   enabled = true,
      --   view = "mini",
      --   view_error = "mini",
      --   view_warn = "mini",
      -- },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        message = {
          view = "mini",
        },
        hover = {
          silent = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
        -- Show @recording messages
        {
          view = "notify",
          filter = { event = "msg_showmode" },
        },
        -- Disable various messages
        {
          opts = { skip = true },
          filter = {
            any = {
              { event = "msg_show", find = "written" },
              { event = "msg_show", find = "%d+ lines, %d+ bytes" },
              { event = "msg_show", find = "%d+L, %d+B" },
              { event = "msg_show", find = "^Hunk %d+ of %d" },
              { event = "msg_show", find = "%d+ change" },
              { event = "msg_show", find = "%d+ line" },
              { event = "msg_show", find = "%d+ more line" },
            },
          },
        },
      },
      views = {
        cmdline_popup = {
          border = core.config.ui.transparent.floats and {
            style = "rounded",
          } or {
            style = "none",
            padding = { 1, 2 },
          },
          win_options = {
            winhighlight = {
              Normal = "NormalFloat",
            },
          },
        },
        mini = {
          position = {
            -- auto-adjust height based on cmdheight (so it doesn't overlap with the statusline)
            row = -1 - vim.o.cmdheight,
          },
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = core.config.ui.transparent.floats and true or false,
      },
    },
  },
}, {
  which_key = {
    ["<leader>sn"] = "noice",
  },
})
