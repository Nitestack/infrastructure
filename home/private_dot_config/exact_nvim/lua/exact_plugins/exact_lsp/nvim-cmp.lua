local function has_words_before()
  local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

return utils.plugin.with_extensions({
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "luckasRanarison/tailwind-tools.nvim",
      "onsails/lspkind.nvim",
      "zbirenbaum/copilot.lua",
    },
    keys = core.lazy_map({
      n = {
        [{ "<Tab>", "<S-Tab>" }] = { false },
      },
    }),
    ---@module "cmp"
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      local copilot = require("copilot.suggestion")

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
        opts.mapping["<C-x>"] = cmp.mapping.complete()
      end

      -- Integrate Copilot into cmp
      opts.mapping["<Tab>"] = cmp.mapping(function(fallback)
        if copilot.is_visible() then
          copilot.accept()
        elseif cmp.visible() then
          cmp.select_next_item()
        elseif vim.api.nvim_get_mode().mode ~= "c" and vim.snippet.active({ direction = 1 }) then
          vim.schedule(function()
            vim.snippet.jump(1)
          end)
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "s" })
      opts.mapping["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif vim.api.nvim_get_mode().mode ~= "c" and vim.snippet.active({ direction = -1 }) then
          vim.schedule(function()
            vim.snippet.jump(-1)
          end)
        else
          fallback()
        end
      end, { "i", "s" })
      opts.mapping["<C-x>"] = cmp.mapping(function()
        if copilot.is_visible() then
          copilot.next()
        end
      end)
      opts.mapping["<C-z>"] = cmp.mapping(function()
        if copilot.is_visible() then
          copilot.prev()
        end
      end)
      opts.mapping["<C-right>"] = cmp.mapping(function()
        if copilot.is_visible() then
          copilot.accept_word()
        end
      end)
      opts.mapping["<C-l>"] = cmp.mapping(function()
        if copilot.is_visible() then
          copilot.accept_word()
        end
      end)
      opts.mapping["<C-down>"] = cmp.mapping(function()
        if copilot.is_visible() then
          copilot.accept_line()
        end
      end)
      opts.mapping["<C-j>"] = cmp.mapping(function()
        if copilot.is_visible() then
          copilot.accept_line()
        end
      end)
      opts.mapping["<C-c>"] = cmp.mapping(function()
        if copilot.is_visible() then
          copilot.dismiss()
        end
      end)

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
        symbol_map = { Copilot = "" },
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
