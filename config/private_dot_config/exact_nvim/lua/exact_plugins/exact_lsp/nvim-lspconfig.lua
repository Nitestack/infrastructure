---@type LazyPluginSpec
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "artemave/workspace-diagnostics.nvim",
      opts = {},
    },
  },
  -- Modify LSP mappings
  init = function()
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    -- add `F2` to rename and simply remap it to `<leader>cr`
    keys[#keys + 1] = { "<F2>", "<leader>cr", desc = "Rename", has = "rename", remap = true }
  end,
  ---@param opts PluginLspOpts
  opts = function(_, opts)
    -- Capabilities
    opts.capabilities = {
      workspace = {
        -- PERF: didChangeWatchedFiles is too slow.
        -- TODO: Remove this when https://github.com/neovim/neovim/issues/23291#issuecomment-1686709265 is fixed.
        didChangeWatchedFiles = { dynamicRegistration = false },
      },
    }

    -- Workspace diagnostics
    LazyVim.lsp.on_attach(function(client, buffer)
      if client.name ~= "copilot" then
        require("workspace-diagnostics").populate_workspace_diagnostics(client, buffer)
      end
    end)
  end,
}
