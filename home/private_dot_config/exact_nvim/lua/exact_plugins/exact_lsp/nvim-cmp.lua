return utils.plugin.with_extensions({
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "luckasRanarison/tailwind-tools.nvim",
      "onsails/lspkind.nvim",
    },
    ---@module "cmp"
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")

      opts.enabled = function()
        if vim.bo[0].buftype ~= "prompt" then
          return true
        end

        -- Check if in a DAP window (`require("cmp_dap").is_dap_buffer()` uses deprecated function, so using this)
        local filetype = vim.bo[0].filetype
        if vim.startswith(filetype, "dapui_") then
          return true
        end
        if filetype == "dap-repl" then
          return true
        end
        return false
      end

      -- View
      opts.entries = opts.entries or {}
      opts.entries.follow_cursor = true

      -- Window
      opts.window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      }

      -- Mapping: Only on Windows (excluding Neovide)
      if utils.is_win() and not utils.is_neovide() then
        opts.mapping = vim.tbl_extend("force", opts.mapping, {
          ["<C-x>"] = cmp.mapping.complete(),
        })
      end

      -- Formatting
      opts.formatting = opts.formatting or {}
      opts.formatting.fields = { "kind", "abbr", "menu" }
      opts.formatting.format = require("lspkind").cmp_format({
        mode = "symbol",
        maxwidth = math.min(50, math.floor(vim.o.columns * 0.5)),
        ellipsis_char = core.icons.ui.Ellipsis,
        preset = "codicons",
        before = require("tailwind-tools.cmp").lspkind_format,
        show_labelDetails = true,
      })
    end,
  },
  {
    "hrsh7th/cmp-cmdline",
    dependencies = {
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    keys = { ":", "/", "?" },
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
}, {
  catppuccin = {
    cmp = true,
  },
})
