---@module "lazy"
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

    -- Jump directly to the first available definition every time.
    vim.lsp.handlers["textDocument/definition"] = function(_, result)
      if not result or vim.tbl_isempty(result) then
        return
      end

      if vim.islist(result) then
        vim.lsp.util.jump_to_location(result[1], "utf-8")
      else
        vim.lsp.util.jump_to_location(result, "utf-8")
      end
    end

    -- LSP info border
    require("lspconfig.ui.windows").default_options.border = core.config.ui.transparent.floats and "rounded" or "none"

    -- Diagnostics
    opts.diagnostics = opts.diagnostics or {}
    opts.diagnostics.virtual_text = opts.diagnostics.virtual_text or {}
    opts.diagnostics.virtual_text.prefix = "icons"

    -- Code lens
    opts.codelens = opts.codelens or {}
    opts.codelens.enabled = false

    -- Semantic tokens
    LazyVim.lsp.on_attach(function(client, buffer)
      if
        vim.lsp.semantic_tokens
        and client.supports_method("textDocument/semanticTokens/full")
        and vim.b[buffer].semantic_tokens == nil
      then
        vim.b[buffer].semantic_tokens = true
      end
    end)

    -- Workspace diagnostics
    LazyVim.lsp.on_attach(function(client, buffer)
      require("workspace-diagnostics").populate_workspace_diagnostics(client, buffer)
    end)
  end,
}
