---@type LazySpec
return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "roobert/tailwindcss-colorizer-cmp.nvim",
      "onsails/lspkind.nvim",
      "L3MON4D3/LuaSnip",
      "windwp/nvim-autopairs",
      -- Sources
      "hrsh7th/cmp-emoji",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      local tailwindcss_colorizer = require("tailwindcss-colorizer-cmp")

      tailwindcss_colorizer.setup()
      lspkind.init()

      local max_menu_width = math.min(50, math.floor(vim.o.columns * 0.5))

      -- Sources
      opts.sources = opts.sources or {}
      opts.sources = vim.list_extend(opts.sources, {
        { name = "emoji" },
      })

      -- Window
      opts.window = opts.window or {}
      opts.window.completion = cmp.config.window.bordered({
        scrollbar = false,
        scrolloff = 8,
        col_offset = -3,
      })
      opts.window.documentation = cmp.config.window.bordered()

      -- Formatting
      local duplicates = {
        buffer = 1,
        path = 1,
        nvim_lsp = 0,
        luasnip = 1,
      }
      local duplicates_default = 0
      opts.formatting = opts.formatting or {}
      opts.formatting.fields = {
        "kind",
        "abbr",
        "menu",
      }
      opts.formatting.format = lspkind.cmp_format({
        mode = "symbol",
        maxwidth = max_menu_width,
        ellipsis_char = core.icons.ui.Ellipsis,
        preset = "codicons",
        before = function(entry, vim_item)
          vim_item = require("tailwindcss-colorizer-cmp").formatter(entry, vim_item)
          if vim.tbl_contains({ "nvim_lsp" }, entry.source.name) then
            vim_item.dup = duplicates[entry.source.name] or duplicates_default
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

      if utils.general.is_win() and not utils.general.is_neovide() then
        opts.mapping = vim.tbl_extend("force", opts.mapping, {
          ["<C-x>"] = cmp.mapping.complete(),
        })
      end

      -- Autopairs
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
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
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
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
