---@type LazyPluginSpec
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = core.lazy_map({
    [{ "n", "i", "t" }] = {
      ["<C-t>"] = {},
    },
  }),
  ---@type ToggleTermConfig
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    open_mapping = "<C-t>",
    direction = "float",
    highlights = {
      NormalFloat = {
        link = "NormalFloat",
      },
    },
    float_opts = {
      border = core.config.ui.transparent.floats and "curved" or "none",
    },
  },
}
