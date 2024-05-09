---@type LazyPluginSpec
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    {
      "folke/neoconf.nvim",
      dependencies = "neovim/nvim-lspconfig",
      cmd = "Neoconf",
    },
    {
      "folke/neodev.nvim",
      opts = {},
    },
    {
      "artemave/workspace-diagnostics.nvim",
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
    -- Load `neoconf.nvim`. See https://github.com/LazyVim/LazyVim/issues/1070
    if require("lazy.core.config").spec.plugins["neoconf.nvim"] ~= nil then
      local plugin = require("lazy.core.config").spec.plugins["neoconf.nvim"]
      require("neoconf").setup(require("lazy.core.plugin").values(plugin, "opts", false))
    end

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
          for name, icon in pairs(core.icons.diagnostics) do
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
    for name, icon in pairs(core.icons.diagnostics) do
      local hl = "DiagnosticSign" .. name
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })

      diagnostic_opts.signs.text[vim.diagnostic.severity[name:upper()]] = icon
      diagnostic_opts.signs.numhl[vim.diagnostic.severity[name:upper()]] = hl
    end

    vim.diagnostic.config(diagnostic_opts)

    -- Setup capabilities
    local capabilities = utils.lsp.get_capabilities({
      workspace = {
        -- PERF: didChangeWatchedFiles is too slow.
        -- TODO: Remove this when https://github.com/neovim/neovim/issues/23291#issuecomment-1686709265 is fixed.
        didChangeWatchedFiles = { dynamicRegistration = false },
      },
    })

    -- Setup additional settings for handlers
    utils.lsp.set_handlers()

    require("mason-lspconfig").setup({
      handlers = {
        function(server)
          ---@type _.lspconfig.options
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

          local on_attach = server_opts.on_attach

          server_opts.on_attach = function(client, bufnr)
            -- Workspace diagnostics
            require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)

            -- If there is an existing `on_attach` function, call it
            if on_attach then
              on_attach(client, bufnr)
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
          ---@param args { buf: integer, data: { client_id: integer } }
          callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)

            if client then
              if client.supports_method("textDocument/inlayHint") then
                utils.toggle.inlay_hints(args.buf, false) -- `false` - disabled by default
              end
              utils.lsp.set_code_lens(client, args.buf)
              utils.lsp.set_semantic_tokens(client, args.buf)
              utils.lsp.set_document_highlight(client, args.buf)
            end

            utils.lsp.attach_mappings(core.mappings.lsp_mappings, args.buf)
          end,
        },
      },
    })
  end,
}
