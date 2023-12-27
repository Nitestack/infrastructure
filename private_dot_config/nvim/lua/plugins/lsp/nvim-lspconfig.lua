---@type LazyPluginSpec
return {
  "neovim/nvim-lspconfig",
  init = function()
    require("lazyvim.util.lsp").on_attach(function()
      for name, icon in pairs(require("lazyvim.config").icons.diagnostics) do
        name = "DiagnosticSign" .. name
        vim.fn.sign_define(name, { text = icon, texthl = name, numhl = name })
      end
    end)
  end,
  ---@type PluginLspOpts
  opts = {
    diagnostics = {
      update_in_insert = false,
      virtual_text = {
        prefix = "",
      },
    },
    inlay_hints = {
      enable = true,
    },
  },
}
