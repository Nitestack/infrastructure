return utils.plugin.with_extensions({
  { import = "lazyvim.plugins.extras.coding.copilot" },
  { import = "lazyvim.plugins.extras.coding.copilot-chat" },
  {
    "zbirenbaum/copilot.lua",
    opts = {
      filetypes = { ["*"] = true },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = { model = "gpt-4o" },
  },
}, {
  which_key = {
    { "<leader>a", group = "AI" },
  },
})
