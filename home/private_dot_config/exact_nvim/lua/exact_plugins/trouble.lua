return utils.plugin.with_extensions({
  {
    "folke/trouble.nvim",
    ---@module "trouble"
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
}, {
  lualine = "trouble",
  catppuccin = {
    lsp_trouble = true,
  },
})
