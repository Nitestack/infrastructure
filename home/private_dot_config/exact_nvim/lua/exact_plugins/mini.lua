---@type LazySpec
return {
  {
    "echasnovski/mini.indentscope",
    opts = {
      symbol = core.icons.ui.LineLeft,
    },
  },
  {
    "echasnovski/mini.move",
    keys = core.lazy_map({
      [{ "n", "x" }] = {
        [{ "<M-j>", "<M-k>", "<M-h>", "<M-l>" }] = {},
      },
    }),
    opts = {},
  },
  {
    "echasnovski/mini.ai",
    event = function()
      return {
        "LazyFile",
      }
    end,
  },
  {
    "echasnovski/mini.comment",
    event = function()
      return {}
    end,
    keys = core.lazy_map({
      n = {
        ["gcc"] = {},
      },
      [{ "n", "x", "o" }] = {
        ["gc"] = {},
      },
    }),
  },
  {
    "echasnovski/mini.pairs",
    event = function()
      return { "InsertEnter" }
    end,
  },
  { import = "lazyvim.plugins.extras.editor.mini-files" },
  {
    "echasnovski/mini.files",
    keys = core.lazy_map({
      n = {
        [{ "<leader>fm", "<leader>e" }] = {
          function()
            if not MiniFiles.close() then
              MiniFiles.open(vim.api.nvim_buf_get_name(0), true)
            end
          end,
          "Open mini.files (directory of current file)",
        },
        [{ "<leader>fM", "<leader>E" }] = {
          function()
            if not MiniFiles.close() then
              MiniFiles.open(vim.loop.cwd(), true)
            end
          end,
          "Open mini.files (cwd)",
        },
      },
    }),
    opts = {
      content = {
        prefix = function(fs_entry)
          if fs_entry.fs_type == "directory" then
            return core.icons.ui.Folder .. " ", "MiniFilesDirectory"
          end
          return MiniFiles.default_prefix(fs_entry)
        end,
      },
    },
    config = function(_, opts)
      require("mini.files").setup(opts)

      core.auto_cmds({
        {
          "User",
          {
            pattern = "MiniFilesWindowOpen",
            callback = function(args)
              local win_id = args.data.win_id

              vim.api.nvim_win_set_config(win_id, { border = "rounded" })
            end,
          },
        },
      })
    end,
  },
  -- { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
}
