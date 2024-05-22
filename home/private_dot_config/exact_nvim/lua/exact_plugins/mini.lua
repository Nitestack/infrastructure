return utils.plugin.with_extensions({
  { import = "lazyvim.plugins.extras.ui.mini-indentscope" },
  {
    "echasnovski/mini.indentscope",
    opts = {
      symbol = core.icons.ui.LineLeft,
    },
  },
  { import = "lazyvim.plugins.extras.editor.mini-files" },
  {
    "echasnovski/mini.files",
    keys = core.lazy_map({
      n = {
        ["<leader>e"] = {
          function()
            if not require("mini.files").close() then
              require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
            end
          end,
          desc = "File Explorer: Toggle",
        },
        [{ "<leader>fm", "<leader>fM" }] = {
          false,
        },
      },
    }),
    opts = {
      content = {
        prefix = function(fs_entry)
          if fs_entry.fs_type == "directory" then
            return core.icons.ui.FolderClosed .. " ", "MiniFilesDirectory"
          end
          return require("mini.files").default_prefix(fs_entry)
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
        {
          "User",
          {
            pattern = "MiniFilesActionRename",
            callback = function(event)
              LazyVim.lsp.on_rename(event.data.from, event.data.to)
            end,
          },
        },
      })
    end,
  },
  { import = "lazyvim.plugins.extras.editor.mini-move" },
  {
    "echasnovski/mini.move",
    event = function()
      return {}
    end,
    keys = core.lazy_map({
      [{ "n", "x" }] = {
        ["<M-j>"] = {
          desc = "Move down",
        },
        ["<M-k>"] = {
          desc = "Move up",
        },
        ["<M-h>"] = {
          desc = "Move left",
        },
        ["<M-l>"] = {
          desc = "Move right",
        },
      },
      i = {
        ["<M-j>"] = {
          "<Esc><cmd>m .+1<cr>==gi",
          desc = "Move down",
        },
        ["<M-k>"] = {
          "<Esc><cmd>m .-2<cr>==gi",
          desc = "Move up",
        },
      },
    }),
  },
  { import = "lazyvim.plugins.extras.coding.mini-surround" },
  {
    "echasnovski/mini.surround",
    opts = {
      mappings = {
        add = "sa", -- Add surrounding in Normal and Visual modes
        delete = "sd", -- Delete surrounding
        find = "sf", -- Find surrounding (to the right)
        find_left = "sF", -- Find surrounding (to the left)
        highlight = "sh", -- Highlight surrounding
        replace = "sr", -- Replace surrounding
        update_n_lines = "sn", -- Update `n_lines`
      },
    },
  },
  {
    "echasnovski/mini.ai",
    event = function()
      return { "LazyFile" }
    end,
  },
  {
    "echasnovski/mini.pairs",
    event = function()
      return { "LazyFile" }
    end,
  },
}, {
  which_key = {
    ["s"] = "Surround",
  },
})
