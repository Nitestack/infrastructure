---@type LazyPluginSpec
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "artemave/workspace-diagnostics.nvim",
      opts = {},
    },
  },
  ---@param opts PluginLspOpts
  opts = function(_, opts)
    -- Modify LSP mappings
    opts.servers["*"].keys = vim.list_extend(opts.servers["*"].keys or {}, {
      { "<F2>", "<leader>cr", desc = "Rename", has = "rename", remap = true },
    })
    -- Workspace diagnostics
    Snacks.util.lsp.on(function(buffer, client)
      if client.name ~= "copilot" then
        require("workspace-diagnostics").populate_workspace_diagnostics(client, buffer)
      end
    end)
  end,
}
