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
    dependencies = "echasnovski/mini.icons",
    keys = core.lazy_map({
      n = {
        ["<leader>e"] = {
          function()
            if not require("mini.files").close() then
              require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
            end
          end,
          desc = "Open File Explorer (current dir)",
        },
        ["<leader>E"] = {
          function()
            if not require("mini.files").close() then
              require("mini.files").open(vim.uv.cwd(), true)
            end
          end,
          desc = "Open File Explorer (cwd)",
        },
        [{ "<leader>fm", "<leader>fM" }] = {
          false,
        },
      },
    }),
    opts = function(_, opts)
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

      opts.content = opts.content or {}
      opts.content.prefix = function(fs_entry)
        local category = fs_entry.fs_type == "directory" and "directory" or "file"
        local icon, hl = require("mini.icons").get(category, utils.resolve_chezmoi_name(category, fs_entry.name))
        return icon .. " ", hl
      end
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
    keys = core.lazy_map({
      [{ "n", "x" }] = {
        ["s"] = "Surround",
      },
    }),
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
    keys = { ":", "/", "?" },
    event = function()
      return { "LazyFile" }
    end,
  },
}, {
  catppuccin = {
    mini = {
      enabled = true,
      indentscope_color = "overlay0",
    },
  },
})
