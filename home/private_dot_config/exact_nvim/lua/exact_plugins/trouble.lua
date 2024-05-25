---@type LazySpec
return {
  { import = "lazyvim.plugins.extras.editor.trouble-v3" },
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    keys = core.lazy_map({
      n = {
        [{ "<leader>cs", "<leader>cS" }] = { false },
      },
    }),
    ---@type trouble.Config
    opts = {
      focus = true,
      icons = {
        kinds = vim.tbl_map(function(icon)
          return icon .. " "
        end, core.icons.kind),
      },
    },
  },
}
