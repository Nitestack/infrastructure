---@type LazyPluginSpec
return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = { "ConformInfo", "Format", "FormatEnable", "FormatDisable" },
  init = function()
    vim.o.formatexpr = "v:lua.require('conform').formatexpr()"
  end,
  keys = core.lazy_map({
    [""] = {
      ["<leader>cf"] = {
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        desc = "Format",
      },
    },
  }),
  opts = core.config.plugins.formatting,
  config = function(_, opts)
    for _, formatter in pairs(opts.formatters) do
      if type(formatter) == "table" then
        if formatter.extra_args then
          formatter.prepend_args = formatter.extra_args
        end
      end
    end

    require("conform").setup(vim.tbl_deep_extend("force", {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end

        return { timeout_ms = 500, lsp_fallback = true }
      end,
    }, opts))

    core.user_cmds({
      {
        "FormatEnable",
        function()
          vim.b.disable_autoformat = false
          vim.g.disable_autoformat = false
          vim.notify("Autoformat enabled", vim.log.levels.INFO, { title = "Editor" })
        end,
        {
          desc = "Re-enable autoformat on save",
        },
      },
      {
        "FormatDisable",
        function(args)
          if args.bang then
            -- FormatDisable! will disable formatting just for this buffer
            vim.b.disable_autoformat = true
            vim.notify("Autoformat for current buffer disabled", vim.log.levels.INFO, { title = "Editor" })
          else
            vim.g.disable_autoformat = true
            vim.notify("Autoformat disabled", vim.log.levels.INFO, { title = "Editor" })
          end
        end,
        {
          desc = "Disable autoformat on save",
          bang = true,
        },
      },
      {
        "Format",
        function(args)
          local range = nil
          if args.count ~= -1 then
            local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
            range = {
              start = { args.line1, 0 },
              ["end"] = { args.line2, end_line:len() },
            }
          end
          require("conform").format({ async = true, lsp_fallback = true, range = range })
        end,
        { range = true },
      },
    })
  end,
}
