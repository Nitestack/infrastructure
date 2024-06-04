---@module "lazy"
---@type LazyPluginSpec
return {
  "LunarVim/bigfile.nvim",
  event = "BufReadPre",
  ---@module "bigfile"
  ---@type config
  opts = {},
}
