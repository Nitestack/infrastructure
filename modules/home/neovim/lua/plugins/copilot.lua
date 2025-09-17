---@type LazyPluginSpec
return {
  { import = "lazyvim.plugins.extras.ai.copilot" },
  {
    "zbirenbaum/copilot.lua",
    opts = {
      filetypes = { ["*"] = true },
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
  },
}
