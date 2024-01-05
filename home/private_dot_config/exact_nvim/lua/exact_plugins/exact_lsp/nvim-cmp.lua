---@type LazySpec
return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "roobert/tailwindcss-colorizer-cmp.nvim",
        opts = {},
      },
      "onsails/lspkind.nvim",
      -- Sources
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-emoji",
      "ray-x/cmp-treesitter",
      "L3MON4D3/LuaSnip",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      local min_menu_width, max_menu_width = 25, math.min(50, math.floor(vim.o.columns * 0.5))

      -- Sources
      opts.sources = opts.sources or {}
      opts.sources = vim.list_extend(opts.sources, {
        { name = "nvim_lua" },
        { name = "emoji" },
        { name = "treesitter" },
      })

      -- Formatting (VSCode-like completion window)
      opts.formatting = opts.formatting or {}
      opts.formatting.fields = {
        "kind",
        "abbr",
        "menu",
      }
      opts.formatting.format = require("lspkind").cmp_format({
        mode = "symbol",
        maxwidth = max_menu_width,
        ellipsis_char = core.icons.ui.Ellipsis,
        preset = "codicons",
        menu = {
          nvim_lsp = "[LSP]",
          emoji = "[Emoji]",
          path = "[Path]",
          luasnip = "[Snippet]",
          buffer = "[Buffer]",
          tmux = "[TMUX]",
          copilot = "[Copilot]",
          treesitter = "[Treesitter]",
        },
        before = function(entry, vim_item)
          local label, length = vim_item.abbr, vim.api.nvim_strwidth(vim_item.abbr)
          vim_item = require("tailwindcss-colorizer-cmp").formatter(entry, vim_item)
          if length < min_menu_width then
            vim_item.abbr = label .. string.rep(" ", min_menu_width - length)
          end
          return vim_item
        end,
      })

      -- Experimental
      opts.experimental = opts.experimental or {}
      opts.experimental.ghost_text = false

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })

      if utils.general.is_win() then
        opts.mapping = vim.tbl_extend("force", opts.mapping, {
          ["<C-x>"] = cmp.mapping.complete(),
        })
      end
    end,
  },
  {
    "hrsh7th/cmp-cmdline",
    dependencies = {
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    event = "CmdlineEnter",
    config = function()
      local cmp = require("cmp")

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      ---@diagnostic disable-next-line: missing-fields
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      ---@diagnostic disable-next-line: missing-fields
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },
}
