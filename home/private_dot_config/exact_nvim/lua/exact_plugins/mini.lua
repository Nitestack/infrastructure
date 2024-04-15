---@type LazySpec
return {
  {
    "echasnovski/mini.files",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = core.lazy_map({
      n = {
        ["<leader>e"] = {
          function()
            if not MiniFiles.close() then
              MiniFiles.open(vim.api.nvim_buf_get_name(0), true)
            end
          end,
          "File Explorer: Toggle",
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
      windows = {
        preview = true,
        width_focus = 30,
        width_preview = 30,
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
              utils.lsp.on_rename(event.data.from, event.data.to)
            end,
          },
        },
      })
    end,
  },
  {
    "echasnovski/mini.move",
    keys = core.lazy_map({
      [{ "n", "x" }] = {
        [{ "<M-j>", "<M-k>", "<M-h>", "<M-l>" }] = {},
      },
      i = {
        ["<M-j>"] = {
          "<Esc><cmd>m .+1<cr>==gi",
          "Move down",
        },
        ["<M-k>"] = {
          "<Esc><cmd>m .-2<cr>==gi",
          "Move up",
        },
      },
    }),
    opts = {},
  },
  {
    "echasnovski/mini.indentscope",
    event = "LazyFile",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
          "noice",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
    opts = {
      symbol = core.icons.ui.LineLeft,
      options = { try_as_border = true },
    },
  },
  {
    "echasnovski/mini.surround",
    keys = function(_, keys)
      -- Populate the keys based on the user's options
      local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        { opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
        { opts.mappings.delete, desc = "Delete surrounding" },
        { opts.mappings.find, desc = "Find right surrounding" },
        { opts.mappings.find_left, desc = "Find left surrounding" },
        { opts.mappings.highlight, desc = "Highlight surrounding" },
        { opts.mappings.replace, desc = "Replace surrounding" },
        { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
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
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["s"] = { name = "+surround" },
      },
    },
  },
  {
    "echasnovski/mini.ai",
    dependencies = { "folke/which-key.nvim" },
    event = "LazyFile",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[%S][%l%d]+%f[^%l%d]",
              "%f[%P][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
            },
            "^().*()$",
          },
          g = function() -- Whole buffer, similar to `gg` and 'G' motion
            local from = { line = 1, col = 1 }
            local to = {
              line = vim.fn.line("$"),
              col = math.max(vim.fn.getline("$"):len(), 1),
            }
            return { from = from, to = to }
          end,
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)

      -- register all text objects with which-key
      ---@type table<string, string|table>
      local i = {
        [" "] = "Whitespace",
        ["\""] = "Balanced \"",
        ["'"] = "Balanced '",
        ["`"] = "Balanced `",
        ["("] = "Balanced (",
        [")"] = "Balanced ) including white-space",
        [">"] = "Balanced > including white-space",
        ["<lt>"] = "Balanced <",
        ["]"] = "Balanced ] including white-space",
        ["["] = "Balanced [",
        ["}"] = "Balanced } including white-space",
        ["{"] = "Balanced {",
        ["?"] = "User Prompt",
        _ = "Underscore",
        a = "Argument",
        b = "Balanced ), ], }",
        c = "Class",
        d = "Digit(s)",
        e = "Word in CamelCase & snake_case",
        f = "Function",
        g = "Entire file",
        o = "Block, conditional, loop",
        q = "Quote `, \", '",
        t = "Tag",
        u = "Use/call function & method",
        U = "Use/call without dot in name",
      }
      local a = vim.deepcopy(i)
      for k, v in pairs(a) do
        a[k] = v:gsub(" including.*", "")
      end

      local ic = vim.deepcopy(i)
      local ac = vim.deepcopy(a)
      for key, name in pairs({ n = "Next", l = "Last" }) do
        i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
        a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
      end
      require("which-key").register({
        mode = { "o", "x" },
        i = i,
        a = a,
      })
    end,
  },
}
