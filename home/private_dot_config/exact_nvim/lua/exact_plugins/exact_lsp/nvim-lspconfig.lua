---@param opts? lsp.Client.filter
local function get_clients(opts)
  local ret = {} ---@type lsp.Client[]
  if vim.lsp.get_clients then
    ret = vim.lsp.get_clients(opts)
  else
    ---@diagnostic disable-next-line: deprecated
    ret = vim.lsp.get_active_clients(opts)
    if opts and opts.method then
      ---@param client lsp.Client
      ret = vim.tbl_filter(function(client)
        return client.supports_method(opts.method, { bufnr = opts.bufnr })
      end, ret)
    end
  end
  return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

---@param method string
local function client_supports_method(method, buffer)
  method = method:find("/") and method or "textDocument/" .. method
  local clients = get_clients({ bufnr = buffer })
  for _, client in ipairs(clients) do
    if client.supports_method(method) then
      return true
    end
  end
  return false
end

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
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
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
      update_in_insert = false,
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
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local capabilities =
      vim.tbl_deep_extend("force", {}, vim.lsp.protocol.make_client_capabilities(), cmp_nvim_lsp.default_capabilities())

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
            ---@type Mappings
            local mappings = require("config.mappings").lsp_mappings(args)

            -- If client doesn't support method, remove it from mappings
            for _, mode in pairs(mappings) do
              for mapping, mapping_info in pairs(mode) do
                if mapping_info.has and not client_supports_method(mapping_info.has, args.buf) then
                  mode[mapping] = nil
                else
                  mapping_info.has = nil
                end
              end
            end

            core.map(mappings, {
              buffer = args.buf,
              silent = true,
            })
          end,
        },
      },
    })
  end,
}
