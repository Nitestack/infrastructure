---@type LazySpec
return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "luckasRanarison/tailwind-tools.nvim",
      {
        "onsails/lspkind.nvim",
        config = function(_, opts)
          require("lspkind").init(opts)
        end,
      },
      -- Sources
      "hrsh7th/cmp-nvim-lsp",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "Saecki/crates.nvim",
    },
    event = "InsertEnter",
    opts = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      local duplicates = {
        nvim_lsp = 0,
        luasnip = 1,
        path = 1,
        buffer = 1,
      }
      local duplicates_default = 0

      -- Setup mappings
      local mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<Tab>"] = cmp.mapping(function(fallback)
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })

      -- Only on Windows (excluding Neovide)
      if core.is_win() and not core.is_neovide() then
        mapping = vim.tbl_extend("force", mapping, {
          ["<C-x>"] = cmp.mapping.complete(),
        })
      end

      ---@type cmp.ConfigSchema
      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered({
            scrollbar = false,
            scrolloff = 8,
            col_offset = -3,
          }),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = require("lspkind").cmp_format({
            mode = "symbol",
            maxwidth = math.min(50, math.floor(vim.o.columns * 0.5)),
            ellipsis_char = core.icons.ui.Ellipsis,
            preset = "codicons",
            before = function(entry, vim_item)
              vim_item = require("tailwind-tools.cmp").lspkind_format(entry, vim_item)
              if vim.tbl_contains({ "nvim_lsp" }, entry.source.name) then
                vim_item.dup = duplicates[entry.source.name] or duplicates_default
              end
              return vim_item
            end,
            show_labelDetails = true,
          }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "crates" },
          { name = "path" },
        }, {
          { name = "buffer", keyword_length = 5 },
        }),
        mapping = mapping,
      }
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
        formatting = {
          fields = { "abbr", "menu" },
        },
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(":", {
        formatting = {
          fields = { "abbr", "menu" },
        },
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
