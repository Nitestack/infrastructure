---@type LazySpec
return {
  { import = "lazyvim.plugins.extras.editor.trouble-v3" },
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    ---@type trouble.Config
    opts = {
      auto_close = true,
      focus = true,
      icons = {
        kinds = vim.tbl_map(function(icon)
          return icon .. " "
        end, core.icons.kind),
      },
    },
  },
}
