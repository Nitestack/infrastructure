return utils.lsp.load_language({
  plugins = {
    {
      "neovim/nvim-lspconfig",
      ---@param opts PluginLspOpts
      opts = function(_, opts)
        opts.servers = opts.servers or {}

        -- Lua
        local lua_ls_filetypes = require("lspconfig.server_configurations.lua_ls").default_config.filetypes
        opts.servers.lua_ls = opts.servers.lua_ls or {}
        opts.servers.lua_ls.filetypes = vim.list_extend(lua_ls_filetypes, { "lua.chezmoitmpl" })
        -- Bash
        local bashls_filetypes = require("lspconfig.server_configurations.bashls").default_config.filetypes
        opts.servers.bashls = opts.servers.bashls or {}
        opts.servers.bashls.filetypes = vim.list_extend(bashls_filetypes, { "sh.chezmoitmpl" })
        -- PowerShell
        local powershell_es_filetypes =
          require("lspconfig.server_configurations.powershell_es").default_config.filetypes
        opts.servers.powershell_es = opts.servers.powershell_es or {}
        opts.servers.powershell_es.filetypes = vim.list_extend(powershell_es_filetypes, { "ps1.chezmoitmpl" })
      end,
    },
  },
})
