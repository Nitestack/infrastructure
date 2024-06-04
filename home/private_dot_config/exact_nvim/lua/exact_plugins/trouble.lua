---@module "lazy"
---@type LazyPluginSpec
return {
  "folke/trouble.nvim",
  keys = core.lazy_map({
    n = {
      [{ "<leader>cs", "<leader>cS" }] = { false },
    },
  }),
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
}
