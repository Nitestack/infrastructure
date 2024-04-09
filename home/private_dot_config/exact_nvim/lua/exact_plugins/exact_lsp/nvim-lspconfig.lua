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
    local lsp_utils = require("utils.lsp")

    -- Load `neoconf.nvim`. See https://github.com/LazyVim/LazyVim/issues/1070
    if require("lazy.core.config").spec.plugins["neoconf.nvim"] ~= nil then
      local plugin = require("lazy.core.config").spec.plugins["neoconf.nvim"]
      require("neoconf").setup(require("lazy.core.plugin").values(plugin, "opts", false))
    end

    -- Icons
    local diagnostic_icons = {
      Error = core.icons.diagnostics.Error,
      Warn = core.icons.diagnostics.Warning,
      Hint = core.icons.diagnostics.Hint,
      Info = core.icons.diagnostics.Information,
    }

    -- LSP info border
    require("lspconfig.ui.windows").default_options.border = core.config.ui.transparent.floats and "rounded" or "none"

    -- Diagnostic config
    ---@type vim.diagnostic.Opts
    local diagnostic_opts = {
      underline = true,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        -- this only works on a recent 0.10.0 build
        prefix = function(diagnostic)
          for name, icon in pairs(diagnostic_icons) do
            if diagnostic.severity == vim.diagnostic.severity[name:upper()] then
              return icon
            end
            ---@diagnostic disable-next-line: missing-return
          end
        end,
      },
      signs = {
        text = {},
        texthl = {},
        numhl = {},
      },
      update_in_insert = not core.config.performance_mode,
      severity_sort = true,
    }
    -- Diagnostic signs
    for name, icon in pairs(diagnostic_icons) do
      local hl = "DiagnosticSign" .. name
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })

      diagnostic_opts.signs.text[vim.diagnostic.severity[name:upper()]] = icon
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
              -- Inlay hints
              if client.supports_method("textDocument/inlayHint") then
                require("utils.toggle").inlay_hints(buffer, false) -- `false` - disabled by default
              end

              -- Code lens
              if vim.lsp.codelens and client.supports_method("textDocument/codeLens") then
                vim.lsp.codelens.refresh({ bufnr = buffer })
                core.auto_cmds({
                  {
                    { "BufEnter", "CursorHold", "InsertLeave" },
                    {
                      buffer = buffer,
                      callback = function(a)
                        vim.lsp.codelens.refresh({ bufnr = a.buf })
                      end,
                    },
                  },
                })
              end

              -- Semantic tokens
              if
                vim.lsp.semantic_tokens
                and client.supports_method("textDocument/semanticTokens/full")
                and vim.b[buffer].semantic_tokens == nil
              then
                vim.b[buffer].semantic_tokens = true
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
