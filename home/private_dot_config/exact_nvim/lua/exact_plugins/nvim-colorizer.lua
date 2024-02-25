---@type LazyPluginSpec
return {
  "NvChad/nvim-colorizer.lua",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    user_default_options = {
      css = true,
      css_fn = true,
      tailwind = true,
    },
  },
}
