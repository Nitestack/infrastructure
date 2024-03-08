local lsp_utils = require("utils.lsp")

---@type LazyPluginSpec
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    {
      "folke/neoconf.nvim",
      dependencies = { "neovim/nvim-lspconfig" },
      cmd = "Neoconf",
      opts = {},
    },
    {
      "folke/neodev.nvim",
      opts = {},
    },
  },
  event = "LazyFile",
  opts = {
    servers = {
      emmet_language_server = {},
    },
    setup = {},
  },
  config = function(_, opts)
    -- Diagnostic config
    ---@type vim.diagnostic.Opts
    local diagnostic_opts = {
      underline = true,
      update_in_insert = not core.config.performance_mode,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "",
        -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
        -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
        -- prefix = "icons",
      },
      severity_sort = true,
      signs = {
        text = {},
        texthl = {},
        numhl = {},
      },
    }
    -- Diagnostic signs
    for name, icon in pairs({
      Error = core.icons.diagnostics.Error,
      Warn = core.icons.diagnostics.Warning,
      Hint = core.icons.diagnostics.Hint,
      Info = core.icons.diagnostics.Information,
    }) do
      local hl = "DiagnosticSign" .. name
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })

      diagnostic_opts.signs.text[vim.diagnostic.severity[name:upper()]] = icon
      diagnostic_opts.signs.texthl[vim.diagnostic.severity[name:upper()]] = hl
      diagnostic_opts.signs.numhl[vim.diagnostic.severity[name:upper()]] = hl
    end

    vim.diagnostic.config(diagnostic_opts)

    -- Setup language servers
    local capabilities = lsp_utils.get_capabilities({
      workspace = {
        -- PERF: didChangeWatchedFiles is too slow.
        -- TODO: Remove this when https://github.com/neovim/neovim/issues/23291#issuecomment-1686709265 is fixed.
        didChangeWatchedFiles = { dynamicRegistration = false },
      },
    })

    lsp_utils.set_handlers()

    require("mason-lspconfig").setup({
      handlers = {
        function(server)
          local server_opts = vim.tbl_deep_extend("force", {
            capabilities = vim.deepcopy(capabilities),
          }, opts.servers[server] or {})

          if opts.setup[server] then
            if opts.setup[server](server, server_opts) then
              return
            end
          elseif opts.setup["*"] then
            if opts.setup["*"](server, server_opts) then
              return
            end
          end
          require("lspconfig")[server].setup(server_opts)
        end,
      },
    })

    -- Setup LSP keymaps
    core.auto_cmds({
      {
        "LspAttach",
        {
          group = "lspconfig",
          callback = function(args)
            local buffer = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)

            if client then
              -- inlay hints
              local ih = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint
              if ih then
                if client.supports_method("textDocument/inlayHint") then
                  if type(ih) == "function" then
                    ih(buffer)
                  elseif type(ih) == "table" and ih.enable then
                    ih.enable(buffer)
                  end
                end
              end

              -- Code lens
              if vim.lsp.codelens then
                if client.supports_method("textDocument/codeLens") then
                  vim.lsp.codelens.refresh()
                  core.auto_cmds({
                    {
                      { "BufEnter", "CursorHold", "InsertLeave" },
                      {
                        buffer = buffer,
                        callback = vim.lsp.codelens.refresh,
                      },
                    },
                  })
                end
              end
            end

            -- Mappings
            ---@type Mappings
            local mappings = require("config.mappings").lsp_mappings(args)

            lsp_utils.remove_unsupported_methods(buffer, mappings)

            core.map(mappings, {
              buffer = buffer,
              silent = true,
            })

            lsp_utils.set_document_highlight(args)
          end,
        },
      },
    })
  end,
}
